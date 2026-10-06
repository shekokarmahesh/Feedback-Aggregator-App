import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../generated/protocol.dart';

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
class EmailIdpEndpoint extends EmailIdpBaseEndpoint {
  /// Password registration intentionally does not claim verified email ownership
  /// or link to another user's Google identity based on an email address.
  Future<AuthSuccess> register(
    Session session, {
    required String email,
    required String password,
  }) async {
    email = email.trim().toLowerCase();
    if (email.length > 254 ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      throw AuthFlowException(message: 'Enter a valid email address.');
    }
    if (password.length < 8 ||
        password.length > 256 ||
        password.trim() != password) {
      throw AuthFlowException(
        message: 'Use 8–256 characters without spaces at the ends.',
      );
    }
    final limiter = DatabaseRateLimiter(
      RateLimiterConfig(
        domain: 'feedback_aggregator',
        source: 'password_signup',
        maxAttempts: 5,
        timeframe: const Duration(hours: 1),
      ),
    );
    if (!await limiter.tryRecordAttempt(session, key: email)) {
      throw AuthFlowException(
        message: 'Too many attempts. Please try again later.',
      );
    }
    return session.db.transaction((transaction) async {
      if (await emailIdp.admin.findAccount(
            session,
            email: email,
            transaction: transaction,
          ) !=
          null) {
        throw AuthFlowException(
          message:
              'Could not create this account. Try signing in or resetting your password.',
        );
      }
      final auth = AuthServices.instance;
      final user = await auth.authUsers.create(
        session,
        transaction: transaction,
      );
      await emailIdp.admin.createEmailAuthentication(
        session,
        authUserId: user.id,
        email: email,
        password: password,
        transaction: transaction,
      );
      await auth.userProfiles.createUserProfile(
        session,
        user.id,
        UserProfileData(email: email),
        transaction: transaction,
      );
      return emailIdp.login(
        session,
        email: email,
        password: password,
        transaction: transaction,
      );
    });
  }
}
