import 'dart:async';
import 'dart:math';

import 'package:feedback_aggregator_client/feedback_aggregator_client.dart';
import 'package:feedback_aggregator_flutter/screens/workspace_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A controllable RPC boundary for timing/tenant races; persistence and roles
/// are exercised against PostgreSQL in the server integration tests.
class _Store {
  final workspaces = [
    WorkspaceSummary(id: 1, name: 'Alpha', role: WorkspaceRole.admin),
    WorkspaceSummary(id: 2, name: 'Beta', role: WorkspaceRole.admin),
  ];
  final tickets = <int, List<WorkspaceTicket>>{1: [], 2: []};
  final connections = <int, List<MockSourceConnection>>{1: [], 2: []};
  final syncCalls = <int>[];
  bool failNextSync = false;
  int? holdWorkspace;
  Completer<List<WorkspaceTicket>>? heldTickets;

  _Store() {
    add(1, 5);
  }

  int add(int workspaceId, int number) {
    final rows = tickets[workspaceId]!;
    final before = rows.length;
    final count = min(12 - before, number);
    rows.addAll([
      for (var i = before; i < before + count; i++)
        WorkspaceTicket(
          id: workspaceId * 100 + i,
          workspaceId: workspaceId,
          title: 'Alpha email report $i',
          description: 'Sample message',
          source: 'Email',
          status: 'Open',
          priority: 'High',
          supporters: 1,
          requester: 'Maya',
          isMock: true,
          externalId: 'email-$i',
        ),
    ]);
    connections[workspaceId] = [
      MockSourceConnection(
        workspaceId: workspaceId,
        source: 'Email',
        connected: true,
        syncedCount: rows.length,
        availableCount: 12,
        lastSyncedAt: DateTime.now().toUtc(),
      ),
    ];
    return count;
  }
}

class _WorkspaceApi implements EndpointWorkspace {
  final _Store store;
  _WorkspaceApi(this.store);
  @override
  Future<List<WorkspaceSummary>> list() async => List.of(store.workspaces);
  @override
  Future<List<WorkspaceTicket>> tickets(int workspaceId) async =>
      store.holdWorkspace == workspaceId
      ? store.heldTickets!.future
      : List.of(store.tickets[workspaceId]!);
  @override
  Future<List<GroupedTicket>> issues(int workspaceId) async {
    final rows = await tickets(workspaceId);
    return [
      for (final row in rows)
        GroupedTicket(
          id: -row.id!,
          primaryTicketId: row.id!,
          title: row.title,
          description: row.description,
          status: row.status,
          priority: row.priority,
          priorityScore: 0,
          sources: [row.source],
          reports: [row],
          groupingState: 'pending',
          createdAt: row.createdAt,
        ),
    ];
  }

