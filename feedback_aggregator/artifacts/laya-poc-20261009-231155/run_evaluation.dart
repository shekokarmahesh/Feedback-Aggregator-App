import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'source/laya_client.dart';
import 'source/poc_run.dart';
import 'source/sample_feedback.dart';

// Reuses the unmodified production POC engine; gold labels remain evaluation-only.
Future<void> main() async {
  final output = File.fromUri(Platform.script).parent;
  final client = LayaClient();
  if (!await client.isAvailable()) throw StateError('Start local Laya first.');
  for (final scenario in [('ordered-2', null), ('shuffled-7', 7), ('shuffled-42', 42)]) {
    final reports = generateSampleFeedback();
    if (scenario.$2 != null) reports.shuffle(Random(scenario.$2));
    final run = PocRun(scenario.$1, reports);
    while (!run.complete) {
      await run.advance(client);
      stdout.writeln('${scenario.$1} ${run.processed}/34');
    }
    final result = {
      'recordedAt': DateTime.now().toUtc().toIso8601String(),
      'seed': scenario.$2,
      'threshold': pocMatchThreshold,
      'triageThreshold': pocTriageThreshold,
      'newIssueDuplicateCeiling': pocNewIssueCeiling,
      'fixture': '34 synthetic English reports; fixed development fixture',
      'reports': reports.map((r) => {...r.toJson(), 'expectedIssue': r.expectedIssue}).toList(),
      'run': run.toJson(),
    };
    await File('${output.path}/${scenario.$1}.json').writeAsString(const JsonEncoder.withIndent('  ').convert(result));
    stdout.writeln('${scenario.$1}: ${jsonEncode(run.metrics)}; ${run.latencyMs}ms');
  }
}
