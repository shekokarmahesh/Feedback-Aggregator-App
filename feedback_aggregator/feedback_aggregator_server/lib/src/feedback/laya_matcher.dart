import 'dart:math';

import '../generated/protocol.dart';
import '../laya_poc/laya_client.dart';

class IssueCandidate {
  final int id;
  final String title;
  final String text;
  const IssueCandidate(this.id, this.title, this.text);
}

class GroupingDecision {
  final int? groupId;
  final double confidence;
  final double severity;
  final bool review;
  const GroupingDecision({
    this.groupId,
    required this.confidence,
    required this.severity,
    this.review = false,
  });
}

abstract class GroupingMatcher {
  Future<GroupingDecision> match(
    WorkspaceTicket report,
    List<IssueCandidate> candidates,
  );
}

String reportText(WorkspaceTicket report) {
  var body = report.description.split('\n\n').last;
  if (body.contains('\n')) body = body.substring(body.indexOf('\n') + 1);
  return '${report.title}. ${body.substring(0, min(240, body.length))}';
}

/// Retrieval only narrows the candidate list. Laya makes every merge decision.
List<IssueCandidate> shortlist(
  WorkspaceTicket report,
  List<IssueCandidate> candidates,
) {
  Set<String> words(String value) => RegExp(r'[a-z0-9]+')
      .allMatches(value.toLowerCase())
      .map((m) => m.group(0)!)
      .where(
        (w) =>
            w.length > 2 &&
            !{
              'the',
              'and',
              'for',
              'with',
              'this',
              'that',
              'from',
              'have',
              'are',
              'our',
              'can',
              'please',
              'would',
            }.contains(w),
      )
      .toSet();
  final terms = words(reportText(report));
  double relevance(IssueCandidate candidate) {
    final other = words(candidate.text);
    return terms.intersection(other).length / max(1, terms.union(other).length);
  }

  return ([
    ...candidates,
  ]..sort((a, b) => relevance(b).compareTo(relevance(a)))).take(3).toList();
}

class LayaGroupingMatcher implements GroupingMatcher {
  final LayaClient client;
  const LayaGroupingMatcher(this.client);
  static const threshold = .75;

  static const _severity = {
    'type': 'score',
    'instructions': 'How severe is the customer problem in reportA?',
    'criteria': [
      'Optional enhancement or cosmetic preference.',
      'Minor inconvenience with a workaround.',
      'Important functionality is impaired.',
      'A core workflow is blocked.',
      'Data loss, security incident, or complete service outage.',
    ],
  };

  double _number(dynamic value, double maxValue) {
    if (value is! num || !value.isFinite || value < 0 || value > maxValue) {
      throw const LayaFailure('Invalid grouping response.');
    }
    return value.toDouble();
  }

  Map _answers(dynamic value) {
    if (value is! Map ||
        value['model'] != 'laya-rl-agent' ||
        value['routing'] is! Map ||
        value['routing']['model'] != layaModel ||
        value['answers'] is! Map ||
        value['usage'] is! Map) {
      throw const LayaFailure('Invalid grouping response.');
    }
    final usage = value['usage'];
    if (usage['truncated'] == true ||
        (usage['state_tokens_dropped'] is num &&
            usage['state_tokens_dropped'] > 0) ||
        (usage['options'] is Map && usage['options'].isNotEmpty)) {
      throw const LayaFailure('Grouping input exceeded the model budget.');
    }
    return value['answers'] as Map;
  }

  @override
  Future<GroupingDecision> match(
    WorkspaceTicket report,
    List<IssueCandidate> candidates,
  ) async {
    const base = {'model': layaModel, 'max_len': 384, 'head_max_len': 128};
    if (candidates.isEmpty) {
      final result = await client.post(client.endpoint, {
        ...base,
        'state': {'reportA': reportText(report)},
        'questions': {'severity': _severity},
      });
      final severity = _answers(result)['severity'];
      if (severity is! Map || severity['type'] != 'score') {
        throw const LayaFailure('Invalid grouping response.');
      }
      return GroupingDecision(
        confidence: 1,
        severity: _number(severity['score'], 4),
      );
    }
    final result = await client.post(
      client.endpoint.replace(path: '${client.endpoint.path}/batch'),
      {
        ...base,
        'states': [
          for (final c in candidates) ...[
            {'reportA': report.title, 'reportB': c.title},
            {'reportA': reportText(report), 'reportB': c.text},
          ],
        ],
        'questions': {
          'same': {
            'type': 'noul',
            'instructions':
                'Do both reports describe the same specific customer problem or request the same product change? Ignore wording and channel. Different failures or different requested features are not the same issue.',
          },
          'severity': _severity,
        },
      },
    );
    if (result is! Map ||
        result['results'] is! List ||
        result['results'].length != candidates.length * 2) {
      throw const LayaFailure('Invalid grouping response.');
    }
    final probabilities =
        <({int id, double probability, bool contradiction})>[];
    var severity = 0.0;
    for (var i = 0; i < candidates.length; i++) {
      final scores = <double>[];
      for (var j = 0; j < 2; j++) {
        final answers = _answers(result['results'][i * 2 + j]);
        final same = answers['same'];
        final impact = answers['severity'];
        if (same is! Map ||
            same['type'] != 'noul' ||
            impact is! Map ||
            impact['type'] != 'score') {
          throw const LayaFailure('Invalid grouping response.');
        }
        scores.add(_number(same['noul'], 1));
        severity = max(severity, _number(impact['score'], 4));
      }
      probabilities.add((
        id: candidates[i].id,
        probability: scores.reduce(max),
        contradiction:
            scores.reduce(min) < .20 && scores.reduce(max) >= threshold,
      ));
    }
    probabilities.sort((a, b) => b.probability.compareTo(a.probability));
    final best = probabilities.first;
    final ambiguous =
        best.contradiction ||
        (probabilities.length > 1 &&
            best.probability - probabilities[1].probability < .08);
    return GroupingDecision(
      groupId: best.probability >= threshold && !ambiguous ? best.id : null,
      confidence: best.probability,
      severity: severity,
      review:
          best.probability >= .50 &&
          (best.probability < threshold || ambiguous),
    );
  }
}
