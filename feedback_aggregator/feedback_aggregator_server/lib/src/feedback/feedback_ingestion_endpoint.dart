import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'webhook_key_service.dart';

/// Authenticated workspace provisioning and ingestion-key management.
class FeedbackIngestionEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  String _userId(Session session) {
    final userId = session.authenticated?.userIdentifier;
    if (userId == null) {
      throw AuthFlowException(message: 'Sign in to manage feedback ingestion.');
    }
    return userId;
  }

  Future<void> _requireOwner(Session session, int teamId) async {
    final userId = _userId(session);
    final team = await Team.db.findFirstRow(
      session,
      where: (t) => t.id.equals(teamId) & t.ownerUserId.equals(userId),
    );
    if (team == null) {
      throw AuthFlowException(message: 'Team unavailable or access denied.');
    }
  }

  Future<Team> createTeam(Session session, String name) async {
    final userId = _userId(session);
    name = name.trim();
    if (name.isEmpty || name.length > 100) {
      throw AuthFlowException(message: 'Use a team name of 1–100 characters.');
    }
    return Team.db.insertRow(
      session,
      Team(name: name, ownerUserId: userId, createdAt: DateTime.now().toUtc()),
    );
  }

  /// Returns the raw key once. Store it privately on the integrating backend.
  Future<String> generateKey(Session session, int teamId) async {
    await _requireOwner(session, teamId);
    final key = generateWebhookKey();
    await FeedbackWebhookKey.db.insertRow(
      session,
      FeedbackWebhookKey(
        teamId: teamId,
        keyHash: hashWebhookKey(key),
        createdByUserId: _userId(session),
        createdAt: DateTime.now().toUtc(),
      ),
    );
    return key;
  }

  /// Idempotent revocation; cannot revoke another team's keys.
  Future<void> revokeKey(Session session, int teamId, String key) async {
    await _requireOwner(session, teamId);
    if (!isWebhookKey(key)) {
      throw AuthFlowException(message: 'Invalid webhook key.');
    }
    final mapping = await FeedbackWebhookKey.db.findFirstRow(
      session,
      where: (t) =>
          t.teamId.equals(teamId) & t.keyHash.equals(hashWebhookKey(key)),
    );
    if (mapping != null && mapping.revokedAt == null) {
      mapping.revokedAt = DateTime.now().toUtc();
      await FeedbackWebhookKey.db.updateRow(session, mapping);
    }
  }
}
