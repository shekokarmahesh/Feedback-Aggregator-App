import 'package:flutter/material.dart';
import 'package:feedback_aggregator_client/feedback_aggregator_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedback_aggregator_flutter/models/demo_ticket.dart';
import 'package:feedback_aggregator_flutter/screens/dashboard_screen.dart';

void main() {
  test('combines search, status, source, and priority filters', () {
    final tickets = filterTickets(
      query: 'duplicate',
      status: 'Open',
      source: 'Forms',
      priority: 'High',
    );
    expect(tickets.map((t) => t.id), ['FB-1040']);
    expect(filterTickets(query: 'dark mode', status: 'Resolved'), isEmpty);
  });
  test('sorts feedback by demand, recency, and priority', () {
    expect(filterTickets().first.supporters, 28);
    expect(filterTickets(sort: 'Most recent').first.hoursAgo, 2);
    expect(filterTickets(sort: 'Priority').first.priority, 'High');
    expect(filterTickets(query: 'PRIYA').single.id, 'FB-1041');
  });
  Future<void> showDashboard(
    WidgetTester tester, {
    VoidCallback? signedOut,
    WorkspaceSummary? workspace,
    List<DemoTicket> tickets = demoTickets,
    VoidCallback? onCreateTicket,
    Future<void> Function(DemoTicket, String)? onUpdateStatus,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardScreen(
            workspace: workspace,
            tickets: tickets,
            onCreateTicket: onCreateTicket,
            onUpdateStatus: onUpdateStatus,
            onSignOut: () async {
              signedOut?.call();
            },
            loadProfile: () async => const AccountProfile(
              name: 'Mahesh Test',
              email: 'mahesh@example.com',
              id: 'test-account',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('search empty state can be reset and ticket details open', (
    tester,
  ) async {
    await showDashboard(tester);
    await tester.enterText(find.byType(TextField), 'no-such-ticket');
    await tester.pumpAndSettle();
    expect(find.text('No feedback matches'), findsOneWidget);
    await tester.ensureVisible(find.text('Reset filters'));
    await tester.tap(find.text('Reset filters'));
    await tester.pumpAndSettle();
    expect(find.text('Add dark mode to the dashboard'), findsOneWidget);
    await tester.ensureVisible(find.text('Add dark mode to the dashboard'));
    await tester.tap(find.text('Add dark mode to the dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('What customers are saying'), findsOneWidget);
    expect(find.text('28 customer requests'), findsOneWidget);
  });
  testWidgets(
    'profile displays account data and sign-out invokes auth callback',
    (tester) async {
      var signedOut = false;
      await showDashboard(tester, signedOut: () => signedOut = true);
      await tester.tap(find.byTooltip('Account menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View profile'));
      await tester.pumpAndSettle();
      expect(find.text('mahesh@example.com'), findsOneWidget);
      expect(find.text('test-account'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Account menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(signedOut, isTrue);
    },
  );
  testWidgets('dashboard fits a narrow screen and navigation works', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await showDashboard(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Sources').first);
    await tester.pumpAndSettle();
    expect(find.text('Feedback sources'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('workspace inbox does not show global sample data', (
    tester,
  ) async {
    await showDashboard(
      tester,
      workspace: WorkspaceSummary(
        id: 1,
        name: 'Alpha',
        role: WorkspaceRole.viewer,
      ),
      tickets: [],
    );
    expect(find.text('ALPHA'), findsOneWidget);
    expect(find.text('No feedback yet'), findsOneWidget);
    expect(find.text('Add dark mode to the dashboard'), findsNothing);
    expect(find.text('Sample data'), findsNothing);
    expect(find.text('Add feedback'), findsNothing);
  });

  testWidgets(
    'Editor controls create and update only the active workspace ticket',
    (tester) async {
      var created = false;
      String? updated;
      const ticket = DemoTicket(
        'FB-1',
        'Tenant feedback',
        'Private detail',
        'Forms',
        'Open',
        'High',
        1,
        0,
        'Test',
      );
      await showDashboard(
        tester,
        workspace: WorkspaceSummary(
          id: 1,
          name: 'Alpha',
          role: WorkspaceRole.editor,
        ),
        tickets: [ticket],
        onCreateTicket: () => created = true,
        onUpdateStatus: (row, status) async {
          expect(row.id, 'FB-1');
          updated = status;
        },
      );
      await tester.tap(find.text('Add feedback'));
      expect(created, isTrue);
      await tester.ensureVisible(find.text('Tenant feedback'));
      await tester.tap(find.text('Tenant feedback'));
      await tester.pumpAndSettle();
      expect(find.text('Update status'), findsOneWidget);
      await tester.ensureVisible(
        find.widgetWithText(OutlinedButton, 'Planned'),
      );
      await tester.tap(find.widgetWithText(OutlinedButton, 'Planned'));
      await tester.pumpAndSettle();
      expect(updated, 'Planned');
      expect(tester.takeException(), isNull);
    },
  );
}
