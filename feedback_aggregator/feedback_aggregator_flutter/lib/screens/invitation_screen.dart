import 'package:feedback_aggregator_client/feedback_aggregator_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import '../client.dart';
import 'workspace_shell.dart';

class InvitationScreen extends StatefulWidget {
  final String token;
  const InvitationScreen({super.key, required this.token});
  @override
  State<InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen> {
  InvitationInfo? _invitation;
  String? _error;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _preview();
  }

  Future<void> _preview() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final invitation = await client.workspace.previewInvitation(widget.token);
      if (mounted) setState(() => _invitation = invitation);
    } catch (e) {
      if (mounted) setState(() => _error = workspaceError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _join() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final org = await client.workspace.acceptInvitation(widget.token);
      if (!mounted) return;
      // Leave the invitation route after its single-use token is consumed.
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/', (route) => false, arguments: org.id);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = workspaceError(e);
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.group_add_outlined,
                  size: 48,
                  color: Color(0xFF4F46E5),
                ),
                const SizedBox(height: 20),
                const Text(
                  'You’re invited',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                if (_loading)
                  const CircularProgressIndicator()
                else if (_error != null) ...[
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _preview,
                    child: const Text('Try again'),
                  ),
                  TextButton(
                    onPressed: () => client.auth.signOutDevice(),
                    child: const Text('Sign out to use another account'),
                  ),
                ] else if (_invitation != null) ...[
                  Text(
                    'Join ${_invitation!.workspaceName}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_invitation!.email}\n${roleLabel(_invitation!.role)} access',
                    textAlign: TextAlign.center,
                    style: const TextStyle(height: 1.7),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _join,
                    child: const Text('Join workspace'),
                  ),
                ],
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  ),
                  child: const Text('Go to home'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
