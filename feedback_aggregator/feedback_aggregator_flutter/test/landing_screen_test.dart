import 'package:feedback_aggregator_flutter/screens/email_password_form.dart';
import 'package:feedback_aggregator_flutter/screens/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget landing() => MaterialApp(
    home: const Scaffold(body: LandingScreen()),
    routes: {
      '/login': (_) => const Scaffold(body: Text('Login destination')),
      '/signup': (_) =>
          const Scaffold(body: EmailPasswordForm(initialSignUp: true)),
    },
  );

  testWidgets('login and signup navigation open the intended pages', (
    tester,
  ) async {
    await tester.pumpWidget(landing());
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Login destination'), findsOneWidget);
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(TextFormField, 'Confirm password'),
      findsOneWidget,
    );
    expect(find.text('Login destination'), findsNothing);
  });

  testWidgets('get started opens signup and mobile layout fits', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(landing());
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Get started').first);
    await tester.tap(find.text('Get started').first);
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(TextFormField, 'Confirm password'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
