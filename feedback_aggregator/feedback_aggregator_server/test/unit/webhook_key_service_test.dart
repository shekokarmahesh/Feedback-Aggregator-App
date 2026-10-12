import 'package:feedback_aggregator_server/src/feedback/webhook_key_service.dart';
import 'package:test/test.dart';

void main() {
  test(
    'generates distinct 256-bit keys with stable non-reversible lookup hashes',
    () {
      final keys = List.generate(100, (_) => generateWebhookKey());
      expect(keys.toSet(), hasLength(100));
      for (final key in keys) {
        expect(isWebhookKey(key), isTrue);
        expect(hashWebhookKey(key), hasLength(64));
        expect(hashWebhookKey(key), isNot(key));
        expect(hashWebhookKey(key), hashWebhookKey(key));
      }
      expect(hashWebhookKey(keys[0]), isNot(hashWebhookKey(keys[1])));
    },
  );
  test('rejects malformed keys before database lookup', () {
    for (final key in ['', 'secret', 'fbk_short', 'fbk_${'!' * 43}']) {
      expect(isWebhookKey(key), isFalse);
    }
  });
}
