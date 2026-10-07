import 'dart:convert';

/// Validated external input. Email is contact information, not authorization.
class FeedbackSubmission {
  final String title;
  final String body;
  final String source;
  final String userEmail;

  FeedbackSubmission._(this.title, this.body, this.source, this.userEmail);

  factory FeedbackSubmission.parse(String body, String contentType) {
    final Object? decoded;
    if (contentType == 'application/json') {
      decoded = jsonDecode(body);
    } else if (contentType == 'application/x-www-form-urlencoded') {
      final values = Uri.splitQueryString(body);
      // Duplicate fields are ambiguous; require one value per field.
      final all = Uri(query: body).queryParametersAll;
      if (all.values.any((values) => values.length != 1)) {
        throw const FormatException('Duplicate form fields are not allowed.');
      }
      decoded = values;
    } else {
      throw const FormatException('Unsupported content type.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Expected an object containing feedback fields.',
      );
    }
    final data = decoded;
    String field(String name, int maxLength) {
      final value = data[name];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('$name must be a non-empty string.');
      }
      final trimmed = value.trim();
      if (trimmed.length > maxLength) {
        throw FormatException('$name must be at most $maxLength characters.');
      }
      return trimmed;
    }

    final title = field('title', 200);
    final text = field('body', 20000);
    final source = field('source', 100);
    final email = field('userEmail', 254).toLowerCase();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      throw const FormatException('userEmail must be a valid email address.');
    }
    return FeedbackSubmission._(title, text, source, email);
  }
}
