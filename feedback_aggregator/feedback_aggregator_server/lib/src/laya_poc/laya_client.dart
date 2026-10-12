import 'dart:async';
import 'dart:convert';
import 'dart:io';

const layaModel = 'english';
// Development policies, not an accuracy guarantee.
const pocMatchThreshold = .80;
const pocTriageThreshold = .60;
const pocNewIssueCeiling = .50;

class LayaFailure implements Exception {
  final String message;
  const LayaFailure(this.message);
}

class LayaDecision {
  final String choice;
  final double confidence;
  final double severity;
  final double severityConfidence;
  final Map<String, double> probabilities;
  final int inputTokens;
  final double? cost;
  final String model;
  final String? triage;
  final double? triageConfidence;
  const LayaDecision({
    required this.choice,
    required this.confidence,
    required this.severity,
    required this.severityConfidence,
    required this.probabilities,
    required this.inputTokens,
    required this.cost,
    required this.model,
    this.triage,
    this.triageConfidence,
  });
}

abstract class LayaEvaluator {
  Future<LayaDecision> evaluate(Map<String, dynamic> request);
}

/// Local Laya's typed System One API. No hosted provider key is required.
class LayaClient implements LayaEvaluator {
  final String apiKey;
  final Uri endpoint;
  final Duration requestTimeout;
  LayaClient({
    this.apiKey = '',
    Uri? endpoint,
    this.requestTimeout = const Duration(seconds: 18),
  }) : endpoint = endpoint ?? Uri.parse('http://127.0.0.1:8093/v1/systemone');

  Future<bool> isAvailable() async {
    final http = HttpClient()..connectionTimeout = const Duration(seconds: 2);
    try {
      return await (() async {
        final request = await http.getUrl(endpoint.resolve('/health'));
        request.followRedirects = false;
        if (apiKey.isNotEmpty) {
          request.headers.set(
            HttpHeaders.authorizationHeader,
            'Bearer $apiKey',
          );
        }
        final response = await request.close();
        if (response.statusCode != 200) return false;
        final body = await utf8.decoder.bind(response).join();
        return (jsonDecode(body) as Map)['status'] == 'ok';
      })().timeout(const Duration(seconds: 2));
    } catch (_) {
      return false;
    } finally {
      http.close(force: true);
    }
  }

  @override
  Future<LayaDecision> evaluate(Map<String, dynamic> request) async {
    final body = {...request}..remove('candidates');
    final result = await _post(endpoint, body);
    // Validate the complete triage response before spending work on candidates.
    final triage = _triage(result, request);
    final candidates = request['candidates'] as List;
    final duplicates = <dynamic>[];
    if (['bug', 'feature'].contains(triage.choice) &&
        triage.confidence >= pocTriageThreshold &&
        candidates.isNotEmpty) {
      final batch = await _post(
        endpoint.replace(path: '${endpoint.path}/batch'),
        {
          'model': request['model'],
          'max_len': request['max_len'],
          'head_max_len': request['head_max_len'],
          'states': [
            for (final candidate in candidates)
              {'reportA': request['state'], 'reportB': candidate['text']},
          ],
          'questions': {
            'same': {
              'type': 'noul',
              'instructions':
                  'Do reportA and reportB describe the same specific issue? '
                  'Similar topics with different symptoms are different issues.',
            },
          },
        },
      );
      if (batch is! Map || batch['results'] is! List) {
        _invalid();
      }
      duplicates.addAll(batch['results'] as List);
    }
    return parseLayaDecision(result, request, duplicateResults: duplicates);
  }

  Future<dynamic> _post(Uri url, Map<String, dynamic> body) async {
    final http = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      return await (() async {
        final req = await http.postUrl(url);
        req.followRedirects = false;
        if (apiKey.isNotEmpty) {
          req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
        }
        req.headers.contentType = ContentType.json;
        req.write(jsonEncode(body));
        final response = await req.close();
        if (response.statusCode != 200) {
          throw LayaFailure(switch (response.statusCode) {
            401 || 403 =>
              'The local Laya service requires a matching server-side layaApiKey.',
            422 => 'Laya rejected the request shape or model configuration.',
            429 || 503 => 'Laya is busy. Wait a moment and resume the run.',
            _ =>
              'Laya is temporarily unavailable. Resume to retry the current report.',
          });
        }
        final bytes = <int>[];
        await for (final chunk in response) {
          bytes.addAll(chunk);
          if (bytes.length > 128 * 1024) {
            throw const LayaFailure('Laya returned an unexpected response.');
          }
        }
        return jsonDecode(utf8.decode(bytes));
      })().timeout(requestTimeout);
    } on LayaFailure {
      rethrow;
    } on TimeoutException {
      throw const LayaFailure(
        'Laya timed out. Resume to retry the current report.',
      );
    } catch (_) {
      // Provider bodies and credentials must never enter logs or client errors.
      throw const LayaFailure(
        'Could not reach local Laya. Start tools/laya/run.sh, then resume.',
      );
    } finally {
      http.close(force: true);
    }
  }
}

