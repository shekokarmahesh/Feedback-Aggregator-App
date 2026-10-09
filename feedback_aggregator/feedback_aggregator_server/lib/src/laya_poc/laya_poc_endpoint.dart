import 'dart:convert';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../generated/protocol.dart';
import '../workspaces/workspace_service.dart';
import 'laya_client.dart';
import 'poc_run.dart';
import 'sample_feedback.dart';

class LayaPocEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;
  final _workspaces = WorkspaceService();
  // Bounded, workspace-scoped scratch state; intentionally lost on restart.
  final _runs = <int, PocRun>{};

  LayaClient _client(Session session) => LayaClient(
    apiKey: session.serverpod.getPassword('layaApiKey') ?? '',
    endpoint: Uri.parse(
      Platform.environment['LAYA_URL'] ?? 'http://127.0.0.1:8093/v1/systemone',
    ),
  );

  Future<String> _snapshot(Session session, int workspaceId) async {
    final available = await _client(session).isAvailable();
    await _workspaces.requireAccess(session, workspaceId);
    return jsonEncode({
      'available': available,
      'model': layaModel,
      'threshold': pocMatchThreshold,
      'samples': generateSampleFeedback().map((r) => r.toJson()).toList(),
      'run': _runs[workspaceId]?.toJson(),
    });
  }

  Future<String> read(Session session, int workspaceId) async {
    await _workspaces.requireAccess(session, workspaceId);
    return _snapshot(session, workspaceId);
  }

  Future<String> start(
    Session session,
    int workspaceId,
    List<String> sources,
  ) async {
    await _workspaces.requireAccess(session, workspaceId, write: true);
    if (!await _client(session).isAvailable()) {
      throw WorkspaceException(
        message:
            'Start the local Laya model service with sh tools/laya/run.sh, then refresh.',
      );
    }
    if (sources.isEmpty || sources.any((s) => !pocSources.contains(s))) {
      throw WorkspaceException(message: 'Select at least one sample source.');
    }
    if (_runs[workspaceId]?.busy ?? false) {
      throw WorkspaceException(
        message: 'A Laya request is already running. Refresh in a moment.',
      );
    }
    final limiter = DatabaseRateLimiter(
      RateLimiterConfig(
        domain: 'laya-poc',
        source: 'start',
        maxAttempts: 5,
        timeframe: const Duration(hours: 1),
      ),
    );
    if (!await limiter.tryRecordAttempt(
      session,
      key: '$workspaceId:${_workspaces.userId(session)}',
    )) {
      throw WorkspaceException(
        message:
            'POC limit reached: five runs per hour per member and workspace.',
      );
    }
    // Membership may have changed while recording the rate-limit attempt.
    await _workspaces.requireAccess(session, workspaceId, write: true);
    if (_runs[workspaceId]?.busy ?? false) {
      throw WorkspaceException(
        message: 'A Laya request is already running. Refresh in a moment.',
      );
    }
    _runs.removeWhere(
      (_, run) =>
          !run.busy &&
          DateTime.now().toUtc().difference(run.createdAt).inHours >= 24,
    );
    if (_runs.length >= 100 && !_runs.containsKey(workspaceId)) {
      throw WorkspaceException(
        message: 'POC workspace capacity reached. Please try again later.',
      );
    }
    _runs[workspaceId] = PocRun(
      Uuid().v4(),
      generateSampleFeedback()
          .where((r) => sources.contains(r.source))
          .toList(),
    );
    return _snapshot(session, workspaceId);
  }

  Future<String> step(
    Session session,
    int workspaceId,
    String runId,
    int expectedIndex,
  ) async {
    await _workspaces.requireAccess(session, workspaceId, write: true);
    final run = _runs[workspaceId];
    if (run == null || run.id != runId) {
      throw WorkspaceException(
        message:
            'This POC run has expired or been replaced. Refresh and start again.',
      );
    }
    if (expectedIndex < 0 || expectedIndex > run.processed) {
      throw WorkspaceException(message: 'Refresh before continuing this run.');
    }
    if (expectedIndex < run.processed || run.complete || run.busy) {
      return _snapshot(session, workspaceId);
    }
    try {
      await run.advance(_client(session));
    } on LayaFailure catch (e) {
      throw WorkspaceException(message: e.message);
    }
    await _workspaces.requireAccess(session, workspaceId);
    return _snapshot(session, workspaceId);
  }

  Future<String> updateStatus(
    Session session,
    int workspaceId,
    String runId,
    String issueId,
    String status,
  ) async {
    await _workspaces.requireAccess(session, workspaceId, write: true);
    final run = _runs[workspaceId];
    if (run == null || run.id != runId) {
      throw WorkspaceException(message: 'Refresh to load the current POC run.');
    }
    final issue = run.issues.where((i) => i.id == issueId).firstOrNull;
    if (issue == null ||
        !['Open', 'Planned', 'In progress', 'Resolved'].contains(status)) {
      throw WorkspaceException(message: 'Choose a valid issue and status.');
    }
    issue.status = status;
    return _snapshot(session, workspaceId);
  }
}
