import 'package:serverpod/serverpod.dart';
import 'package:feedback_aggregator_server/src/generated/protocol.dart';
import 'package:feedback_aggregator_server/src/feedback/webhook_key_service.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Team-scoped ingestion keys', (sessions, endpoints) {
    final owner = sessions.copyWith(
      authentication: AuthenticationOverride.authenticationInfo('owner-a', {}),
    );
    final other = sessions.copyWith(
      authentication: AuthenticationOverride.authenticationInfo('owner-b', {}),
    );

    test('requires login for team creation and key generation', () async {
      await expectLater(
        endpoints.feedbackIngestion.createTeam(sessions, 'A'),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
      await expectLater(
        endpoints.feedbackIngestion.generateKey(sessions, 1),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });

    test('maps hashes to teams and denies cross-team key management', () async {
      final a = await endpoints.feedbackIngestion.createTeam(owner, 'A');
      final b = await endpoints.feedbackIngestion.createTeam(other, 'B');
      final keyA = await endpoints.feedbackIngestion.generateKey(owner, a.id!);
      final keyB = await endpoints.feedbackIngestion.generateKey(other, b.id!);
      expect(keyA, isNot(keyB));
      final session = sessions.build();
      addTearDown(session.close);
      final mappingA = await FeedbackWebhookKey.db.findFirstRow(
        session,
        where: (t) => t.keyHash.equals(hashWebhookKey(keyA)),
      );
      final mappingB = await FeedbackWebhookKey.db.findFirstRow(
        session,
        where: (t) => t.keyHash.equals(hashWebhookKey(keyB)),
      );
      expect(mappingA!.teamId, a.id);
      expect(mappingB!.teamId, b.id);
      expect(mappingA.keyHash, isNot(keyA));
      await expectLater(
        endpoints.feedbackIngestion.generateKey(other, a.id!),
        throwsA(isA<AuthFlowException>()),
      );
      await expectLater(
        endpoints.feedbackIngestion.revokeKey(other, a.id!, keyA),
        throwsA(isA<AuthFlowException>()),
      );
      await endpoints.feedbackIngestion.revokeKey(owner, a.id!, keyA);
      final active = await FeedbackWebhookKey.db.findFirstRow(
        session,
        where: (t) =>
            t.keyHash.equals(hashWebhookKey(keyA)) & t.revokedAt.equals(null),
      );
      expect(active, isNull);
      await endpoints.feedbackIngestion.revokeKey(owner, a.id!, keyA);
      final otherActive = await FeedbackWebhookKey.db.findFirstRow(
        session,
        where: (t) =>
            t.keyHash.equals(hashWebhookKey(keyB)) & t.revokedAt.equals(null),
      );
      expect(otherActive, isNotNull);
    });
  });
}
