import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// 256 bits of entropy; the raw key is returned once and never persisted.
String generateWebhookKey() {
  final random = Random.secure();
  return 'fbk_${base64Url.encode(List<int>.generate(32, (_) => random.nextInt(256))).replaceAll('=', '')}';
}

String hashWebhookKey(String key) =>
    sha256.convert(utf8.encode(key)).toString();

bool isWebhookKey(String key) =>
    RegExp(r'^fbk_[A-Za-z0-9_-]{43}$').hasMatch(key);
