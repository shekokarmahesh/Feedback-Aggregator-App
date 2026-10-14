import 'package:feedback_aggregator_server/src/feedback/discord_submission.dart';
import 'package:test/test.dart';

void main() {
  const valid = {
    'guild_id': '123456789012345678',
    'title': ' CSV export ',
    'body': ' Please add export. ',
  };
  test('validates and trims Discord feedback without requiring an email', () {
    final input = DiscordSubmission({...valid, 'workspaceId': 999});
    expect(input.guildId, valid['guild_id']);
    expect(input.title, 'CSV export');
    expect(input.body, 'Please add export.');
    expect(input.requester, 'Discord user');
    expect(
      DiscordSubmission({...valid, 'requester': ' Alice '}).requester,
      'Alice',
    );
  });
  test('rejects missing, invalid, and oversized fields', () {
    for (final field in valid.keys) {
      for (final value in [null, '', ' ', 42]) {
        expect(
          () => DiscordSubmission({...valid, field: value}),
          throwsFormatException,
        );
      }
    }
    for (final guild in ['-123456789012345678', '1.234e17', 'abc', '0' * 18]) {
      expect(
        () => DiscordSubmission({...valid, 'guild_id': guild}),
        throwsFormatException,
      );
    }
    for (final field in {
      'title': 201,
      'body': 20001,
      'requester': 101,
    }.entries) {
      expect(
        () => DiscordSubmission({...valid, field.key: 'a' * field.value}),
        throwsFormatException,
      );
    }
  });
}
