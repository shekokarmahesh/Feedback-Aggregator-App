import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../workspaces/workspace_service.dart';
import 'mock_source_feedback.dart';

/// Uses the same tenant lock as member changes and live ticket writes. A source
/// replay cannot overwrite edited tickets or import into another workspace.
class MockSourceService {
  final _workspaces = WorkspaceService();

  List<MockSourceFeedback> _reports(String source) {
    final reports = mockSourceFeedback[source];
    if (reports == null) {
      throw WorkspaceException(message: 'Demo sync supports Email and Slack.');
    }
    return reports;
  }

  Future<T> _write<T>(
    Session session,
    int workspaceId,
    Future<T> Function(Transaction) action, {
    bool admin = false,
  }) => session.db.transaction((tx) async {
    final workspace = await Workspace.db.findById(
      session,
      workspaceId,
      transaction: tx,
      lockMode: LockMode.forUpdate,
    );
    if (workspace == null) {
      throw WorkspaceException(message: 'Workspace access denied.');
    }
    await _workspaces.requireAccess(
      session,
      workspaceId,
      write: true,
      admin: admin,
      transaction: tx,
    );
    return action(tx);
  });

  Future<List<MockSourceConnection>> list(
    Session session,
    int workspaceId,
  ) async {
    await _workspaces.requireAccess(session, workspaceId);
    return MockSourceConnection.db.find(
      session,
      where: (t) => t.workspaceId.equals(workspaceId),
      orderBy: (t) => t.source,
    );
  }

  Future<SourceSyncResult> connect(
    Session session,
    int workspaceId,
    String source,
  ) async {
    final reports = _reports(source);
    return _write(session, workspaceId, (tx) async {
      var connection = await MockSourceConnection.db.findFirstRow(
        session,
        where: (t) =>
            t.workspaceId.equals(workspaceId) & t.source.equals(source),
        transaction: tx,
      );
      if (connection?.connected == true) {
        return SourceSyncResult(connection: connection!, addedCount: 0);
      }
      connection ??= await MockSourceConnection.db.insertRow(
        session,
        MockSourceConnection(workspaceId: workspaceId, source: source),
        transaction: tx,
      );
      connection.connected = true;
      connection.connectedAt = DateTime.now().toUtc();
      return _sync(session, connection, reports, tx, limit: 5);
    }, admin: true);
  }

  Future<SourceSyncResult> sync(
    Session session,
    int workspaceId,
    String source,
  ) async {
    final reports = _reports(source);
    return _write(session, workspaceId, (tx) async {
      final connection = await MockSourceConnection.db.findFirstRow(
        session,
        where: (t) =>
            t.workspaceId.equals(workspaceId) & t.source.equals(source),
        transaction: tx,
      );
      if (connection == null || !connection.connected) {
        throw WorkspaceException(
          message: 'Connect this demo source before syncing.',
        );
      }
      return _sync(session, connection, reports, tx, limit: 3);
    });
  }

  Future<MockSourceConnection> disconnect(
    Session session,
    int workspaceId,
    String source,
  ) async {
    _reports(source);
    return _write(session, workspaceId, (tx) async {
      final connection = await MockSourceConnection.db.findFirstRow(
        session,
        where: (t) =>
            t.workspaceId.equals(workspaceId) & t.source.equals(source),
        transaction: tx,
      );
      if (connection == null) {
        throw WorkspaceException(
          message: 'This source has not been connected.',
        );
      }
      connection.connected = false;
      return MockSourceConnection.db.updateRow(
        session,
        connection,
        transaction: tx,
      );
    }, admin: true);
  }

  Future<SourceSyncResult> _sync(
    Session session,
    MockSourceConnection connection,
    List<MockSourceFeedback> reports,
    Transaction tx, {
    required int limit,
  }) async {
    final existing = await WorkspaceTicket.db.find(
      session,
      where: (t) =>
          t.workspaceId.equals(connection.workspaceId) &
          t.source.equals(connection.source) &
          t.isMock.equals(true) &
          t.externalId.inSet(reports.map((r) => r.externalId).toSet()),
      transaction: tx,
    );
    final delivered = existing.map((t) => t.externalId).toSet();
    final pending = reports
        .where((r) => !delivered.contains(r.externalId))
        .take(limit)
        .toList();
    final now = DateTime.now().toUtc();
    if (pending.isNotEmpty) {
      await WorkspaceTicket.db.insert(
        session,
        [
          for (var index = 0; index < pending.length; index++)
            WorkspaceTicket(
              workspaceId: connection.workspaceId,
              title: pending[index].title,
              description: pending[index].description,
              source: connection.source,
              status: 'Open',
              priority: pending[index].priority,
              supporters: 1,
              requester: pending[index].requester,
              isMock: true,
              externalId: pending[index].externalId,
              createdAt: now.subtract(Duration(minutes: index * 7)),
            ),
        ],
        transaction: tx,
      );
    }
    connection.lastSyncedAt = now;
    connection.syncedCount = delivered.length + pending.length;
    connection.availableCount = reports.length;
    return SourceSyncResult(
      connection: await MockSourceConnection.db.updateRow(
        session,
        connection,
        transaction: tx,
      ),
      addedCount: pending.length,
    );
  }
}
