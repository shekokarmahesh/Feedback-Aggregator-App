import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../../feedback/discord_submission.dart';
import '../../feedback/feedback_submission.dart';
import '../../feedback/webhook_key_service.dart';
import '../../feedback/grouping_service.dart';
import '../../generated/protocol.dart';

class FeedbackWebhookRoute extends Route {
  FeedbackWebhookRoute() : super(methods: {Method.post});

  Response _json(int status, Map<String, Object?> data) => Response(
    status,
    body: Body.fromString(jsonEncode(data), mimeType: MimeType.json),
  );

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final contentType = request.headers['Content-Type']?.first
        .split(';')
        .first
        .trim()
        .toLowerCase();
    if (contentType != 'application/json' &&
        contentType != 'application/x-www-form-urlencoded') {
      return _json(415, {
        'error': 'Use application/json or application/x-www-form-urlencoded.',
      });
    }
    final String body;
    final Map<String, dynamic> data;
    try {
      final bytes = <int>[];
      await for (final chunk in request.read()) {
        if (bytes.length + chunk.length > 65536) {
          return _json(413, {'error': 'Request body exceeds 64 KiB.'});
        }
        bytes.addAll(chunk);
      }
      body = utf8.decode(bytes);
      final decoded = contentType == 'application/json'
          ? jsonDecode(body)
          : Uri.splitQueryString(body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Expected an object containing feedback fields.',
        );
      }
      data = decoded;
    } on FormatException catch (error) {
      return _json(400, {'error': error.message});
    } catch (_) {
      return _json(400, {'error': 'Unable to read request body.'});
    }

    if (data['platform'] is String &&
        (data['platform'] as String).trim().toLowerCase() == 'discord') {
      if (contentType != 'application/json') {
        return _json(415, {
          'error': 'Discord submissions require application/json.',
        });
      }
      return _discord(session, data);
    }

    final keys = request.headers['X-Feedback-Webhook-Key'];
    if (keys == null || keys.length != 1 || !isWebhookKey(keys.single)) {
      return _json(401, {'error': 'Invalid webhook key.'});
    }
    final FeedbackWebhookKey? mapping;
    try {
      mapping = await FeedbackWebhookKey.db.findFirstRow(
        session,
        where: (t) =>
            t.keyHash.equals(hashWebhookKey(keys.single)) &
            t.revokedAt.equals(null),
      );
    } catch (_) {
      session.log('Feedback webhook key lookup failed.', level: LogLevel.error);
      return _json(503, {'error': 'Feedback ingestion is unavailable.'});
    }
    if (mapping == null) return _json(401, {'error': 'Invalid webhook key.'});

    final FeedbackSubmission input;
    try {
      input = FeedbackSubmission.parse(body, contentType!);
    } on FormatException catch (error) {
      return _json(400, {'error': error.message});
    }
    try {
      final feedback = await Feedback.db.insertRow(
        session,
        Feedback(
          teamId: mapping.teamId,
          title: input.title,
          body: input.body,
          source: input.source,
          userEmail: input.userEmail,
          createdAt: DateTime.now().toUtc(),
        ),
      );
      return _json(201, {
        'id': feedback.id,
        'createdAt': feedback.createdAt.toIso8601String(),
      });
    } catch (_) {
      session.log(
        'Feedback webhook persistence failed.',
        level: LogLevel.error,
      );
      return _json(500, {'error': 'Unable to save feedback.'});
    }
  }

  Future<Result> _discord(Session session, Map<String, dynamic> data) async {
    final DiscordSubmission input;
    try {
      input = DiscordSubmission(data);
    } on FormatException catch (error) {
      return _json(400, {'error': error.message});
    }
    final DiscordGuild? mapping;
    try {
      mapping = await DiscordGuild.db.findFirstRow(
        session,
        where: (t) => t.guildId.equals(input.guildId),
      );
    } catch (_) {
      session.log('Discord guild lookup failed.', level: LogLevel.error);
      return _json(503, {'error': 'Feedback ingestion is unavailable.'});
    }
    if (mapping == null) {
      // Flutter's page fallback intercepts 404 responses, including POSTs.
      return _json(422, {
        'error': 'Discord guild is not linked to a workspace.',
      });
    }
    try {
      // shortcut: MVP trusts guild IDs without sender authentication; verify the bot before public rollout.
      final ticket = await WorkspaceTicket.db.insertRow(
        session,
        WorkspaceTicket(
          workspaceId: mapping.workspaceId,
          title: input.title,
          description: input.body,
          source: 'Discord',
          status: 'Open',
          priority: 'Medium',
          supporters: 1,
          requester: input.requester,
        ),
      );
      final admin = await WorkspaceMember.db.findFirstRow(
        session,
        where: (t) =>
            t.workspaceId.equals(mapping!.workspaceId) &
            t.role.equals(WorkspaceRole.admin),
      );
      if (admin != null) {
        await GroupingService().enqueueFor(
          session,
          mapping.workspaceId,
          admin.authUserId,
        );
      }
      return _json(201, {
        'id': ticket.id,
        'createdAt': ticket.createdAt.toIso8601String(),
      });
    } catch (_) {
      session.log(
        'Discord feedback persistence failed.',
        level: LogLevel.error,
      );
      return _json(500, {'error': 'Unable to save feedback.'});
    }
  }
}
