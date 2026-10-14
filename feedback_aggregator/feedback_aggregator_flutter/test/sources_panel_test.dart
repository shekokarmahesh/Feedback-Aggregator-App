import 'dart:async';

import 'package:feedback_aggregator_client/feedback_aggregator_client.dart';
import 'package:feedback_aggregator_flutter/models/demo_ticket.dart';
import 'package:feedback_aggregator_flutter/screens/dashboard_screen.dart';
import 'package:feedback_aggregator_flutter/screens/sources_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

WorkspaceSummary workspace(WorkspaceRole role) =>
    WorkspaceSummary(id: 1, name: 'Alpha', role: role);
MockSourceConnection connection({bool connected = true, int count = 5}) =>
    MockSourceConnection(
      workspaceId: 1,
      source: 'Email',
      connected: connected,
      syncedCount: count,
      availableCount: 12,
      lastSyncedAt: DateTime.now().toUtc(),
    );

Future<void> showPanel(
  WidgetTester tester, {
  WorkspaceRole role = WorkspaceRole.admin,
  List<MockSourceConnection> connections = const [],
  Set<String> syncing = const {},
  Future<SourceSyncResult> Function(String)? onConnect,
  Future<SourceSyncResult> Function(String, String)? onConfigure,
  Future<SourceSyncResult> Function(String)? onSync,
  Future<void> Function(String)? onDisconnect,
}) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: SourcesPanel(
          workspace: workspace(role),
          connections: connections,
          syncing: syncing,
          onConnect: onConnect,
          onConfigure: onConfigure,
          onSync: onSync,
          onDisconnect: onDisconnect,
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets(
    'configuration fits a narrow screen and prevents duplicate submission',
    (tester) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final response = Completer<SourceSyncResult>();
      var calls = 0;
      await showPanel(
        tester,
        onConfigure: (_, _) {
          calls++;
          return response.future;
        },
      );
      await tester.ensureVisible(find.byKey(const ValueKey('connect-Forms')));
      await tester.tap(find.byKey(const ValueKey('connect-Forms')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('webhook-key')),
      );
      await tester.enterText(
        find.byKey(const ValueKey('webhook-key')),
        'demo',
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('submit-source-configuration')),
      );
      await tester.tap(
        find.byKey(const ValueKey('submit-source-configuration')),
      );
      await tester.pump();
      expect(calls, 1);
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey('submit-source-configuration')),
            )
            .onPressed,
        isNull,
      );
      expect(tester.takeException(), isNull);
      response.complete(
        SourceSyncResult(
          connection: MockSourceConnection(
            workspaceId: 1,
            source: 'Forms',
            connected: true,
            syncedCount: 5,
            availableCount: 8,
          ),
          addedCount: 5,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
  for (final source in ['Forms', 'Support', 'App reviews']) {
    testWidgets(
      '$source configuration previews webhook steps and imports with any demo key',
      (tester) async {
        final calls = <String>[];
        await showPanel(
          tester,
          onConfigure: (name, key) async {
            calls.add('$name:$key');
            return SourceSyncResult(
              connection: MockSourceConnection(
                workspaceId: 1,
                source: name,
                connected: true,
                syncedCount: 5,
                availableCount: sourceFeedCounts[name]!,
              ),
              addedCount: 5,
            );
          },
        );
        await tester.ensureVisible(find.byKey(ValueKey('connect-$source')));
        await tester.tap(find.byKey(ValueKey('connect-$source')));
        await tester.pumpAndSettle();
        expect(find.text('Configure $source'), findsWidgets);
        expect(find.textContaining('/webhooks/feedback'), findsOneWidget);
        expect(find.textContaining('X-Feedback-Webhook-Key:'), findsOneWidget);
        await tester.ensureVisible(
          find.byKey(const ValueKey('submit-source-configuration')),
        );
        await tester.tap(
          find.byKey(const ValueKey('submit-source-configuration')),
        );
        await tester.pumpAndSettle();
        expect(calls, isEmpty);
        expect(find.text('Enter a webhook key to connect.'), findsOneWidget);
        await tester.enterText(
          find.byKey(const ValueKey('webhook-key')),
          'mock',
        );
        await tester.tap(
          find.byKey(const ValueKey('submit-source-configuration')),
        );
        await tester.pumpAndSettle();
        expect(calls, ['$source:mock']);
        expect(find.byKey(const ValueKey('webhook-key')), findsNothing);
        expect(
          find.text('5 reports from $source added to your inbox.'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'configuration errors retain the demo key for retry and cancel writes nothing',
    (tester) async {
      var attempts = 0;
      await showPanel(
        tester,
        onConfigure: (source, key) async {
          attempts++;
          throw WorkspaceException(
            message: 'Configuration unavailable. Try again.',
          );
        },
      );
      await tester.ensureVisible(find.byKey(const ValueKey('connect-Forms')));
      await tester.tap(find.byKey(const ValueKey('connect-Forms')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('webhook-key')),
        'demo',
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('submit-source-configuration')),
      );
      await tester.tap(
        find.byKey(const ValueKey('submit-source-configuration')),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Configuration unavailable. Try again.'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<TextFormField>(
              find.byKey(const ValueKey('webhook-key')),
            )
            .controller!
            .text,
        'demo',
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(attempts, 1);
      expect(find.byKey(const ValueKey('connect-Forms')), findsOneWidget);
    },
  );

  testWidgets(
    'Connect populates the inbox, retains Sources tab, and labels demo tickets',
    (tester) async {
      final connections = <MockSourceConnection>[];
      final tickets = <DemoTicket>[];
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return DashboardScreen(
                  workspace: workspace(WorkspaceRole.admin),
                  tickets: tickets,
                  sourceConnections: connections,
                  onSignOut: () async {},
                  loadProfile: () async => const AccountProfile(
                    name: 'Test',
                    email: 'test@example.com',
                    id: 'test',
                  ),
                  onConnectSource: (source) async {
                    expect(source, 'Email');
                    final row = connection();
                    update(() {
                      connections.add(row);
                      tickets.addAll([
                        for (var i = 1; i <= 5; i++)
                          DemoTicket(
                            'FB-$i',
                            'Sample email report $i',
                            'Sample support email',
                            'Email',
                            'Open',
                            'High',
                            1,
                            0,
                            'Maya',
                            isMock: true,
                          ),
                      ]);
                    });
                    return SourceSyncResult(connection: row, addedCount: 5);
                  },
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Manage sources'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('connect-Email')));
      await tester.tap(find.byKey(const ValueKey('connect-Email')));
      await tester.pumpAndSettle();
      expect(find.text('Feedback sources'), findsOneWidget);
      expect(find.text('Connected'), findsOneWidget);
      expect(find.text('5 of 12 reports imported'), findsOneWidget);
      expect(find.text('5 feedback reports imported'), findsOneWidget);
      await tester.ensureVisible(find.text('Inbox').first);
      await tester.tap(find.text('Inbox').first);
      await tester.pumpAndSettle();
      expect(find.text('Sample email report 1'), findsOneWidget);
      expect(find.text('Demo'), findsNothing);
      await tester.ensureVisible(find.text('Sample email report 1'));
      await tester.tap(find.text('Sample email report 1'));
      await tester.pumpAndSettle();
      expect(find.text('Workspace ticket'), findsOneWidget);
      expect(find.textContaining('Generated demo feedback'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('failed connection shows an error and can be retried', (
    tester,
  ) async {
    var attempts = 0;
    await showPanel(
      tester,
      onConnect: (source) async {
        if (++attempts == 1) {
          throw WorkspaceException(
            message: 'Connection unavailable. Try again.',
          );
        }
        return SourceSyncResult(connection: connection(), addedCount: 5);
      },
    );
    await tester.ensureVisible(find.byKey(const ValueKey('connect-Email')));
    await tester.tap(find.byKey(const ValueKey('connect-Email')));
    await tester.pumpAndSettle();
    expect(find.text('Connection unavailable. Try again.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('connect-Email')));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.text('Connection unavailable. Try again.'), findsNothing);
    expect(
      find.text('5 reports from Email added to your inbox.'),
      findsOneWidget,
    );
  });

  testWidgets('pending connection cannot be clicked twice', (tester) async {
    final response = Completer<SourceSyncResult>();
    var calls = 0;
    await showPanel(
      tester,
      onConnect: (_) {
        calls++;
        return response.future;
      },
    );
    await tester.ensureVisible(find.byKey(const ValueKey('connect-Email')));
    await tester.tap(find.byKey(const ValueKey('connect-Email')));
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('connect-Email')))
          .onPressed,
      isNull,
    );
    expect(find.text('Syncing…'), findsOneWidget);
    expect(calls, 1);
    response.complete(
      SourceSyncResult(connection: connection(), addedCount: 5),
    );
    await tester.pumpAndSettle();
  });

  testWidgets(
    'Editor can sync but cannot connect or disconnect; Viewer only reads',
    (tester) async {
      Future<SourceSyncResult> action(String _) async =>
          SourceSyncResult(connection: connection(count: 12), addedCount: 0);
      var calls = 0;
      await showPanel(
        tester,
        role: WorkspaceRole.editor,
        connections: [connection()],
        onConnect: action,
        onSync: (_) async {
          calls++;
          return action('Email');
        },
        onDisconnect: (_) async {},
      );
      expect(find.byKey(const ValueKey('connect-Slack')), findsNothing);
      expect(find.byKey(const ValueKey('disconnect-Email')), findsNothing);
      await tester.ensureVisible(find.byKey(const ValueKey('sync-Email')));
      await tester.tap(find.byKey(const ValueKey('sync-Email')));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(
        find.text(
          'Email is up to date. Related reports are grouped automatically.',
        ),
        findsOneWidget,
      );
      await showPanel(
        tester,
        role: WorkspaceRole.viewer,
        connections: [connection()],
        onConnect: action,
        onSync: action,
        onDisconnect: (_) async {},
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('sync-Email')), findsNothing);
      expect(find.byKey(const ValueKey('connect-Slack')), findsNothing);
      expect(find.byKey(const ValueKey('disconnect-Email')), findsNothing);
      expect(
        find.text('View-only access. An Admin or Editor can sync feedback.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'disconnect clears source counters and offers Connect again',
    (tester) async {
      var row = connection();
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) {
                  update = setState;
                  return SourcesPanel(
                    workspace: workspace(WorkspaceRole.admin),
                    connections: [row],
                    tickets: const [
                      DemoTicket(
                        'FB-1',
                        'Saved demo',
                        'Email evidence',
                        'Email',
                        'Planned',
                        'High',
                        1,
                        0,
                        'Maya',
                        isMock: true,
                      ),
                    ],
                    onConnect: (_) async =>
                        SourceSyncResult(connection: row, addedCount: 0),
                    onDisconnect: (_) async =>
                        update(() => row = connection(connected: false)),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('disconnect-Email')),
      );
      await tester.tap(find.byKey(const ValueKey('disconnect-Email')));
      await tester.pumpAndSettle();
      expect(find.text('1 feedback reports imported'), findsNothing);
      expect(find.text('5 of 12 reports imported'), findsNothing);
      expect(find.byKey(const ValueKey('connect-Email')), findsOneWidget);
      expect(
        find.textContaining(
          'Tickets from this source stay hidden while disconnected.',
        ),
        findsNWidgets(5),
      );
    },
  );

  testWidgets(
    'connected and pending source controls fit a 320-pixel viewport',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await showPanel(
        tester,
        connections: [connection(count: 12)],
        syncing: {'Email'},
        onConnect: (_) async =>
            SourceSyncResult(connection: connection(), addedCount: 5),
        onSync: (_) async =>
            SourceSyncResult(connection: connection(), addedCount: 0),
        onDisconnect: (_) async {},
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(
        tester
            .widget<OutlinedButton>(find.byKey(const ValueKey('sync-Email')))
            .onPressed,
        isNull,
      );
      await tester.ensureVisible(find.byKey(const ValueKey('connect-Slack')));
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
}
