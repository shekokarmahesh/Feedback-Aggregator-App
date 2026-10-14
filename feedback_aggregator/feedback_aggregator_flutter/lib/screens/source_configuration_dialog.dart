import 'dart:convert';

import 'package:feedback_aggregator_client/feedback_aggregator_client.dart';
import 'package:flutter/material.dart';

const suggestedWebhookKey = 'whk_fa_7e2d91b4c8a640f3b59e1d027c8f6a45';

class SourceConfigurationDialog extends StatefulWidget {
  final String source;
  final int availableCount;
  final Future<SourceSyncResult> Function(String) onSubmit;

  const SourceConfigurationDialog({
    super.key,
    required this.source,
    required this.availableCount,
    required this.onSubmit,
  });

  @override
  State<SourceConfigurationDialog> createState() =>
      _SourceConfigurationDialogState();
}

class _SourceConfigurationDialogState extends State<SourceConfigurationDialog> {
  final _key = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _key.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await widget.onSubmit(_key.text.trim());
      if (mounted) Navigator.pop(context, result);
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error is WorkspaceException
              ? error.message
              : 'Could not connect. Try again.';
        });
      }
    }
  }

  Widget _step(String title, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        SelectableText(text, style: const TextStyle(fontSize: 13, height: 1.5)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final origin = ['http', 'https'].contains(Uri.base.scheme)
        ? Uri.base.origin
        : 'https://feedbackaggregatorai.online';
    const sampleKey = suggestedWebhookKey;
    final payload = const JsonEncoder.withIndent('  ').convert({
      'title': 'CSV export is empty',
      'body': 'Filtered feedback exports contain only headers.',
      'source': widget.source,
      'userEmail': 'customer@example.com',
    });
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text('Configure ${widget.source}'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F0FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Connect ${widget.source} · ${widget.availableCount} reports\nFollow the webhook format below and enter your webhook key to start importing feedback.',
                      style: const TextStyle(height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _step(
                    '1. Webhook endpoint',
                    'POST $origin/webhooks/feedback',
                  ),
                  _step(
                    '2. Request headers',
                    'Content-Type: application/json\nX-Feedback-Webhook-Key: $sampleKey',
                  ),
                  TextButton.icon(
                    key: const ValueKey('use-webhook-key'),
                    onPressed: _busy
                        ? null
                        : () => _key.text = suggestedWebhookKey,
                    icon: const Icon(Icons.key_outlined, size: 18),
                    label: const Text('Use this key'),
                  ),
                  const SizedBox(height: 12),
                  _step('3. Example feedback payload', payload),
                  const Text(
                    'These connections currently import sample feedback. Laya processes the reports automatically in your workspace.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    key: const ValueKey('webhook-key'),
                    controller: _key,
                    enabled: !_busy,
                    maxLength: 128,
                    decoration: InputDecoration(
                      labelText: 'Your webhook key',
                      hintText: sampleKey,
                      helperText:
                          'Use the key above or enter your webhook key.',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a webhook key to connect.'
                        : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  if (_error != null)
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const ValueKey('submit-source-configuration'),
            onPressed: _busy ? null : _submit,
            child: Text(_busy ? 'Connecting…' : 'Connect and import'),
          ),
        ],
      ),
    );
  }
}
