import 'dart:convert';

import 'package:feedback_aggregator_server/src/feedback/feedback_submission.dart';
import 'package:test/test.dart';

void main() {
  const valid = {
    'title': ' Export feedback ',
    'body': 'Please add CSV export.',
    'source': 'website-support',
    'userEmail': ' USER@Example.com ',
  };
  test('normalizes JSON and ignores untrusted database fields', () {
    final input = FeedbackSubmission.parse(
      jsonEncode({
        ...valid,
        'id': 999,
        'teamId': 999,
        'team_id': 999,
        'createdAt': 'yesterday',
      }),
      'application/json',
    );
    expect(input.title, 'Export feedback');
    expect(input.body, valid['body']);
    expect(input.source, valid['source']);
    expect(input.userEmail, 'user@example.com');
  });
  test('accepts URL-encoded forms', () {
    final input = FeedbackSubmission.parse(
      Uri(queryParameters: valid).query,
      'application/x-www-form-urlencoded',
    );
    expect(input.userEmail, 'user@example.com');
  });
  test('rejects missing, blank, non-string, and oversized fields', () {
    for (final field in valid.keys) {
      for (final value in [null, '', '   ', 42]) {
        expect(
          () => FeedbackSubmission.parse(
            jsonEncode({...valid, field: value}),
            'application/json',
          ),
          throwsFormatException,
        );
      }
    }
    for (final entry in {
      'title': 201,
      'body': 20001,
      'source': 101,
      'userEmail': 255,
    }.entries) {
      expect(
        () => FeedbackSubmission.parse(
          jsonEncode({...valid, entry.key: 'a' * entry.value}),
          'application/json',
        ),
        throwsFormatException,
      );
    }
  });
  test(
    'rejects malformed JSON, arrays, invalid emails, and duplicate form fields',
    () {
      for (final body in [
        '{',
        '[]',
        jsonEncode({...valid, 'userEmail': 'bad-email'}),
      ]) {
        expect(
          () => FeedbackSubmission.parse(body, 'application/json'),
          throwsFormatException,
        );
      }
      expect(
        () => FeedbackSubmission.parse(
          '${Uri(queryParameters: valid).query}&title=another',
          'application/x-www-form-urlencoded',
        ),
        throwsFormatException,
      );
    },
  );
}
