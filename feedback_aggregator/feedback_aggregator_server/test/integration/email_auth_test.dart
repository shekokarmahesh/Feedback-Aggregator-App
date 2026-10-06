import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:feedback_aggregator_server/src/generated/protocol.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Email/password authentication', (sessions, endpoints) {
    String? resetCode;
    var registrationEmails = 0;
    setUp(() {
      resetCode = null;
      registrationEmails = 0;
      AuthServices.set(
        tokenManagerBuilders: [JwtConfigFromPasswords()],
        identityProviderBuilders: [
          EmailIdpConfigFromPasswords(
            sendRegistrationVerificationCode:
                (
                  session, {
                  required email,
                  required accountRequestId,
                  required verificationCode,
                  required transaction,
                }) {
                  registrationEmails++;
                },
            sendPasswordResetVerificationCode:
                (
                  session, {
                  required email,
                  required passwordResetRequestId,
                  required verificationCode,
                  required transaction,
                }) {
                  resetCode = verificationCode;
                },
          ),
        ],
      );
    });

    test(
      'registers and logs in immediately without sending a signup code',
      () async {
        final signup = await endpoints.emailIdp.register(
          sessions,
          email: ' New@Example.com ',
          password: 'SecurePassword123',
        );
        final login = await endpoints.emailIdp.login(
          sessions,
          email: 'new@example.com',
          password: 'SecurePassword123',
        );
        expect(signup.authUserId, login.authUserId);
        expect(signup.token, isNotEmpty);
        expect(registrationEmails, 0);
      },
    );

    test(
      'duplicate registration offers sign-in/reset instead of a fake code step',
      () async {
        await endpoints.emailIdp.register(
          sessions,
          email: 'duplicate@example.com',
          password: 'SecurePassword123',
        );
        await expectLater(
          endpoints.emailIdp.register(
            sessions,
            email: 'DUPLICATE@example.com',
            password: 'AnotherPassword123',
          ),
          throwsA(isA<AuthFlowException>()),
        );
        expect(registrationEmails, 0);
      },
    );

    test('rejects weak passwords and malformed email addresses', () async {
      await expectLater(
        endpoints.emailIdp.register(
          sessions,
          email: 'weak@example.com',
          password: '123',
        ),
        throwsA(isA<AuthFlowException>()),
      );
      await expectLater(
        endpoints.emailIdp.register(
          sessions,
          email: 'invalid',
          password: 'SecurePassword123',
        ),
        throwsA(isA<AuthFlowException>()),
      );
    });

    test(
      'reset requires the emailed code and the completion token cannot be reused',
      () async {
        await endpoints.emailIdp.register(
          sessions,
          email: 'reset@example.com',
          password: 'OldPassword123',
        );
        final id = await endpoints.emailIdp.startPasswordReset(
          sessions,
          email: 'reset@example.com',
        );
        expect(resetCode, isNotNull);
        await expectLater(
          endpoints.emailIdp.verifyPasswordResetCode(
            sessions,
            passwordResetRequestId: id,
            verificationCode: 'incorrect',
          ),
          throwsA(isA<EmailAccountPasswordResetException>()),
        );
        final token = await endpoints.emailIdp.verifyPasswordResetCode(
          sessions,
          passwordResetRequestId: id,
          verificationCode: resetCode!,
        );
        await endpoints.emailIdp.finishPasswordReset(
          sessions,
          finishPasswordResetToken: token,
          newPassword: 'NewPassword123',
        );
        await expectLater(
          endpoints.emailIdp.login(
            sessions,
            email: 'reset@example.com',
            password: 'OldPassword123',
          ),
          throwsA(isA<EmailAccountLoginException>()),
        );
        final signedIn = await endpoints.emailIdp.login(
          sessions,
          email: 'reset@example.com',
          password: 'NewPassword123',
        );
        expect(signedIn.token, isNotEmpty);
        await expectLater(
          endpoints.emailIdp.finishPasswordReset(
            sessions,
            finishPasswordResetToken: token,
            newPassword: 'ReusedPassword123',
          ),
          throwsA(isA<EmailAccountPasswordResetException>()),
        );
      },
    );

    test('unknown email does not receive a reset code', () async {
      await endpoints.emailIdp.startPasswordReset(
        sessions,
        email: 'unknown@example.com',
      );
      expect(resetCode, isNull);
    });
  }, rollbackDatabase: RollbackDatabase.disabled);
}
