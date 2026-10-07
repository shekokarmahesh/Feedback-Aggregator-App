import 'package:feedback_aggregator_client/feedback_aggregator_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../client.dart';
import 'workspace_shell.dart';

class TeamScreen extends StatefulWidget {
  final WorkspaceSummary workspace;
  const TeamScreen({super.key, required this.workspace});
  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final _email = TextEditingController();
  WorkspaceRole _role = WorkspaceRole.viewer;
  List<MemberInfo> _members = [];
  List<InvitationInfo> _invitations = [];
  bool _loading = true;
  bool _busy = false;
  String? _error;
  WorkspaceRole? _currentRole;
  bool get _admin =>
      (_currentRole ?? widget.workspace.role) == WorkspaceRole.admin;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final members = await client.workspace.members(widget.workspace.id);
      final currentRole = members.firstWhere((m) => m.isCurrentUser).role;
      final invitations = currentRole == WorkspaceRole.admin
          ? await client.workspace.invitations(widget.workspace.id)
          : <InvitationInfo>[];
      if (mounted) {
        setState(() {
          _currentRole = currentRole;
          _members = members;
          _invitations = invitations;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = workspaceError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _action(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (mounted) await _load();
    } catch (e) {
      if (mounted) setState(() => _error = workspaceError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _invite({bool sendEmail = true}) => _action(() async {
    final delivery = sendEmail
        ? await client.workspace.invite(widget.workspace.id, _email.text, _role)
        : await client.workspace.createInvitationLink(
            widget.workspace.id,
            _email.text,
            _role,
          );
    _email.clear();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          delivery.emailSent ? 'Invitation sent' : 'Invitation link ready',
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${delivery.emailSent ? 'Sent to' : 'Created for'} ${delivery.invitation.email} as ${roleLabel(delivery.invitation.role)}. They must sign in with that email to join.',
              ),
              const SizedBox(height: 16),
              const Text(
                'You can also share this link with the same recipient. It expires in seven days.',
              ),
              const SizedBox(height: 12),
              SelectableText(delivery.url),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: delivery.url));
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Invitation link copied.')),
                );
              }
            },
            child: const Text('Copy link'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  });

  Future<void> _remove(MemberInfo member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove team member?'),
        content: Text(
          '${member.email} will lose access to ${widget.workspace.name}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _action(
        () => client.workspace.removeMember(widget.workspace.id, member.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('${widget.workspace.name} · Team')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'A team with the right access',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Admin: manage the workspace, invitations, and members.\nEditor: read, add, and update feedback.\nViewer: read feedback and team details.',
                        style: TextStyle(height: 1.7, color: Color(0xFF64748B)),
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _busy ? null : _load,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      if (_admin) ...[
                        const SizedBox(height: 28),
                        const Text(
                          'Invite a teammate',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _email,
                          enabled: !_busy,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email address',
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<WorkspaceRole>(
                          initialValue: _role,
                          decoration: const InputDecoration(
                            labelText: 'Access role',
                          ),
                          items: [
                            for (final role in WorkspaceRole.values)
                              DropdownMenuItem(
                                value: role,
                                child: Text(roleLabel(role)),
                              ),
                          ],
                          onChanged: _busy
                              ? null
                              : (role) => setState(() => _role = role!),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _busy ? null : () => _invite(),
                          icon: const Icon(Icons.mail_outline),
                          label: Text(
                            _busy ? 'Please wait…' : 'Send invitation',
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _busy
                              ? null
                              : () => _invite(sendEmail: false),
                          icon: const Icon(Icons.link),
                          label: const Text('Create share link'),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Share links work without email delivery. Share only with the email address entered above.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      Text(
                        'Members (${_members.length})',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (final member in _members)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Wrap(
                              spacing: 20,
                              runSpacing: 12,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                SizedBox(
                                  width: 230,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${member.name}${member.isCurrentUser ? ' (you)' : ''}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        member.email,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (_admin)
                                  SizedBox(
                                    width: 145,
                                    child:
                                        DropdownButtonFormField<WorkspaceRole>(
                                          key: ValueKey(
                                            '${member.id}-${member.role}',
                                          ),
                                          initialValue: member.role,
                                          items: [
                                            for (final role
                                                in WorkspaceRole.values)
                                              DropdownMenuItem(
                                                value: role,
                                                child: Text(roleLabel(role)),
                                              ),
                                          ],
                                          onChanged: _busy
                                              ? null
                                              : (role) => _action(
                                                  () => client.workspace
                                                      .changeRole(
                                                        widget.workspace.id,
                                                        member.id,
                                                        role!,
                                                      ),
                                                ),
                                        ),
                                  )
                                else
                                  Text(roleLabel(member.role)),
                                if (_admin)
                                  TextButton(
                                    onPressed: _busy
                                        ? null
                                        : () => _remove(member),
                                    child: const Text('Remove'),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      if (_admin) ...[
                        const SizedBox(height: 32),
                        const Text(
                          'Invitations',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_invitations.isEmpty)
                          const Text('No invitations yet.'),
                        for (final i in _invitations)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Wrap(
                                spacing: 16,
                                runSpacing: 12,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 230,
                                    child: Text(
                                      i.email,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text('${roleLabel(i.role)} · ${i.status}'),
                                  Text(
                                    'Expires ${i.expiresAt.toLocal().toString().split(' ').first}',
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  if (i.status == 'Pending')
                                    TextButton(
                                      onPressed: _busy
                                          ? null
                                          : () => _action(
                                              () => client.workspace
                                                  .revokeInvitation(
                                                    widget.workspace.id,
                                                    i.id,
                                                  ),
                                            ),
                                      child: const Text('Revoke'),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
  );
}
