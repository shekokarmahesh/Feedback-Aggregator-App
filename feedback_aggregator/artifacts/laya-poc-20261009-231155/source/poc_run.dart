import 'dart:math';
import 'laya_client.dart';
import 'sample_feedback.dart';

class PocIssue {
  final String id;
  final List<SampleFeedback> reports;
  double severity;
  double confidence;
  bool severityNeedsReview;
  String status = 'Open';
  PocIssue(this.id, SampleFeedback first, LayaDecision decision)
    : reports = [first],
      severity = decision.severity,
      confidence = decision.confidence,
      severityNeedsReview = decision.severityConfidence < pocMatchThreshold;

  int get uniqueReporters => reports.map((r) => r.reporterId).toSet().length;
  Set<String> get sources => reports.map((r) => r.source).toSet();
  Map<String, int> get scoreBreakdown => {
    'severity': (40 * severity / 4).round(),
    'reach': (30 * min(uniqueReporters / 10, 1)).round(),
    'recentReports':
        (20 * min(reports.where((r) => r.hoursAgo < 24).length / 5, 1)).round(),
    'channels': (10 * sources.length / pocSources.length).round(),
  };
  int get score {
    final weighted = scoreBreakdown.values.fold<int>(0, (a, b) => a + b);
    return severity >= 3.5 && !severityNeedsReview
        ? max(95, weighted)
        : weighted;
  }

  void add(SampleFeedback report, LayaDecision decision) {
    reports.add(report);
    confidence = min(confidence, decision.confidence);
    severity = max(severity, decision.severity);
    severityNeedsReview |= decision.severityConfidence < pocMatchThreshold;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': reports.first.title,
    'description': reports.first.text,
    'reportIds': reports.map((r) => r.id).toList(),
    'reportCount': reports.length,
    'uniqueReporters': uniqueReporters,
    'sources': sources.toList(),
    'confidence': confidence,
    'severity': severity,
    'severityNeedsReview': severityNeedsReview,
    'score': score,
    'scoreBreakdown': scoreBreakdown,
    'status': status,
  };
}

/// Disposable, single-process POC state. No real tickets are seeded or modified.
class PocRun {
  final String id;
  final List<SampleFeedback> reports;
  final DateTime createdAt;
  final List<PocIssue> issues = [];
  final List<Map<String, dynamic>> decisions = [];
  bool busy = false;
  int attempts = 0;
  int latencyMs = 0;
  int inputTokens = 0;
  double cost = 0;
  bool costKnown = true;
  String? actualModel;
  PocRun(this.id, this.reports) : createdAt = DateTime.now().toUtc();
  int get processed => decisions.length;
  bool get complete => processed == reports.length;