  @override
  Future<String?> discordGuild(int workspaceId) async => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SourcesApi implements EndpointSources {
  final _Store store;
  _SourcesApi(this.store);
  @override
  Future<List<MockSourceConnection>> list(int workspaceId) async =>
      List.of(store.connections[workspaceId]!);
  @override
  Future<MockSourceConnection> disconnect(
    int workspaceId,
    String source,
  ) async {
    final connection = store.connections[workspaceId]!.single.copyWith(
      connected: false,
      syncedCount: 0,
      lastSyncedAt: null,
    );
    store.connections[workspaceId] = [connection];
    return connection;
  }

  @override
  Future<SourceSyncResult> connect(int workspaceId, String source) async {
    final count = store.add(workspaceId, 5);
    return SourceSyncResult(
      connection: store.connections[workspaceId]!.single,
      addedCount: count,
    );
  }

  @override
  Future<SourceSyncResult> sync(int workspaceId, String source) async {
    store.syncCalls.add(workspaceId);
    if (store.failNextSync) {
      store.failNextSync = false;
      throw WorkspaceException(message: 'Source unavailable. Try again.');
    }
    final count = store.add(workspaceId, 3);
    return SourceSyncResult(
      connection: store.connections[workspaceId]!.single,
      addedCount: count,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Client implements Client {
  @override
  final _WorkspaceApi workspace;
  @override
  final _SourcesApi sources;
  _Client(_Store store)
    : workspace = _WorkspaceApi(store),
      sources = _SourcesApi(store);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _showShell(WidgetTester tester, _Store store) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: WorkspaceShell(apiClient: _Client(store))),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'disconnect hides cached rows across a stale refresh, reload, and reconnect',
    (tester) async {
      final store = _Store()..add(1, 7);
      await _showShell(tester, store);
      await tester.tap(find.text('Sources').first);
      await tester.pumpAndSettle();
      store.holdWorkspace = 1;
      store.heldTickets = Completer<List<WorkspaceTicket>>();
      await tester.pump(const Duration(seconds: 30));
      await tester.pump();
      await tester.ensureVisible(
        find.byKey(const ValueKey('disconnect-Email')),
      );
      await tester.tap(find.byKey(const ValueKey('disconnect-Email')));
      await tester.pump();
      store.heldTickets!.complete(List.of(store.tickets[1]!));
      store.holdWorkspace = null;
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('connect-Email')), findsOneWidget);
      expect(find.text('12 of 12 reports imported'), findsNothing);
      await tester.tap(find.text('Inbox').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('Alpha email report'), findsNothing);
      expect(find.text('No feedback yet'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await _showShell(tester, store);
      expect(find.textContaining('Alpha email report'), findsNothing);
      expect(find.text('No feedback yet'), findsOneWidget);
      await tester.tap(find.text('Sources').first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('connect-Email')));
      await tester.tap(find.byKey(const ValueKey('connect-Email')));
      await tester.pumpAndSettle();
      expect(find.text('12 of 12 reports imported'), findsOneWidget);
      await tester.tap(find.text('Inbox').first);
      await tester.pumpAndSettle();
      expect(find.text('Alpha email report 0'), findsOneWidget);
      expect(store.tickets[1], hasLength(12));
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'automatic delta sync updates Sources without resetting the inbox search or tab',
    (tester) async {
      final store = _Store();
      await _showShell(tester, store);
      await tester.enterText(find.byType(TextField), 'Alpha email');
      await tester.tap(find.text('Sources').first);
      await tester.pumpAndSettle();
      for (final count in [8, 11, 12]) {
        await tester.pump(const Duration(seconds: 30));
        await tester.pumpAndSettle();
        expect(find.text('Feedback sources'), findsOneWidget);
        expect(
          find.text('$count of 12 reports imported'),
          findsOneWidget,
        );
      }
      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();
      expect(store.syncCalls, [1, 1, 1]);
      expect(
        find.text('Up to date. All reports are in your inbox.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Inbox').first);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Alpha email',
      );
      expect(find.text('Alpha email report 11'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('a refreshed Viewer role stops automatic writes', (tester) async {
    final store = _Store();
    await _showShell(tester, store);
    store.workspaces[0] = WorkspaceSummary(
      id: 1,
      name: 'Alpha',
      role: WorkspaceRole.viewer,
    );
    await tester.pump(const Duration(seconds: 30));
    await tester.pumpAndSettle();
    expect(store.syncCalls, isEmpty);
    expect(store.tickets[1], hasLength(5));
    expect(find.text('Viewer'), findsOneWidget);
    await tester.tap(find.text('Sources').first);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('sync-Email')), findsNothing);
    expect(find.byKey(const ValueKey('connect-Slack')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'automatic sync recovers on the next tick after a provider failure',
    (tester) async {
      final store = _Store()..failNextSync = true;
      await _showShell(tester, store);
      await tester.tap(find.text('Sources').first);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();
      expect(find.text('Source unavailable. Try again.'), findsOneWidget);
      expect(store.tickets[1], hasLength(5));
      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();
      expect(find.text('Source unavailable. Try again.'), findsNothing);
      expect(find.text('8 of 12 reports imported'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'an old refresh cannot display Alpha tickets after switching to Beta',
    (tester) async {
      final store = _Store();
      store.add(1, 7); // Completed source: this tick only refreshes tickets.
      await _showShell(tester, store);
      store.holdWorkspace = 1;
      store.heldTickets = Completer<List<WorkspaceTicket>>();
      await tester.pump(const Duration(seconds: 30));
      await tester.pump();
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Beta').last);
      await tester.pumpAndSettle();
      expect(find.text('BETA'), findsOneWidget);
      store.heldTickets!.complete(List.of(store.tickets[1]!));
      await tester.pumpAndSettle();
      expect(find.text('BETA'), findsOneWidget);
      expect(find.textContaining('Alpha email report'), findsNothing);
      expect(find.text('No feedback yet'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
