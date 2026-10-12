import 'dart:convert';
import 'dart:io';
import 'package:feedback_aggregator_server/src/laya_poc/laya_client.dart';
import 'package:feedback_aggregator_server/src/laya_poc/poc_run.dart';
import 'package:feedback_aggregator_server/src/laya_poc/sample_feedback.dart';
import 'package:test/test.dart';

class FakeEvaluator implements LayaEvaluator {
  final LayaDecision Function(Map<String, dynamic>) answer;
  FakeEvaluator(this.answer);
  @override
  Future<LayaDecision> evaluate(Map<String, dynamic> request) async =>
      answer(request);
}

LayaDecision decision(
  String choice, {
  double confidence = .98,
  double severity = 2,
}) => LayaDecision(
  choice: choice,
  confidence: confidence,
  severity: severity,
  severityConfidence: .99,
  probabilities: {choice: 1},
  inputTokens: 100,
  cost: 0,
  model: layaModel,
);

void main() {
  const a = SampleFeedback(
    'a',
    'Slack',
    'person-1',
    'Reset emails missing',
    'Reset email never arrives.',
    2,
    'reset',
  );
  const b = SampleFeedback(
    'b',
    'Email',
    'person-1',
    'No recovery code',
    'Reset email code is not delivered.',
    3,
    'reset',
  );
  const c = SampleFeedback(
    'c',
    'Discord',
    'person-2',
    'Google login loop',
    'Google login redirects to login.',
    4,
    'google',
  );

  test(
    'cross-channel merges preserve evidence and count identified reporters once',
    () async {
      final run = PocRun('run', [a, b]);
      await run.advance(FakeEvaluator((_) => decision('new_issue')));
      await run.advance(FakeEvaluator((_) => decision('POC-1')));
      expect(run.issues.single.reports.map((r) => r.id), ['a', 'b']);
      expect(run.issues.single.uniqueReporters, 1);
      expect(run.issues.single.sources, {'Slack', 'Email'});
      expect(run.metrics['precision'], 1);
      expect(run.metrics['recall'], 1);
    },
  );

  test(
    'uncertain matches stay out of groups and count as missed duplicates',
    () async {
      final run = PocRun('run', [a, b]);
      await run.advance(FakeEvaluator((_) => decision('new_issue')));
      await run.advance(
        FakeEvaluator((_) => decision('POC-1', confidence: .5)),
      );
      expect(run.issues.single.reports, hasLength(1));
      expect(run.metrics['reviewCount'], 1);
      expect(run.metrics['missedDuplicatePairs'], 1);
      expect(run.metrics['recall'], 0);
      expect(run.metrics['precision'], isNull);
    },
  );

  test(
    'evaluation exposes false merges rather than rewarding fewer groups',
    () async {
      final run = PocRun('run', [a, b, c]);
      await run.advance(FakeEvaluator((_) => decision('new_issue')));
      await run.advance(FakeEvaluator((_) => decision('POC-1')));
      await run.advance(FakeEvaluator((_) => decision('POC-1')));
      expect(run.metrics['falseMergePairs'], 2);
      expect(run.metrics['precision'], closeTo(1 / 3, .0001));
      expect(run.metrics['recall'], 1);
    },
  );

  test(
    'gold labels never reach the model and candidate issues are discovered',
    () async {
      final run = PocRun('run', generateSampleFeedback());
      final initial = run.requestForNext();
      expect(initial['state'], isA<String>());
      expect(initial['candidates'], isEmpty);
      final encoded = jsonEncode(initial);
      expect(encoded, isNot(contains('expectedIssue')));
      expect(encoded, isNot(contains('google-login')));
      await run.advance(FakeEvaluator((_) => decision('new_issue')));
      expect(
        (run.requestForNext()['candidates'] as List).single['text'],
        run.reports.first.text,
      );
    },
  );

  test(
    'provider failure leaves the report retryable and retains previous results',
    () async {
      final run = PocRun('run', [a, b]);
      await run.advance(FakeEvaluator((_) => decision('new_issue')));
      await expectLater(
        run.advance(
          FakeEvaluator((_) => throw const LayaFailure('unavailable')),
        ),
        throwsA(isA<LayaFailure>()),
      );
      expect(run.processed, 1);
      expect(run.busy, isFalse);
      await run.advance(FakeEvaluator((_) => decision('POC-1')));
      expect(run.complete, isTrue);
    },
  );

  test('high-confidence critical severity overrides low frequency', () async {
    final run = PocRun('run', [a]);
    await run.advance(FakeEvaluator((_) => decision('new_issue', severity: 4)));
    expect(run.issues.single.score, 95);
  });

  test('noise and vague reports do not create actionable issues', () async {
    final run = PocRun('run', [a, b]);
    await run.advance(FakeEvaluator((_) => decision('noise')));
    await run.advance(FakeEvaluator((_) => decision('uncertain')));
    expect(run.issues, isEmpty);
    expect(run.metrics['noiseCount'], 1);
    expect(run.metrics['reviewCount'], 1);
  });

  test(
    'HTTP adapter uses local System One API and rejects an unknown choice',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final run = PocRun('run', [a]);
      final request = run.requestForNext();
      final handled = server.first.then((req) async {
        expect(req.uri.path, '/v1/systemone');
        expect(req.headers.value('authorization'), 'Bearer fake-test-key');
        final body = jsonDecode(await utf8.decoder.bind(req).join()) as Map;
        expect(body['model'], layaModel);
        expect((body['questions'] as Map)['kind']['type'], 'choice');
        req.response.headers.contentType = ContentType.json;
        req.response.write(
          jsonEncode({
            'model': 'laya-rl-agent',
            'routing': {'model': layaModel},
            'answers': {
              'kind': {
                'type': 'choice',
                'choice': 'unknown-kind',
                'confidence': 1,
                'answer_confidence': 1,
                'probabilities': {
                  'bug': 1,
                  'feature': 0,
                  'noise': 0,
                  'uncertain': 0,
                },
              },
              'severity': {
                'type': 'score',
                'score': 2,
                'confidence': 1,
                'answer_confidence': 1,
              },
            },
            'usage': {'input_tokens': 100},
          }),
        );
        await req.response.close();
      });
      final client = LayaClient(
        apiKey: 'fake-test-key',
        endpoint: Uri.parse(
          'http://127.0.0.1:${server.port}/v1/systemone',
        ),
      );
      await expectLater(client.evaluate(request), throwsA(isA<LayaFailure>()));
      await handled;
    },
  );

  test('HTTP adapter honors its configured request timeout', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    // Accept the request but deliberately never send a response.
    final handled = server.first.then((req) => req.drain<void>());
    final client = LayaClient(
      endpoint: Uri.parse('http://127.0.0.1:${server.port}/v1/systemone'),
      requestTimeout: const Duration(milliseconds: 200),
    );
    await expectLater(
      client.evaluate(PocRun('run', [a]).requestForNext()),
      throwsA(
        isA<LayaFailure>().having(
          (error) => error.message,
          'message',
          'Laya timed out. Resume to retry the current report.',
        ),
      ),
    );
    await handled;
  }, timeout: const Timeout(Duration(seconds: 5)));

  Map<String, dynamic> validResponse() => {
    'model': 'laya-rl-agent',
    'routing': {'model': layaModel},
    'answers': {
      'kind': {
        'type': 'choice',
        'choice': 'bug',
        'confidence': .15,
        'answer_confidence': .98,
        'probabilities': {
          'bug': .98,
          'feature': 0,
          'uncertain': .01,
          'noise': .01,
        },
      },
      'severity': {
        'type': 'score',
        'score': 2.5,
        'confidence': .2,
        'answer_confidence': .75,
      },
    },
    'usage': {'input_tokens': 555, 'truncated': false},
  };

  test(
    'local response uses answer confidence rather than entropy confidence',
    () {
      final request = PocRun('run', [a]).requestForNext();
      final result = parseLayaDecision(validResponse(), request);
      expect(result.confidence, .98);
      expect(result.severityConfidence, .75);
      expect(result.cost, 0);
      expect(result.probabilities, isEmpty);
      expect(result.choice, 'new_issue');
      expect(result.triage, 'bug');
      expect(result.severity, 2.5);
      expect(result.model, 'Laya / english');
    },
  );

  test(
    'truncated or collapsed input is rejected rather than silently grouped',
    () {
      final request = PocRun('run', [a]).requestForNext();
      for (final usage in [
        {'input_tokens': 555, 'truncated': true},
        {'input_tokens': 555, 'state_tokens_dropped': 1},
        {
          'input_tokens': 555,
          'options': {
            'match': ['collapsed'],
          },
        },
      ]) {
        final response = validResponse()..['usage'] = usage;
        expect(
          () => parseLayaDecision(response, request),
          throwsA(isA<LayaFailure>()),
        );
      }
    },
  );
  Map<String, dynamic> duplicateResponse(double probability) => {
    'model': 'laya-rl-agent',
    'routing': {'model': layaModel},
    'answers': {
      'same': {
        'type': 'noul',
        'noul': probability,
        'answer_confidence': probability > .5 ? probability : 1 - probability,
      },
    },
    'usage': {'input_tokens': 50, 'truncated': false},
  };

  test(
    'pairwise matching uses true probability and sends competing matches to review',
    () {
      final request = PocRun('run', [a]).requestForNext()
        ..['candidates'] = [
          {'id': 'POC-1', 'text': a.text},
          {'id': 'POC-2', 'text': c.text},
        ];
      final merged = parseLayaDecision(
        validResponse(),
        request,
        duplicateResults: [duplicateResponse(.9), duplicateResponse(.1)],
      );
      expect(merged.choice, 'POC-1');
      expect(merged.confidence, .9);
      expect(merged.inputTokens, 655);
      final competing = parseLayaDecision(
        validResponse(),
        request,
        duplicateResults: [duplicateResponse(.9), duplicateResponse(.88)],
      );
      expect(competing.choice, 'uncertain');
      final unrelated = parseLayaDecision(
        validResponse(),
        request,
        duplicateResults: [duplicateResponse(.1), duplicateResponse(.2)],
      );
      expect(unrelated.choice, 'new_issue');
    },
  );

  test(
    'HTTP adapter batches candidate pairs without sending gold labels',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final request = PocRun('run', [a]).requestForNext()
        ..['candidates'] = [
          {'id': 'POC-1', 'text': b.text},
        ];
      var calls = 0;
      server.listen((req) async {
        calls++;
        expect(req.headers.value('authorization'), isNull);
        final body = jsonDecode(await utf8.decoder.bind(req).join()) as Map;
        expect(body.containsKey('candidates'), isFalse);
        req.response.headers.contentType = ContentType.json;
        if (req.uri.path.endsWith('/batch')) {
          expect(body['states'], [
            {'reportA': a.text, 'reportB': b.text},
          ]);
          req.response.write(
            jsonEncode({
              'results': [duplicateResponse(.93)],
            }),
          );
        } else {
          expect(req.uri.path, '/v1/systemone');
          req.response.write(jsonEncode(validResponse()));
        }
        await req.response.close();
      });
      final result = await LayaClient(
        endpoint: Uri.parse('http://127.0.0.1:${server.port}/v1/systemone'),
      ).evaluate(request);
      expect(result.choice, 'POC-1');
      expect(calls, 2);
    },
  );
}
