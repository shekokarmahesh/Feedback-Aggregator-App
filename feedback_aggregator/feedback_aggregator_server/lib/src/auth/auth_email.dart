import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

/// Responsive, table-based email with a plain-text alternative for email clients.
String authCodeHtml(String code, {bool passwordReset = true}) {
  final safeCode = const HtmlEscape().convert(code);
  final title = passwordReset ? 'Reset your password' : 'Verify your email';
  final purpose = passwordReset ? 'password reset' : 'email verification';
  return '''<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>$title</title></head>
<body style="margin:0;background:#f3f4f8;font-family:Arial,Helvetica,sans-serif;color:#172033">
<div style="display:none;max-height:0;overflow:hidden">Your Feedback Aggregator $purpose code expires in 15 minutes.</div>
<table role="presentation" width="100%" cellspacing="0" cellpadding="0"><tr><td align="center" style="padding:40px 16px">
<table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="max-width:520px;background:#ffffff;border:1px solid #e5e7eb;border-radius:16px">
<tr><td style="padding:28px 32px;background:#4f46e5;color:#ffffff;border-radius:16px 16px 0 0;font-size:18px;font-weight:bold">Feedback Aggregator</td></tr>
<tr><td style="padding:32px"><p style="margin:0 0 8px;font-size:12px;letter-spacing:2px;color:#6366f1;font-weight:bold">ACCOUNT SECURITY</p>
<h1 style="margin:0 0 16px;font-size:28px;line-height:1.3">$title</h1>
<p style="font-size:16px;line-height:1.6;color:#536079">Enter this code in the app to complete your $purpose.</p>
<div style="padding:24px 12px;margin:24px 0;background:#eef2ff;border:1px solid #c7d2fe;border-radius:12px;text-align:center;font-family:monospace;font-size:30px;font-weight:bold;letter-spacing:5px;color:#3730a3">$safeCode</div>
<p style="font-size:14px;line-height:1.6;color:#536079">This code expires in <strong>15 minutes</strong> and can only be used once. Never share it with anyone.</p>
<p style="font-size:14px;line-height:1.6;color:#536079">If you didn't request this, you can safely ignore this email.</p></td></tr>
<tr><td style="padding:20px 32px;border-top:1px solid #e5e7eb;font-size:12px;color:#6b7280">Sent securely by Feedback Aggregator · Automated account email</td></tr>
</table></td></tr></table></body></html>''';
}

class AuthEmailSender {
  final String apiKey;
  final String from;
  final Uri endpoint;
  AuthEmailSender({required this.apiKey, required this.from, Uri? endpoint})
    : endpoint = endpoint ?? Uri.parse('https://api.resend.com/emails');

  Future<void> sendCode(
    Session session, {
    required String email,
    required String code,
    required String requestId,
    bool passwordReset = true,
  }) async {
    if (apiKey.isEmpty) {
      session.log('Resend API key is not configured.', level: LogLevel.error);
      throw StateError('Email delivery is unavailable.');
    }
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      await (() async {
        final request = await client.postUrl(endpoint);
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
        request.headers.contentType = ContentType.json;
        request.headers.set(
          'Idempotency-Key',
          '${passwordReset ? 'reset' : 'verify'}/$requestId',
        );
        final purpose = passwordReset ? 'password reset' : 'email verification';
        request.write(
          jsonEncode({
            'from': from,
            'to': [email],
            'subject': passwordReset
                ? 'Reset your Feedback Aggregator password'
                : 'Verify your Feedback Aggregator email',
            'html': authCodeHtml(code, passwordReset: passwordReset),
            'text':
                'Your Feedback Aggregator $purpose code is: $code\n\nIt expires in 15 minutes and can only be used once. Never share it. If you did not request this, ignore this email.',
          }),
        );
        final response = await request.close();
        await response.drain<void>();
        if (response.statusCode < 200 || response.statusCode >= 300) {
          session.log(
            'Resend rejected auth email (HTTP ${response.statusCode}).',
            level: LogLevel.error,
          );
          throw StateError('Email delivery failed.');
        }
      })().timeout(const Duration(seconds: 20));
    } finally {
      client.close(force: true);
    }
  }
}
