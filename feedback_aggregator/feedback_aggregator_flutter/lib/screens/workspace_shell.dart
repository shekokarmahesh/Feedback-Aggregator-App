import 'package:feedback_aggregator_client/feedback_aggregator_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import '../client.dart';
import '../models/demo_ticket.dart';
import 'dashboard_screen.dart';
import 'team_screen.dart';

String workspaceError(Object error) => error is WorkspaceException
    ? error.message
    : 'Could not complete this request. Please try again.';
String roleLabel(WorkspaceRole role) => switch (role) {
  WorkspaceRole.admin => 'Admin',
  WorkspaceRole.editor => 'Editor',
  WorkspaceRole.viewer => 'Viewer',
};

class WorkspaceShell extends StatefulWidget {
  final int? initialWorkspaceId;
  const WorkspaceShell({super.key, this.initialWorkspaceId});
  @override
  State<WorkspaceShell> createState() => _WorkspaceShellState();
}

class _WorkspaceShellState extends State<WorkspaceShell> {
  List<WorkspaceSummary> _workspaces = [];
  List<WorkspaceTicket> _tickets = [];
  WorkspaceSummary? _active;
  bool _loading = true;
  String? _error;
  int _loadRevision = 0;

  @override
  void initState() {
    super.initState();
    _load(preferred: widget.initialWorkspaceId);
  }

  Future<void> _load({int? preferred}) async {
    final revision = ++_loadRevision;
    setState(() {
      _loading = true;
      _error = null;
      _tickets = [];
    });
    try {
      final orgs = await client.workspace.list();
      final wanted = preferred ?? _active?.id;
      final active =
          orgs.where((o) => o.id == wanted).firstOrNull ?? orgs.firstOrNull;
      final tickets = active == null
          ? <WorkspaceTicket>[]
          : await client.workspace.tickets(active.id);
      if (!mounted || revision != _loadRevision) return;
      setState(() {
        _workspaces = orgs;
        _active = active;
        _tickets = tickets;
      });
    } catch (e) {
      if (mounted && revision == _loadRevision) {
        setState(() {
          _active = null;
          _error = workspaceError(e);
        });
      }
    } finally {
      if (mounted && revision == _loadRevision) {
        setState(() => _loading = false);
      }
    }
  }

  Future<T?> _showFormDialog<T>({
    required List<TextEditingController> controllers,
    required WidgetBuilder builder,
  }) => showDialog<T>(
    context: context,
    builder: (ctx) =>
        _DialogFields(controllers: controllers, child: builder(ctx)),
  );

