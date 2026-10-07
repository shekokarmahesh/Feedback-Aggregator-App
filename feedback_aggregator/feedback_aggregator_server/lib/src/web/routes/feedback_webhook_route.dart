import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../../feedback/feedback_submission.dart';
import '../../feedback/webhook_key_service.dart';
import '../../generated/protocol.dart';

/// Server-to-server ingestion; never distribute the key to browser clients.
class FeedbackWebhookRoute extends Route {
  FeedbackWebhookRoute() : super(methods: {Method.post});

  Response _json(int status, Map<String, Object?> data) => Response(
    status,
    body: Body.fromString(jsonEncode(data), mimeType: MimeType.json),
  );

  @override
  Future<Result> handleCall(Session session, Request request) async {
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
    if (mapping == null) {
      return _json(401, {'error': 'Invalid webhook key.'});
    }
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

    final FeedbackSubmission input;
    try {
      // Enforce the limit on streamed bytes, including chunked requests.
      final bytes = <int>[];
      await for (final chunk in request.read()) {
        if (bytes.length + chunk.length > 65536) {
          return _json(413, {'error': 'Request body exceeds 64 KiB.'});
        }
        bytes.addAll(chunk);
      }
      input = FeedbackSubmission.parse(utf8.decode(bytes), contentType!);
    } on FormatException catch (error) {
      return _json(400, {'error': error.message});
    } catch (_) {
      return _json(400, {'error': 'Unable to read request body.'});
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
      // Do not log request bodies, email addresses, or the webhook key.
      session.log(
        'Feedback webhook persistence failed.',
        level: LogLevel.error,
      );
      return _json(500, {'error': 'Unable to save feedback.'});
    }
  }
}
