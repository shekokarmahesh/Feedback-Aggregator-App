import 'package:feedback_aggregator_client/feedback_aggregator_client.dart';
import 'package:feedback_aggregator_flutter/models/demo_ticket.dart';
import 'package:feedback_aggregator_flutter/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

GroupedTicket issue({String state = 'complete'}) {
  final reports = [
    for (final source in ['Email', 'Slack', 'Forms'])
      WorkspaceTicket(
        id: ['Email', 'Slack', 'Forms'].indexOf(source) + 1,
        workspaceId: 1,
        title: 'Empty CSV reported on $source',
        description:
            '$source report: exporting filtered feedback produces an empty CSV.',
        source: source,
        status: 'Open',
        priority: 'High',
        supporters: 1,
        requester: 'Reporter on $source',
        issueGroupId: 5,
        groupingState: state,
        groupingConfidence: .86,
        severity: 3,
      ),
  ];
  return GroupedTicket(
    id: 5,
    primaryTicketId: 1,
    title: reports.first.title,
    description: reports.first.description,
    status: 'Open',
    priority: 'High',
    priorityScore: 52,
    sources: ['Email', 'Slack', 'Forms'],
    reports: reports,
    groupingState: state,
    confidence: .86,
    createdAt: DateTime.now(),
  );
}

Future<void> showInbox(
  WidgetTester tester,
  DemoTicket ticket, {
  Future<void> Function()? retry,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: DashboardScreen(
          workspace: WorkspaceSummary(
            id: 1,
            name: 'Alpha',
            role: WorkspaceRole.admin,
          ),
          tickets: [ticket],
          onRetryGrouping: retry,
          onSignOut: () async {},
          loadProfile: () async => const AccountProfile(
            name: 'Test',
            email: 'test@example.com',
            id: '1',
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'one inbox issue contains original reports and has no POC or demo labels',
    (tester) async {
      final ticket = DemoTicket.fromGroup(issue(), {})!;
      await showInbox(tester, ticket);
      expect(find.text('Laya POC'), findsNothing);
      expect(find.text('Demo'), findsNothing);
      expect(find.text('Grouped by Laya'), findsOneWidget);
      await tester.ensureVisible(find.text(ticket.title));
      await tester.tap(find.text(ticket.title));
      await tester.pumpAndSettle();
      expect(find.text('Original reports'), findsOneWidget);
      expect(find.text('3 reports across 3 platforms'), findsOneWidget);
      for (final source in ['Email', 'Slack', 'Forms']) {
        expect(
          find.text(
            '$source report: exporting filtered feedback produces an empty CSV.',
          ),
          findsWidgets,
        );
      }
      expect(find.text('86%'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  test(
    'disconnect removes its evidence, lowers score, and keeps remaining platforms',
    () {
      final before = DemoTicket.fromGroup(issue(), {})!;
      final after = DemoTicket.fromGroup(issue(), {'Email'})!;
      expect(after.id, before.id);
      expect(after.supporters, 2);
      expect(after.sources, isNot(contains('Email')));
      expect(after.description, isNot(contains('Email')));
      expect(after.priorityScore, lessThan(before.priorityScore));
      expect(filterTickets(tickets: [after], source: 'Email'), isEmpty);
      expect(filterTickets(tickets: [after], source: 'Slack'), hasLength(1));
      expect(
        DemoTicket.fromGroup(issue(), {'Email', 'Slack', 'Forms'}),
        isNull,
      );
    },
  );
  testWidgets(
    'failed grouping retains feedback and exposes retry in the ordinary inbox',
    (tester) async {
      var calls = 0;
      await showInbox(
        tester,
        DemoTicket.fromGroup(issue(state: 'retrying'), {})!,
        retry: () async {
          calls++;
        },
      );
      expect(find.text('Waiting for grouping'), findsOneWidget);
      expect(find.text('Grouped by Laya'), findsNothing);
      await tester.tap(find.text('Retry grouping'));
      await tester.pumpAndSettle();
      expect(calls, 1);
    },
  );
  testWidgets('grouped evidence and multiple platforms fit a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final ticket = DemoTicket.fromGroup(issue(), {})!;
    await showInbox(tester, ticket);
    await tester.ensureVisible(find.text(ticket.title));
    await tester.tap(find.text(ticket.title));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
