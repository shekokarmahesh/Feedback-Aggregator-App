import 'package:feedback_aggregator_client/feedback_aggregator_client.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';
import '../client.dart';
import 'workspace_shell.dart';

class DiscordConfigScreen extends StatefulWidget {
  final WorkspaceSummary workspace;
  const DiscordConfigScreen({super.key, required this.workspace});
  @override
  State<DiscordConfigScreen> createState() => _DiscordConfigScreenState();
}

class _DiscordConfigScreenState extends State<DiscordConfigScreen> {
  final _guild = TextEditingController();
  bool _loading = true;
  bool _busy = false;
  bool _connected = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _guild.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final guild = await client.workspace.discordGuild(widget.workspace.id);
      if (!mounted) return;
      _guild.text = guild ?? '';
      setState(() {
        _connected = guild != null;
        _loading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = workspaceError(error);
          _loading = false;
        });
      }
    }
  }

  Future<void> _save({bool disconnect = false}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (disconnect) {
        await client.workspace.disconnectDiscord(widget.workspace.id);
      } else {
        await client.workspace.setDiscordGuild(
          widget.workspace.id,
          _guild.text,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = workspaceError(error);
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Discord bot configuration')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.workspace.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              const Text('1. Install the feedback bot in your Discord server.'),
              Link(
                uri: Uri.parse(
                  'https://discord.com/oauth2/authorize?client_id=1558486882793427014',
                ),
                target: LinkTarget.blank,
                builder: (context, followLink) => TextButton.icon(
                  onPressed: followLink,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Install Discord bot'),
                ),
              ),
              const SizedBox(height: 16),
              const Text('2. Run /feedback setup in that server.'),
              const SizedBox(height: 12),
              const Text(
                '3. Paste the guild ID returned by the bot below and save the link.',
              ),
              const SizedBox(height: 24),
              if (_loading) const LinearProgressIndicator(),
              TextField(
                controller: _guild,
                enabled: !_busy && !_loading,
                maxLength: 20,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Discord guild ID',
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton(
                    onPressed: _busy || _loading ? null : () => _save(),
                    child: Text(_busy ? 'Saving…' : 'Save guild link'),
                  ),
                  if (_connected)
                    TextButton(
                      onPressed: _busy ? null : () => _save(disconnect: true),
                      child: const Text('Disconnect'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
