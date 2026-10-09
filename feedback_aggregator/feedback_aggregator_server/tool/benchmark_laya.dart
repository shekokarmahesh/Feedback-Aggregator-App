import 'dart:convert';
import 'dart:io';
import 'package:feedback_aggregator_server/src/laya_poc/laya_client.dart';
import 'package:feedback_aggregator_server/src/laya_poc/poc_run.dart';
import 'package:feedback_aggregator_server/src/laya_poc/sample_feedback.dart';

/// Exercises the same engine as the UI without starting Serverpod or touching DB.
Future<void> main(List<String> args) async {
  final client = LayaClient(
    endpoint: Uri.parse(
      Platform.environment['LAYA_URL'] ?? 'http://127.0.0.1:8093/v1/systemone',
    ),
    apiKey: Platform.environment['SERVERPOD_PASSWORD_layaApiKey'] ?? '',
  );
  if (!await client.isAvailable()) {
    stderr.writeln('Local Laya is offline. Run sh tools/laya/run.sh first.');
    exitCode = 1;
    return;
  }
  final run = PocRun(
    'benchmark-${DateTime.now().millisecondsSinceEpoch}',
    generateSampleFeedback(),
  );
  while (!run.complete) {
    try {
      await run.advance(client);
      final result = run.decisions.last;
      stdout.writeln(
        '${run.processed}/${run.reports.length}: ${result['reportId']} → '
        '${result['choice']} (${(result['confidence'] as double).toStringAsFixed(3)}) ${result['outcome']}',
      );
    } on LayaFailure catch (error) {
      stderr.writeln(error.message);
      exitCode = 1;
      break;
    }
  }
  final result = {
    'recordedAt': DateTime.now().toUtc().toIso8601String(),
    'threshold': pocMatchThreshold,
    'fixture':
        '34 English synthetic reports; development fixture, not a holdout',
    'run': run.toJson(),
  };
  stdout.writeln(jsonEncode(run.metrics));
  stdout.writeln(
    'Issues: ${run.issues.length}; inference time: ${run.latencyMs} ms',
  );
  if (args.isNotEmpty) {
    final output = File(args.first);
    await output.parent.create(recursive: true);
    await output.writeAsString(
      const JsonEncoder.withIndent('  ').convert(result),
    );
  }
}