  Map<String, dynamic> requestForNext() {
    final report = reports[processed];
    // Bound local inference work. Metrics include any lexical retrieval misses.
    Set<String> words(String text) => RegExp(r'[a-z0-9]+')
        .allMatches(text.toLowerCase())
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
                'not',
                'but',
                'our',
              }.contains(w),
        )
        .toSet();
    final incoming = words(report.text);
    double relevance(PocIssue issue) {
      final terms = words(issue.reports.map((r) => r.text).join(' '));
      return incoming.intersection(terms).length /
          max(1, incoming.union(terms).length);
    }

    final candidates = [...issues]
      ..sort((a, b) => relevance(b).compareTo(relevance(a)));
    return {
      'model': layaModel,
      'max_len': 1024,
      'head_max_len': 256,
      'state': report.text,
      'candidates': [
        for (final issue in candidates.take(7))
          {'id': issue.id, 'text': issue.reports.first.text},
      ],
      'questions': {
        'kind': {
          'type': 'choice',
          'instructions': 'What kind of feedback is this?',
          'criteria': {
            'bug': 'Bug report',
            'feature': 'Feature request',
            'noise': 'Praise, social chatter, or meeting reminder',
            'uncertain': 'Unclear complaint',
          },
        },
        'severity': {
          'type': 'score',
          'instructions':
              'How severe is the product problem described by this feedback?',
          'criteria': [
            'Optional enhancement or cosmetic preference; current functionality works.',
            'Minor inconvenience with an easy workaround.',
            'Important functionality impaired but some work can continue.',
            'A core workflow is blocked for the reporting user.',
            'Explicit data loss, security incident, or widespread total service outage.',
          ],
        },
      },
    };
  }

  Future<void> advance(LayaEvaluator evaluator) async {
    if (complete || busy) return;
    if (attempts >= reports.length * 2) {
      throw const LayaFailure(
        'This run reached its retry limit. Start a new run.',
      );
    }
    busy = true;
    attempts++;
    final timer = Stopwatch()..start();
    try {
      final decision = await evaluator.evaluate(requestForNext());
      final report = reports[processed];
      inputTokens += decision.inputTokens;
      actualModel = decision.model;
      costKnown &= decision.cost != null;
      cost += decision.cost ?? 0;
      String outcome;
      String? issueId;
      final threshold = ['new_issue', 'noise'].contains(decision.choice)
          ? pocTriageThreshold
          : pocMatchThreshold;
      if (decision.confidence < threshold || decision.choice == 'uncertain') {
        outcome = 'review';
      } else if (decision.choice == 'noise') {
        outcome = 'noise';
      } else if (decision.choice == 'new_issue') {
        final issue = PocIssue('POC-${issues.length + 1}', report, decision);
        issues.add(issue);
        issueId = issue.id;
        outcome = 'new';
      } else {
        final issue = issues.where((i) => i.id == decision.choice).firstOrNull;
        if (issue == null) {
          throw const LayaFailure('Laya selected an unknown issue.');
        }
        issue.add(report, decision);
        issueId = issue.id;
        outcome = 'merged';
      }
      decisions.add({
        'reportId': report.id,
        'outcome': outcome,
        'issueId': issueId,
        'choice': decision.choice,
        'confidence': decision.confidence,
        'probabilities': decision.probabilities,
        'severity': decision.severity,
        'severityConfidence': decision.severityConfidence,
        'triage': decision.triage,
        'triageConfidence': decision.triageConfidence,
      });
    } finally {
      latencyMs += timer.elapsedMilliseconds;
      busy = false;
    }
  }

  Map<String, dynamic> get metrics {
    var truePairs = 0;
    var falsePairs = 0;
    var missedPairs = 0;
    final byReport = {for (final d in decisions) d['reportId']: d};
    final labeled = reports
        .take(processed)
        .where((r) => r.expectedIssue != null)
        .toList();
    for (var a = 0; a < labeled.length; a++) {
      for (var b = a + 1; b < labeled.length; b++) {
        final expectedSame =
            labeled[a].expectedIssue == labeled[b].expectedIssue;
        final left = byReport[labeled[a].id]?['issueId'];
        final right = byReport[labeled[b].id]?['issueId'];
        final predictedSame = left != null && left == right;
        if (predictedSame && expectedSame) truePairs++;
        if (predictedSame && !expectedSame) falsePairs++;
        if (!predictedSame && expectedSame) missedPairs++;
      }
    }
    return {
      'precision': truePairs + falsePairs == 0
          ? null
          : truePairs / (truePairs + falsePairs),
      'recall': truePairs + missedPairs == 0
          ? null
          : truePairs / (truePairs + missedPairs),
      'falseMergePairs': falsePairs,
      'missedDuplicatePairs': missedPairs,
      'reviewCount': decisions.where((d) => d['outcome'] == 'review').length,
      'noiseCount': decisions.where((d) => d['outcome'] == 'noise').length,
      'mergedCount': decisions.where((d) => d['outcome'] == 'merged').length,
    };
  }

  Map<String, dynamic> toJson() {
    final sorted = [...issues]..sort((a, b) => b.score.compareTo(a.score));
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'processed': processed,
      'total': reports.length,
      'complete': complete,
      'busy': busy,
      'sources': reports.map((r) => r.source).toSet().toList(),
      'issues': sorted.map((i) => i.toJson()).toList(),
      'decisions': decisions,
      'metrics': metrics,
      'inputTokens': inputTokens,
      'costUsd': costKnown && processed > 0 ? cost : null,
      'latencyMs': latencyMs,
      'actualModel': actualModel,
    };
  }
}
