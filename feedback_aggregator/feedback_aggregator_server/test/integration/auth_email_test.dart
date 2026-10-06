import 'dart:convert';
import 'dart:io';
import 'package:feedback_aggregator_server/src/auth/auth_email.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  test(
    'email template escapes codes and includes expiry and security guidance',
    () {
      final html = authCodeHtml('<script>');
      expect(html, contains('&lt;script&gt;'));
      expect(html, isNot(contains('<script>')));
      expect(html, contains('15 minutes'));
      expect(html, contains('Never share'));
    },
  );
  withServerpod('Resend delivery', (sessions, endpoints) {
    test('sends HTML and text and uses an idempotent reset request', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final received = server.first.then((request) async {
        expect(request.headers.value('Authorization'), 'Bearer test-key');
        expect(request.headers.value('Idempotency-Key'), 'reset/request-id');
        final body = jsonDecode(await utf8.decoder.bind(request).join()) as Map;
        expect(body['to'], ['user@example.com']);
        expect(body['html'], contains('12345678'));
        expect(body['text'], contains('12345678'));
        request.response.statusCode = 200;
        request.response.write('{"id":"test-email-id"}');
        await request.response.close();
      });
      final session = sessions.build();
      addTearDown(session.close);
      await AuthEmailSender(
        apiKey: 'test-key',
        from: 'App <auth@example.com>',
        endpoint: Uri.parse('http://127.0.0.1:${server.port}/emails'),
      ).sendCode(
        session,
        email: 'user@example.com',
        code: '12345678',
        requestId: 'request-id',
      );
      await received;
    });

    test(
      'surfaces delivery errors rather than claiming an email was sent',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(() => server.close(force: true));
        final received = server.first.then((request) async {
          await request.drain<void>();
          request.response.statusCode = 403;
          await request.response.close();
        });
        final session = sessions.build();
        addTearDown(session.close);
        await expectLater(
          AuthEmailSender(
            apiKey: 'test-key',
            from: 'App <auth@example.com>',
            endpoint: Uri.parse('http://127.0.0.1:${server.port}/emails'),
          ).sendCode(
            session,
            email: 'user@example.com',
            code: '12345678',
            requestId: 'failed-request',
          ),
          throwsStateError,
        );
        await received;
      },
    );
  });
}
