/// Discord guild IDs are kept as strings to preserve their precision on web.
bool isDiscordGuildId(String value) =>
    RegExp(r'^[1-9][0-9]{16,19}$').hasMatch(value);

class DiscordSubmission {
  final String guildId;
  final String title;
  final String body;
  final String requester;

  DiscordSubmission(Map<String, dynamic> data)
    : guildId = _field(data, 'guild_id', 20),
      title = _field(data, 'title', 200),
      body = _field(data, 'body', 20000),
      requester = data['requester'] == null
          ? 'Discord user'
          : _field(data, 'requester', 100) {
    if (!isDiscordGuildId(guildId)) {
      throw const FormatException(
        'guild_id must be a Discord guild ID string.',
      );
    }
  }

  static String _field(Map<String, dynamic> data, String name, int limit) {
    final value = data[name];
    if (value is! String ||
        value.trim().isEmpty ||
        value.trim().length > limit) {
      throw FormatException(
        '$name must be a non-empty string of at most $limit characters.',
      );
    }
    return value.trim();
  }
}