  Future<void> _createWorkspace() async {
    final controller = TextEditingController();
    var busy = false;
    String? error;
    final created = await _showFormDialog<WorkspaceSummary>(
      controllers: [controller],
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => AlertDialog(
          title: const Text('Create a workspace'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your workspace is an isolated organization. You will be its first Admin.',
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  maxLength: 80,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Workspace name',
                  ),
                ),
                if (error != null)
                  Text(
                    error!,
                    style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: busy ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: busy
                  ? null
                  : () async {
                      update(() {
                        busy = true;
                        error = null;
                      });
                      try {
                        final org = await client.workspace.create(
                          controller.text,
                        );
                        if (ctx.mounted) Navigator.pop(ctx, org);
                      } catch (e) {
                        if (ctx.mounted) {
                          update(() {
                            error = workspaceError(e);
                            busy = false;
                          });
                        }
                      }
                    },
              child: Text(busy ? 'Creating…' : 'Create workspace'),
            ),
          ],
        ),
      ),
    );
    if (created != null && mounted) await _load(preferred: created.id);
  }

  Future<void> _team() async {
    final org = _active!;
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => TeamScreen(workspace: org)),
    );
    if (mounted) await _load(preferred: org.id);
  }

  Future<void> _createTicket() async {
    final org = _active!;
    final title = TextEditingController();
    final description = TextEditingController();
    var source = 'Forms';
    var priority = 'Medium';
    var busy = false;
    String? error;
    final created = await _showFormDialog<bool>(
      controllers: [title, description],
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => AlertDialog(
          title: const Text('Add feedback'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: title,
                    maxLength: 200,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: description,
                    maxLength: 5000,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: source,
                    decoration: const InputDecoration(labelText: 'Source'),
                    items: [
                      for (final value in ticketSources)
                        DropdownMenuItem(value: value, child: Text(value)),
                    ],
                    onChanged: busy
                        ? null
                        : (value) => update(() => source = value!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: priority,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: [
                      for (final value in ticketPriorities)
                        DropdownMenuItem(value: value, child: Text(value)),
                    ],
                    onChanged: busy
                        ? null
                        : (value) => update(() => priority = value!),
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(ctx).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: busy ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: busy
                  ? null
                  : () async {
                      update(() {
                        busy = true;
                        error = null;
                      });
                      try {
                        await client.workspace.createTicket(
                          org.id,
                          title.text,
                          description.text,
                          source,
                          priority,
                        );
                        if (ctx.mounted) Navigator.pop(ctx, true);
                      } catch (e) {
                        if (ctx.mounted) {
                          update(() {
                            error = workspaceError(e);
                            busy = false;
                          });
                        }
                      }
                    },
              child: Text(busy ? 'Saving…' : 'Add feedback'),
            ),
          ],
        ),
      ),
    );
    if (created == true && mounted) await _load(preferred: org.id);
  }

  Future<void> _updateStatus(DemoTicket ticket, String status) async {
    final org = _active!;
    try {
      await client.workspace.updateTicketStatus(
        org.id,
        int.parse(ticket.id.substring(3)),
        status,
      );
      if (mounted) await _load(preferred: org.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(workspaceError(e))));
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Material(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (_workspaces.isNotEmpty)
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<int>(
                    key: ValueKey(_active?.id),
                    initialValue: _active?.id,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Workspace',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    items: [
                      for (final org in _workspaces)
                        DropdownMenuItem(
                          value: org.id,
                          child: Text(
                            org.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: _loading
                        ? null
                        : (id) {
                            if (id != null) _load(preferred: id);
                          },
                  ),
                ),
              if (_active != null)
                Text(
                  roleLabel(_active!.role),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              TextButton.icon(
                onPressed: _loading ? null : _createWorkspace,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New workspace'),
              ),
              if (_active != null)
                TextButton.icon(
                  onPressed: _loading ? null : _team,
                  icon: const Icon(Icons.group_outlined, size: 18),
                  label: const Text('Team'),
                ),
              IconButton(
                onPressed: _loading ? null : () => _load(),
                tooltip: 'Refresh workspace',
                icon: const Icon(Icons.refresh),
              ),
              if (_active == null)
                TextButton(
                  onPressed: () => client.auth.signOutDevice(),
                  child: const Text('Sign out'),
                ),
            ],
          ),
        ),
      ),
      Expanded(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => _load(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            : _active == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.workspaces_outline,
                        size: 56,
                        color: Color(0xFF4F46E5),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Your team starts here',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Create a workspace, or open an invitation from your email to join an existing team.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _createWorkspace,
                        child: const Text('Create workspace'),
                      ),
                    ],
                  ),
                ),
              )
            : DashboardScreen(
                key: ValueKey(_active!.id),
                workspace: _active,
                tickets: _tickets
                    .map(
                      (t) => DemoTicket(
                        'FB-${t.id}',
                        t.title,
                        t.description,
                        t.source,
                        t.status,
                        t.priority,
                        t.supporters,
                        DateTime.now().toUtc().difference(t.createdAt).inHours,
                        t.requester,
                      ),
                    )
                    .toList(),
                onCreateTicket: _active!.role == WorkspaceRole.viewer
                    ? null
                    : _createTicket,
                onUpdateStatus: _active!.role == WorkspaceRole.viewer
                    ? null
                    : _updateStatus,
                onSignOut: () => client.auth.signOutDevice(),
              ),
      ),
    ],
  );
}

class _DialogFields extends StatefulWidget {
  final List<TextEditingController> controllers;
  final Widget child;
  const _DialogFields({required this.controllers, required this.child});
  @override
  State<_DialogFields> createState() => _DialogFieldsState();
}

class _DialogFieldsState extends State<_DialogFields> {
  @override
  void dispose() {
    for (final controller in widget.controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
