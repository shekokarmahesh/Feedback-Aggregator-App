import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedback_aggregator_flutter/screens/email_password_form.dart';

void main() {
  Future<void> showForm(WidgetTester tester) => tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: EmailPasswordForm(),
          ),
        ),
      ),
    ),
  );
  testWidgets('sign-in and signup show password fields without an OTP step', (
    tester,
  ) async {
    await showForm(tester);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Reset code'), findsNothing);
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm password'), findsOneWidget);
    expect(find.text('Reset code'), findsNothing);
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'forgot password asks for email before requesting a real reset code',
    (tester) async {
      await showForm(tester);
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();
      expect(find.text('Send reset code'), findsOneWidget);
      expect(find.text('Password'), findsNothing);
      expect(find.text('Reset code'), findsNothing);
      await tester.tap(find.text('Back to sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Password'), findsOneWidget);
    },
  );
}
