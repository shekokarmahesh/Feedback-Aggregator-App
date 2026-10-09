import 'package:feedback_aggregator_client/feedback_aggregator_client.dart';
import 'package:feedback_aggregator_flutter/screens/laya_poc_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> snapshot({
  bool available = true,
  Map<String, dynamic>? run,
}) => {
  'available': available,
  'model': 'english',
  'threshold': .80,
  'samples': [
    {
      'id': 'a',
      'source': 'Slack',
      'reporterId': 'person-1',
      'title': 'Reset email missing',
      'text': 'The reset email never arrives.',
      'hoursAgo': 2,
    },
    {
      'id': 'b',
      'source': 'Email',
      'reporterId': 'person-2',
      'title': 'No reset code',
      'text': 'My password recovery code has not arrived.',
      'hoursAgo': 3,
    },
  ],
  'run': run,
};

Map<String, dynamic> result({bool complete = true}) => {
  'id': 'run-1',
  'processed': complete ? 2 : 0,
  'total': 2,
  'complete': complete,
  'busy': false,
  'metrics': {
    'precision': 1.0,
    'recall': 1.0,
    'falseMergePairs': 0,
    'reviewCount': 0,
    'mergedCount': 1,
  },
  'issues': complete
      ? [
          {
            'id': 'POC-1',
            'title': 'Reset email missing',
            'description': 'The reset email never arrives.',
            'reportIds': ['a', 'b'],
            'reportCount': 2,
            'uniqueReporters': 2,
            'sources': ['Slack', 'Email'],
            'confidence': .98,
            'severity': 3.0,
            'severityNeedsReview': false,
            'score': 48,
            'scoreBreakdown': {'severity': 30},
            'status': 'Open',
          },
        ]
      : [],
  'decisions': [],
  'inputTokens': 900,
  'costUsd': 0.0,
  'latencyMs': 400,
  'actualModel': 'Laya / english',
};

Future<void> showPanel(
  WidgetTester tester,
  PocRequest request, {
  WorkspaceRole role = WorkspaceRole.admin,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: LayaPocPanel(
              workspace: WorkspaceSummary(
                id: 7,
                name: 'Test workspace',
                role: role,
              ),
              request: request,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('offline model shows samples and never fabricates Laya results', (
    tester,
  ) async {
    final calls = <String>[];
    await showPanel(tester, (method, args) async {
      calls.add(method);
      expect(args['workspaceId'], 7);
      return snapshot(available: false);
    });
    expect(find.text('Local model offline'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Run Laya grouping'),
    );
    expect(button.onPressed, isNull);
    expect(
      find.textContaining('No AI results have been generated yet'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Original reports'));
    await tester.tap(find.text('Original reports'));
    await tester.pumpAndSettle();
    expect(find.text('The reset email never arrives.'), findsOneWidget);
    expect(calls, ['read']);
  });

  testWidgets(
    'real evaluation flow calls server and renders grouped evidence',
    (tester) async {
      final calls = <String>[];
      await showPanel(tester, (method, args) async {
        calls.add(method);
        expect(args['workspaceId'], 7);
        if (method == 'start') {
          expect(args['sources'], containsAll(['Discord', 'Slack', 'Email']));
          return snapshot(run: result(complete: false));
        }
        if (method == 'step') {
          expect(args['runId'], 'run-1');
          expect(args['expectedIndex'], 0);
          return snapshot(run: result());
        }
        return snapshot();
      });
      await tester.ensureVisible(find.text('Run Laya grouping'));
      await tester.tap(find.text('Run Laya grouping'));
      await tester.pumpAndSettle();
      expect(calls, ['read', 'start', 'step']);
      expect(find.text('Reset email missing'), findsOneWidget);
      expect(find.text('2 reports\n2 people'), findsOneWidget);
      await tester.ensureVisible(find.text('Reset email missing'));
      await tester.tap(find.text('Reset email missing'));
      await tester.pumpAndSettle();
      expect(find.text('The reset email never arrives.'), findsOneWidget);
      expect(
        find.text('My password recovery code has not arrived.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Viewer can inspect shared results but cannot run evaluation', (
    tester,
  ) async {
    await showPanel(
      tester,
      (_, _) async => snapshot(run: result()),
      role: WorkspaceRole.viewer,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Run Laya grouping'),
          )
          .onPressed,
      isNull,
    );
    expect(find.text('Reset email missing'), findsOneWidget);
    expect(find.textContaining('Viewer access'), findsOneWidget);
    expect(find.byType(DropdownButton<String>), findsNWidgets(2));
  });

  testWidgets('POC source cards and table fit a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await showPanel(tester, (_, _) async => snapshot(run: result()));
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Original reports'));
    await tester.tap(find.text('Original reports'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