Never _invalid() =>
    throw const LayaFailure('Laya returned an invalid decision.');

double _number(dynamic value, double maximum) {
  if (value is! num || !value.isFinite || value < 0 || value > maximum) {
    _invalid();
  }
  return value.toDouble();
}

int _validateEnvelope(dynamic json, Map<String, dynamic> request) {
  if (json is! Map) {
    _invalid();
  }
  final usage = json['usage'];
  final routing = json['routing'];
  if (usage is! Map ||
      routing is! Map ||
      json['model'] != 'laya-rl-agent' ||
      routing['model'] != request['model'] ||
      json['answers'] is! Map) {
    _invalid();
  }
  if (usage['truncated'] == true ||
      (usage['state_tokens_dropped'] is num &&
          usage['state_tokens_dropped'] > 0) ||
      (usage['options'] is Map && (usage['options'] as Map).isNotEmpty)) {
    throw const LayaFailure(
      'Laya could not read the full request within its token budget.',
    );
  }
  final tokens = usage['input_tokens'];
  if (tokens is! int || tokens < 0) {
    _invalid();
  }
  return tokens;
}

({String choice, double confidence}) _triage(
  dynamic json,
  Map<String, dynamic> request,
) {
  _validateEnvelope(json, request);
  final kind = json['answers']['kind'];
  final severity = json['answers']['severity'];
  if (kind is! Map ||
      severity is! Map ||
      kind['type'] != 'choice' ||
      severity['type'] != 'score') {
    _invalid();
  }
  final options = request['questions']['kind']['criteria'] as Map;
  final choice = kind['choice'];
  final probs = kind['probabilities'];
  if (choice is! String ||
      !options.containsKey(choice) ||
      probs is! Map ||
      probs.length != options.length ||
      !options.keys.every(probs.containsKey)) {
    _invalid();
  }
  final probabilities = {
    for (final key in options.keys) key: _number(probs[key], 1),
  };
  final sum = probabilities.values.fold<double>(0, (a, b) => a + b);
  if ((sum - 1).abs() > .02 ||
      probabilities.values.any((p) => p > probabilities[choice]! + .001)) {
    _invalid();
  }
  _number(severity['score'], 4);
  _number(severity['answer_confidence'], 1);
  // Laya's entropy confidence is not the probability of its selected answer.
  return (choice: choice, confidence: _number(kind['answer_confidence'], 1));
}

LayaDecision parseLayaDecision(
  dynamic json,
  Map<String, dynamic> request, {
  List<dynamic> duplicateResults = const [],
}) {
  final triage = _triage(json, request);
  final severity = json['answers']['severity'];
  var tokens = _validateEnvelope(json, request);
  final candidates = request['candidates'] as List;
  final actionable =
      ['bug', 'feature'].contains(triage.choice) &&
      triage.confidence >= pocTriageThreshold;
  if (duplicateResults.length != (actionable ? candidates.length : 0)) {
    _invalid();
  }
  // Each number is an independent binary duplicate probability, not a distribution.
  final probabilities = <String, double>{};
  for (var i = 0; i < duplicateResults.length; i++) {
    final result = duplicateResults[i];
    tokens += _validateEnvelope(result, request);
    final same = result['answers']['same'];
    if (same is! Map || same['type'] != 'noul') {
      _invalid();
    }
    probabilities[candidates[i]['id'] as String] = _number(same['noul'], 1);
    _number(same['answer_confidence'], 1);
  }
  var choice = triage.choice == 'noise' ? 'noise' : 'uncertain';
  var confidence = triage.confidence;
  if (actionable) {
    final sorted = probabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final best = sorted.isEmpty ? 0.0 : sorted.first.value;
    if (best >= pocMatchThreshold &&
        (sorted.length < 2 || sorted[1].value < pocMatchThreshold)) {
      choice = sorted.first.key;
      confidence = best;
    } else if (best <= pocNewIssueCeiling) {
      choice = 'new_issue';
    } else {
      choice = 'uncertain';
      confidence = best;
    }
  }
  return LayaDecision(
    choice: choice,
    confidence: confidence,
    severity: _number(severity['score'], 4),
    severityConfidence: _number(severity['answer_confidence'], 1),
    probabilities: probabilities,
    inputTokens: tokens,
    cost: 0,
    model: 'Laya / ${request['model']}',
    triage: triage.choice,
    triageConfidence: triage.confidence,
  );
}
