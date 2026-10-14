import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'mock_source_service.dart';

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
  ) => _service.connect(session, workspaceId, source);
  Future<SourceSyncResult> configure(
    Session session,
    int workspaceId,
    String source,
    String demoKey,
  ) async {
    if (!['Forms', 'Support', 'App reviews'].contains(source)) {
      throw WorkspaceException(
        message: 'Configure Forms, Support, or App reviews.',
      );
    }
    return _service.connect(session, workspaceId, source, demoKey: demoKey);
  }

  Future<SourceSyncResult> sync(
    Session session,
    int workspaceId,
    String source,
  ) => _service.sync(session, workspaceId, source);
  Future<MockSourceConnection> disconnect(
    Session session,
    int workspaceId,
    String source,
  ) => _service.disconnect(session, workspaceId, source);
}
