import 'package:feedback_aggregator_client/feedback_aggregator_client.dart';
import 'package:flutter/material.dart';

import '../models/demo_ticket.dart';

class SourcesPanel extends StatefulWidget {
  final WorkspaceSummary? workspace;
  final List<DemoTicket> tickets;
  final List<MockSourceConnection> connections;
  final Set<String> syncing;
  final Map<String, String> syncErrors;
  final String? discordGuildId;
  final VoidCallback? onConfigureDiscord;
  final Future<SourceSyncResult> Function(String)? onConnect;
  final Future<SourceSyncResult> Function(String)? onSync;
  final Future<void> Function(String)? onDisconnect;

  const SourcesPanel({
    super.key,
    this.workspace,
    this.tickets = const [],
    this.connections = const [],
    this.syncing = const {},
    this.syncErrors = const {},
    this.discordGuildId,
    this.onConfigureDiscord,
    this.onConnect,
    this.onSync,
    this.onDisconnect,
  });

  @override
  State<SourcesPanel> createState() => _SourcesPanelState();
}

class _SourcesPanelState extends State<SourcesPanel> {
  final _busy = <String>{};
  final _errors = <String, String>{};

  @override
  void didUpdateWidget(SourcesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final connection in widget.connections) {
      final previous = oldWidget.connections
          .where((c) => c.source == connection.source)
          .firstOrNull;
      if (previous?.lastSyncedAt != connection.lastSyncedAt ||
          previous?.connected != connection.connected) {
        _errors.remove(connection.source);
      }
    }
  }

  Future<void> _act(String source, Future<String> Function() action) async {
    if (_busy.contains(source) || widget.syncing.contains(source)) return;
    setState(() {
      _busy.add(source);
      _errors.remove(source);
    });
    try {
      final message = await action();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _errors[source] = error is WorkspaceException
              ? error.message
              : 'Sync failed. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy.remove(source));
    }
  }

  String _syncMessage(String source, SourceSyncResult result) {
    if (result.addedCount > 0) {
      return '${result.addedCount} sample reports from $source added to your inbox.';
    }
    if (result.connection.syncedCount < result.connection.availableCount) {
      return '$source is connected. Auto-sync will import the remaining sample reports.';
    }
    return '$source is up to date. No duplicate tickets were added.';
  }

  String _lastSynced(DateTime? value) {
    if (value == null) return 'Waiting for the first sync';
    final ago = DateTime.now().toUtc().difference(value.toUtc());
    if (ago.inMinutes < 1) return 'Last synced just now';
    if (ago.inHours < 1) return 'Last synced ${ago.inMinutes} min ago';
    if (ago.inDays < 1) return 'Last synced ${ago.inHours} hr ago';
    return 'Last synced ${ago.inDays} days ago';
  }

  Widget _tag(String text, {bool active = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: active ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: active ? const Color(0xFF047857) : const Color(0xFF64748B),
      ),
    ),
  );

  Widget _card({
    required String source,
    required IconData icon,
    required String description,
    required String status,
    bool active = false,
    List<Widget> children = const [],
  }) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF6154A4)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                source,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _tag(status, active: active),
        const SizedBox(height: 16),
        Text(
          description,
          style: const TextStyle(height: 1.5, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 12),
        Text(
          '${widget.tickets.where((t) => t.source == source).length} feedback tickets in this inbox',
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        ...children,
      ],
    ),
  );

  Widget _mock(String source) {
    final connection = widget.connections
        .where((c) => c.source == source)
        .firstOrNull;
    final connected = connection?.connected == true;
    final admin = widget.workspace?.role == WorkspaceRole.admin;
    final canWrite =
        widget.workspace != null &&
        widget.workspace!.role != WorkspaceRole.viewer;
    final busy = _busy.contains(source) || widget.syncing.contains(source);
    final error = _errors[source] ?? widget.syncErrors[source];
    final remaining = connection == null
        ? 12
        : connection.availableCount - connection.syncedCount;
    return _card(
      source: source,
      icon: source == 'Email' ? Icons.mail_outline : Icons.tag,
      description: source == 'Email'
          ? 'Bring sample support emails, feature requests, and issue reports into your workspace.'
          : 'Sync sample conversations from #customer-feedback, #support-triage, and #product-ideas.',
      status: busy
          ? 'Syncing…'
          : connected
          ? 'Demo connected'
          : 'Demo available',
      active: connected,
      children: [
        const SizedBox(height: 16),
        if (connection != null) ...[
          Text(
            '${connection.syncedCount} of ${connection.availableCount} sample reports imported',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: connection.availableCount == 0
                ? 0
                : connection.syncedCount / connection.availableCount,
            color: const Color(0xFF6154A4),
            backgroundColor: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 10),
          Text(
            _lastSynced(connection.lastSyncedAt),
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          connected
              ? remaining > 0
                    ? 'Auto-sync every 30 seconds while this workspace is open.'
                    : 'Up to date. All sample reports are in your inbox.'
              : connection == null
              ? 'Connect to import the first 5 reports automatically.'
              : 'Disconnected. Imported tickets stay in your workspace.',
          style: const TextStyle(
            height: 1.5,
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
        if (busy) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
        ],
        if (error != null) ...[
          const SizedBox(height: 12),
          Text(
            error,
            key: ValueKey('source-error-$source'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            if (!connected && admin && widget.onConnect != null)
              FilledButton.icon(
                key: ValueKey('connect-$source'),
                onPressed: busy
                    ? null
                    : () => _act(
                        source,
                        () async => _syncMessage(
                          source,
                          await widget.onConnect!(source),
                        ),
                      ),
                icon: const Icon(Icons.link, size: 18),
                label: Text('Connect $source'),
              ),
            if (connected && canWrite && widget.onSync != null)
              OutlinedButton.icon(
                key: ValueKey('sync-$source'),
                onPressed: busy
                    ? null
                    : () => _act(
                        source,
                        () async =>
                            _syncMessage(source, await widget.onSync!(source)),
                      ),
                icon: const Icon(Icons.sync, size: 18),
                label: const Text('Sync now'),
              ),
            if (connected && admin && widget.onDisconnect != null)
              TextButton(
                key: ValueKey('disconnect-$source'),
                onPressed: busy
                    ? null
                    : () => _act(source, () async {
                        await widget.onDisconnect!(source);
                        return '$source disconnected. Imported feedback is preserved.';
                      }),
                child: const Text('Disconnect'),
              ),
          ],
        ),
        if (!connected && !admin)
          const Text(
            'Ask a workspace Admin to connect this source.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        if (connected && !canWrite)
          const Text(
            'View-only access. An Admin or Editor can sync feedback.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
      ],
    );
  }

  void _webhookInfo() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Forms and website submissions'),
      content: const SingleChildScrollView(
        child: SelectableText(
          'Your website backend can forward form or support submissions to /webhooks/feedback. '
          'Use a team ingestion key in the X-Feedback-Webhook-Key header and send title, body, source, and userEmail. '
          'Keep the key on your backend.\n\n'
          'This existing webhook stores team Feedback rows; it does not yet feed the workspace inbox. '
          'Email and Slack demo connections below populate this inbox immediately.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Feedback sources',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 8),
      const Text(
        'Bring every customer conversation into focus.',
        style: TextStyle(height: 1.5, color: Color(0xFF64748B)),
      ),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F0FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.science_outlined, color: Color(0xFF6154A4)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Email and Slack are demo integrations using generated feedback. '
                'No account credentials are needed. Imported tickets are marked Demo and shared only with this workspace.',
                style: TextStyle(height: 1.5),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth >= 700
              ? (constraints.maxWidth - 16) / 2
              : constraints.maxWidth;
          final cards = <Widget>[
            _mock('Email'),
            _mock('Slack'),
            _card(
              source: 'Discord',
              icon: Icons.forum_outlined,
              description:
                  'Install the bot, run /feedback setup in your Discord server, then link its guild ID to this workspace.',
              status: widget.discordGuildId == null
                  ? 'Not connected'
                  : 'Connected',
              active: widget.discordGuildId != null,
              children: [
                const SizedBox(height: 16),
                if (widget.onConfigureDiscord != null)
                  FilledButton.icon(
                    onPressed: widget.onConfigureDiscord,
                    icon: const Icon(Icons.settings_outlined, size: 18),
                    label: Text(
                      widget.discordGuildId == null
                          ? 'Set up Discord'
                          : 'Configure Discord',
                    ),
                  )
                else
                  const Text(
                    'Ask a workspace Admin to set up Discord.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
              ],
            ),
            _card(
              source: 'Forms',
              icon: Icons.article_outlined,
              description:
                  'Collect website feedback with the existing form and support webhook.',
              status: 'Webhook available',
              children: [
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _webhookInfo,
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('View webhook setup'),
                ),
              ],
            ),
            _card(
              source: 'Support',
              icon: Icons.support_agent,
              description:
                  'Forward support submissions through the existing webhook from your website backend.',
              status: 'Webhook available',
              children: [
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _webhookInfo,
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('View webhook setup'),
                ),
              ],
            ),
            _card(
              source: 'App reviews',
              icon: Icons.star_outline,
              description:
                  'Bring store reviews into the same triage workflow in a future integration.',
              status: 'Coming later',
            ),
          ];
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final card in cards) SizedBox(width: cardWidth, child: card),
            ],
          );
        },
      ),
    ],
  );
}
