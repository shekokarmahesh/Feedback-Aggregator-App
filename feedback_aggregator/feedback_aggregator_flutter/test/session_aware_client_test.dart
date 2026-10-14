import 'dart:async';
import 'dart:convert';

import 'package:feedback_aggregator_client/feedback_aggregator_client.dart';
import 'package:feedback_aggregator_flutter/screens/sign_in_screen.dart';
import 'package:feedback_aggregator_flutter/screens/source_configuration_dialog.dart';
import 'package:feedback_aggregator_flutter/session_aware_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart'
    hide Protocol;

class _Storage implements ClientAuthSuccessStorage {
  AuthSuccess? value;
  @override
  Future<AuthSuccess?> get() async => value;
  @override
  Future<void> set(AuthSuccess? data) async => value = data;
}

AuthSuccess _session(String token, {bool expired = false}) => AuthSuccess(
  authStrategy: 'jwt',
  token: token,
  refreshToken: 'refresh-$token',
  tokenExpiresAt: DateTime.now().toUtc().add(
    expired ? const Duration(minutes: -1) : const Duration(minutes: 10),
  ),
  authUserId: UuidValue.fromString('00000000-0000-4000-8000-000000000001'),
  scopeNames: {},
);

http.Response _result() => http.Response(
  jsonEncode(
    SourceSyncResult(
      connection: MockSourceConnection(
        workspaceId: 1,
        source: 'Forms',
        connected: true,
        syncedCount: 5,
        availableCount: 8,
      ),
      addedCount: 5,
    ).toJson(),
  ),
  200,
);

Future<SessionAwareClient> _client(
  FutureOr<http.Response> Function(http.Request) handler, {
  bool expired = false,
}) async {
  final client = SessionAwareClient(
    'https://example.com/api/',
    httpClientOverride: MockClient((request) async => handler(request)),
  )..authSessionManager = FlutterAuthSessionManager(storage: _Storage());
  await client.auth.updateSignedInUser(_session('old', expired: expired));
  addTearDown(client.close);
  return client;
}

void main() {
  testWidgets(
    'rejected refresh closes webhook setup and shows sign-in instead of a stuck dashboard',
    (tester) async {
      var sourceCalls = 0;
      final client = await _client((request) {
        if (request.url.path.endsWith('/emailIdp/login')) {
          return http.Response(jsonEncode(_session('new').toJson()), 200);
        }
        if (request.url.path.endsWith('/refreshAccessToken')) {
          return http.Response(
            Protocol().encodeWithTypeForProtocol(
              RefreshTokenInvalidSecretException(),
            ),
            500,
          );
        }
        sourceCalls++;
        if (request.headers['authorization'] == 'Bearer new') return _result();
        return http.Response('', 401);
      }, expired: true);
      await tester.pumpWidget(
        MaterialApp(
          home: SignInScreen(
            apiClient: client,
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () => showDialog<SourceSyncResult>(
                  context: context,
                  builder: (_) => SourceConfigurationDialog(
                    source: 'Forms',
                    availableCount: 8,
                    onSubmit: (key) =>
                        client.sources.configure(1, 'Forms', key),
                  ),
                ),
                child: const Text('Configure Forms'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Configure Forms'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('use-webhook-key')));
      await tester.tap(
        find.byKey(const ValueKey('submit-source-configuration')),
      );
      await tester.pumpAndSettle();
      expect(sourceCalls, 1);
      expect(client.auth.isAuthenticated, isFalse);
      expect(await client.auth.storage.get(), isNull);
      expect(find.text('Configure Forms'), findsNothing);
      expect(find.text('Could not connect. Try again.'), findsNothing);
      expect(
        find.text('Your session expired. Sign in again to continue.'),
        findsOneWidget,
      );
      expect(find.text('Sign in with email'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'person@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'test-password',
      );
      await tester.ensureVisible(find.text('Sign in'));
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Configure Forms'), findsOneWidget);
      expect(client.sessionExpired, isFalse);
      await tester.tap(find.text('Configure Forms'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('use-webhook-key')));
      await tester.tap(
        find.byKey(const ValueKey('submit-source-configuration')),
      );
      await tester.pumpAndSettle();
      expect(sourceCalls, 2);
      expect(client.auth.isAuthenticated, isTrue);
      expect(find.byKey(const ValueKey('webhook-key')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  test('a valid forced refresh retries the same configuration once', () async {
    var calls = 0;
    final client = await _client((request) {
      if (request.url.path.endsWith('/refreshAccessToken')) {
        return http.Response(jsonEncode(_session('new').toJson()), 200);
      }
      expect(jsonDecode(request.body)['webhookKey'], suggestedWebhookKey);
      return ++calls == 1 ? http.Response('', 401) : _result();
    });
    final result = await client.sources.configure(
      1,
      'Forms',
      suggestedWebhookKey,
    );
    expect(result.connection.connected, isTrue);
    expect(calls, 2);
    expect(client.auth.isAuthenticated, isTrue);
    expect(client.sessionExpired, isFalse);
  });

  test('a temporary refresh outage retains the login for retry', () async {
    final client = await _client((request) {
      if (request.url.path.endsWith('/refreshAccessToken')) {
        return http.Response('', 503);
      }
      return http.Response('', 401);
    }, expired: true);
    await expectLater(
      client.sources.configure(1, 'Forms', suggestedWebhookKey),
      throwsA(isA<ServerpodClientUnauthorized>()),
    );
    expect(client.auth.isAuthenticated, isTrue);
    expect(client.sessionExpired, isFalse);
  });

  test(
    'workspace permission failure does not invalidate authentication',
    () async {
      final client = await _client((_) => http.Response('', 403));
      await expectLater(
        client.sources.configure(1, 'Forms', suggestedWebhookKey),
        throwsA(isA<ServerpodClientForbidden>()),
      );
      expect(client.auth.isAuthenticated, isTrue);
      expect(client.sessionExpired, isFalse);
    },
  );

  test('an old rejected request cannot clear a newer sign-in', () async {
    final response = Completer<http.Response>();
    final started = Completer<void>();
    final client = await _client((_) {
      started.complete();
      return response.future;
    });
    final request = client.sources.configure(1, 'Forms', suggestedWebhookKey);
    final assertion = expectLater(
      request,
      throwsA(isA<ServerpodClientUnauthorized>()),
    );
    await started.future;
    await client.auth.updateSignedInUser(_session('new'));
    response.complete(http.Response('', 401));
    await assertion;
    expect(client.auth.authInfo?.token, 'new');
    expect(client.sessionExpired, isFalse);
  });
}
