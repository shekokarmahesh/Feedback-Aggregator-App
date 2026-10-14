import 'package:feedback_aggregator_server/src/feedback/laya_matcher.dart';
import 'package:feedback_aggregator_server/src/generated/protocol.dart';
import 'package:feedback_aggregator_server/src/laya_poc/laya_client.dart';
import 'package:test/test.dart';

Map<String, dynamic> response(double probability, {bool truncated = false}) => {
  'model': 'laya-rl-agent',
  'routing': {'model': 'english'},
  'usage': {'truncated': truncated, 'input_tokens': 150, 'options': {}},
  'answers': {
    'same': {'type': 'noul', 'noul': probability},
    'severity': {'type': 'score', 'score': 3.0},
  },
};

class _Client extends LayaClient {
  final dynamic result;
  final calls = <Map<String, dynamic>>[];
  _Client(this.result);
  @override
  Future<dynamic> post(Uri url, Map<String, dynamic> body) async {
    calls.add(body);
    return result;
  }
}

WorkspaceTicket report() => WorkspaceTicket(
  workspaceId: 1,
  title: 'CSV exports are empty',
  description: 'Filtered exports contain headers but no rows.',
  source: 'Email',
  status: 'Open',
  priority: 'High',
  supporters: 1,
  requester: 'Maya',
);

void main() {
  test(
    'Laya title and body decisions merge a known issue without lexical fallback',
    () async {
      final client = _Client({
        'results': [response(.81), response(.30), response(.03), response(.07)],
      });
      final decision = await LayaGroupingMatcher(client).match(report(), [
        const IssueCandidate(
          7,
          'CSV export is blank',
          'CSV file contains only headers.',
        ),
        const IssueCandidate(8, 'Dark theme', 'Add dark mode.'),
      ]);
      expect(decision.groupId, 7);
      expect(decision.confidence, .81);
      expect(decision.review, isFalse);
      expect(client.calls.single['states'], hasLength(4));
      expect(client.calls.single['questions']['same']['type'], 'noul');
    },
  );
  test(
    'ambiguous and contradictory model answers stay separate for review',
    () async {
      for (final probs in [
        [.82, .83, .81, .79],
        [.82, .01, .03, .05],
      ]) {
        final client = _Client({
          'results': [for (final p in probs) response(p)],
        });
        final decision = await LayaGroupingMatcher(client).match(report(), [
          const IssueCandidate(7, 'Export', 'Empty file'),
          const IssueCandidate(8, 'Other issue', 'Different workflow'),
        ]);
        expect(decision.groupId, isNull);
        expect(decision.review, isTrue);
      }
    },
  );
  test(
    'truncation, malformed responses, and out-of-range probabilities fail safely',
    () async {
      for (final result in [
        {
          'results': [response(.9, truncated: true), response(.9)],
        },
        {
          'results': [response(2), response(.9)],
        },
        {'results': []},
        {},
      ]) {
        await expectLater(
          LayaGroupingMatcher(
            _Client(result),
          ).match(report(), [const IssueCandidate(7, 'Export', 'Empty file')]),
          throwsA(isA<LayaFailure>()),
        );
      }
    },
  );
  test(
    'the first issue still calls Laya for severity instead of fabricating inference',
    () async {
      final client = _Client(response(0));
      final decision = await LayaGroupingMatcher(client).match(report(), []);
      expect(decision.groupId, isNull);
      expect(decision.severity, 3);
      expect(client.calls, hasLength(1));
      expect(client.calls.single['questions'].keys, ['severity']);
    },
  );
}
