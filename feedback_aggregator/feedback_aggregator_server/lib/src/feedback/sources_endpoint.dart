import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'mock_source_service.dart';
import 'grouping_service.dart';

class SourcesEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  final _service = MockSourceService();

  Future<List<MockSourceConnection>> list(Session session, int workspaceId) =>
      _service.list(session, workspaceId);
  Future<SourceSyncResult> connect(
    Session session,
    int workspaceId,
    String source,
  ) async {
    final result = await _service.connect(session, workspaceId, source);
    await GroupingService().enqueue(session, workspaceId);
    return result;
  }

  Future<SourceSyncResult> configure(
    Session session,
    int workspaceId,
    String source,
    String webhookKey,
  ) async {
    if (!['Forms', 'Support', 'App reviews'].contains(source)) {
      throw WorkspaceException(
        message: 'Configure Forms, Support, or App reviews.',
      );
    }
    final result = await _service.connect(
      session,
      workspaceId,
      source,
      webhookKey: webhookKey,
    );
    await GroupingService().enqueue(session, workspaceId);
    return result;
  }

  Future<SourceSyncResult> sync(
    Session session,
    int workspaceId,
    String source,
  ) async {
    final result = await _service.sync(session, workspaceId, source);
    await GroupingService().enqueue(session, workspaceId);
    return result;
  }

  Future<MockSourceConnection> disconnect(
    Session session,
    int workspaceId,
    String source,
  ) => _service.disconnect(session, workspaceId, source);
}
