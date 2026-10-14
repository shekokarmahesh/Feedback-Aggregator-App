import 'package:feedback_aggregator_client/feedback_aggregator_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

/// Let Serverpod refresh first, then recover or discard a rejected session.
/// A rejected refresh must not leave a signed-in dashboard that cannot write.
class SessionAwareClient extends Client {
  SessionAwareClient(
    super.host, {
    super.connectionTimeout,
    super.httpClientOverride,
  });

  bool sessionExpired = false;
  Future<bool>? _recovery;

  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) async {
    final manager = authKeyProvider;
    final attempted = manager is FlutterAuthSessionManager
        ? manager.authInfo
        : null;
    try {
      return await super.callServerEndpoint<T>(
        endpoint,
        method,
        args,
        authenticated: authenticated,
      );
    } on ServerpodClientUnauthorized {
      if (!authenticated ||
          manager is! FlutterAuthSessionManager ||
          attempted == null) {
        rethrow;
      }
      // An old request must never discard a newer sign-in.
      if (!_sameSession(manager.authInfo, attempted)) rethrow;
      final recovery = _recovery ??= _recover(manager, attempted);
      bool recovered;
      try {
        recovered = await recovery;
      } finally {
        if (identical(_recovery, recovery)) _recovery = null;
      }
      if (!recovered) rethrow;
      return super.callServerEndpoint<T>(
        endpoint,
        method,
        args,
        authenticated: authenticated,
      );
    }
  }

  bool _sameSession(AuthSuccess? current, AuthSuccess attempted) =>
      current?.authUserId == attempted.authUserId &&
      current?.refreshToken == attempted.refreshToken &&
      current?.token == attempted.token;

  Future<bool> _recover(
    FlutterAuthSessionManager manager,
    AuthSuccess attempted,
  ) async {
    final result = await manager.refreshAuthKey(force: true);
    if (result == RefreshAuthKeyResult.success) return true;
    if (result == RefreshAuthKeyResult.failedUnauthorized &&
        _sameSession(manager.authInfo, attempted)) {
      sessionExpired = true;
      await manager.updateSignedInUser(null);
    }
    // Temporary network/server failures preserve the session for a later retry.
    return false;
  }
}
