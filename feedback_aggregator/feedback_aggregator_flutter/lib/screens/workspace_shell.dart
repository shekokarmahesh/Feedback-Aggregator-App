import 'dart:async';

import 'package:feedback_aggregator_client/feedback_aggregator_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import '../client.dart';
import '../models/demo_ticket.dart';
import 'dashboard_screen.dart';
import 'team_screen.dart';
import 'discord_config_screen.dart';

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
  final Client? apiClient;
  const WorkspaceShell({super.key, this.initialWorkspaceId, this.apiClient});
  @override
  State<WorkspaceShell> createState() => _WorkspaceShellState();
}

class _WorkspaceShellState extends State<WorkspaceShell> {
  Client get _client => widget.apiClient ?? client;
  List<WorkspaceSummary> _workspaces = [];
  List<WorkspaceTicket> _tickets = [];
  WorkspaceSummary? _active;
  String? _discordGuild;
  List<MockSourceConnection> _sourceConnections = [];
  Set<String> _syncingSources = {};
  Map<String, String> _sourceSyncErrors = {};
  String? _refreshError;
  Timer? _syncTimer;
  bool _autoSyncing = false;
  final _mutatingSources = <String>{};
  int _refreshRevision = 0;
  bool _loading = true;
  String? _error;
  int _loadRevision = 0;

  List<WorkspaceTicket> _visibleTickets(
    List<WorkspaceTicket> rows,
    List<MockSourceConnection> connections,
  ) {
    final hidden = connections
        .where((c) => !c.connected)
        .map((c) => c.source)
        .toSet();
    return rows.where((ticket) => !hidden.contains(ticket.source)).toList();
  }

  @override
  void initState() {
    super.initState();
    _load(preferred: widget.initialWorkspaceId);
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (_loading ||
          _active == null ||
          _autoSyncing ||
          _mutatingSources.isNotEmpty) {
        return;
      }
      _autoSyncing = true;
      try {
        await _refreshActive(syncDemo: true);
      } finally {
        _autoSyncing = false;
      }
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({int? preferred}) async {
    final revision = ++_loadRevision;
    ++_refreshRevision;
    setState(() {
      _loading = true;
      _error = null;
      _tickets = [];
      _discordGuild = null;
      _sourceConnections = [];
      _syncingSources = {};
      _sourceSyncErrors = {};
      _refreshError = null;
    });
    try {
      final orgs = await _client.workspace.list();
      final wanted = preferred ?? _active?.id;
      final active =
          orgs.where((o) => o.id == wanted).firstOrNull ?? orgs.firstOrNull;
      final tickets = active == null
          ? <WorkspaceTicket>[]
          : await _client.workspace.tickets(active.id);
      final guild = active == null
          ? null
          : await _client.workspace.discordGuild(active.id);
      final connections = active == null
          ? <MockSourceConnection>[]
          : await _client.sources.list(active.id);
      if (!mounted || revision != _loadRevision) return;
      setState(() {
        _workspaces = orgs;
        _active = active;
        _tickets = _visibleTickets(tickets, connections);
        _discordGuild = guild;
        _sourceConnections = connections;
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

  /// Background refresh keeps the current tab, filters, and scroll position.
  /// A request started in one workspace can never replace a different tenant.
  Future<void> _refreshActive({bool syncDemo = false}) async {
    final org = _active;
    if (org == null || _loading) return;
    final loadRevision = _loadRevision;
    final revision = ++_refreshRevision;
    bool current() =>
        mounted &&
        loadRevision == _loadRevision &&
        revision == _refreshRevision &&
        org.id == _active?.id;
    try {
      final orgs = await _client.workspace.list();
      if (!current()) return;
      final active = orgs.where((o) => o.id == org.id).firstOrNull;
      if (active == null) {
        await _load();
        return;
      }
      var connections = await _client.sources.list(org.id);
      if (!current()) return;
      final errors = <String, String>{};
      if (syncDemo && active.role != WorkspaceRole.viewer) {
        final pending = connections
            .where((c) => c.connected && c.syncedCount < c.availableCount)
            .toList();
        setState(() => _syncingSources = pending.map((c) => c.source).toSet());
        for (final connection in pending) {
          if (!current()) return;
          try {
            await _client.sources.sync(org.id, connection.source);
          } catch (error) {
            errors[connection.source] = workspaceError(error);
          }
        }
        connections = await _client.sources.list(org.id);
      }
      if (!current()) return;
      final tickets = await _client.workspace.tickets(org.id);
      final guild = await _client.workspace.discordGuild(org.id);
      if (!current()) return;
      setState(() {
        _workspaces = orgs;
        _active = active;
        _tickets = _visibleTickets(tickets, connections);
        _discordGuild = guild;
        _sourceConnections = connections;
        _sourceSyncErrors = errors;
        _refreshError = null;
      });
    } catch (error) {
      if (current()) {
        if (error is WorkspaceException &&
            error.message == 'Workspace access denied.') {
          await _load();
        } else {
          setState(() => _refreshError = workspaceError(error));
        }
      }
    } finally {
      if (current()) setState(() => _syncingSources = {});
    }
  }

  Future<SourceSyncResult> _connectSource(String source) async {
    return _changeSource(
      source,
      () => _client.sources.connect(_active!.id, source),
    );
  }

  Future<SourceSyncResult> _configureSource(
    String source,
    String demoKey,
  ) async {
    return _changeSource(
      source,
      () => _client.sources.configure(_active!.id, source, demoKey),
    );
  }

  Future<SourceSyncResult> _changeSource(
    String source,
    Future<SourceSyncResult> Function() action,
  ) async {
    final org = _active!;
    final revision = _loadRevision;
    ++_refreshRevision;
    _mutatingSources.add(source);
    try {
      final result = await action();
      if (mounted && revision == _loadRevision && org.id == _active?.id) {
        _acceptConnection(result.connection);
        await _refreshActive();
      }
      return result;
    } finally {
      _mutatingSources.remove(source);
    }
  }

  Future<SourceSyncResult> _syncSource(String source) async {
    return _changeSource(
      source,
      () => _client.sources.sync(_active!.id, source),
    );
  }

  Future<void> _disconnectSource(String source) async {
    final org = _active!;
    final revision = _loadRevision;
    ++_refreshRevision;
    _mutatingSources.add(source);
    try {
      final connection = await _client.sources.disconnect(org.id, source);
      if (mounted && revision == _loadRevision && org.id == _active?.id) {
        _acceptConnection(connection);
        await _refreshActive();
      }
    } finally {
      _mutatingSources.remove(source);
    }
  }

  void _acceptConnection(MockSourceConnection connection) {
    ++_refreshRevision;
    setState(() {
      _sourceConnections = [
        ..._sourceConnections.where((c) => c.source != connection.source),
        connection,
      ];
      _sourceSyncErrors.remove(connection.source);
      _syncingSources.remove(connection.source);
      if (!connection.connected) {
        _tickets.removeWhere((ticket) => ticket.source == connection.source);
      }
    });
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
                        final org = await _client.workspace.create(
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

  Future<void> _discord() async {
    final org = _active!;
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DiscordConfigScreen(workspace: org),
      ),
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
                        await _client.workspace.createTicket(
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
      await _client.workspace.updateTicketStatus(
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
                onPressed: _loading
                    ? null
                    : () => _active == null ? _load() : _refreshActive(),
                tooltip: 'Refresh workspace',
                icon: const Icon(Icons.refresh),
              ),
              if (_refreshError != null)
                Text(
                  _refreshError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              if (_active == null)
                TextButton(
                  onPressed: () => _client.auth.signOutDevice(),
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
                loadProfile: () => loadAccountProfileForClient(_client),
                discordGuildId: _discordGuild,
                sourceConnections: _sourceConnections,
                syncingSources: _syncingSources,
                sourceSyncErrors: _sourceSyncErrors,
                onConnectSource: _active!.role == WorkspaceRole.admin
                    ? _connectSource
                    : null,
                onConfigureSource: _active!.role == WorkspaceRole.admin
                    ? _configureSource
                    : null,
                onSyncSource: _active!.role == WorkspaceRole.viewer
                    ? null
                    : _syncSource,
                onDisconnectSource: _active!.role == WorkspaceRole.admin
                    ? _disconnectSource
                    : null,
                onConfigureDiscord: _active!.role == WorkspaceRole.admin
                    ? _discord
                    : null,
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
                        isMock: t.isMock,
                      ),
                    )
                    .toList(),
                onCreateTicket: _active!.role == WorkspaceRole.viewer
                    ? null
                    : _createTicket,
                onUpdateStatus: _active!.role == WorkspaceRole.viewer
                    ? null
                    : _updateStatus,
                onSignOut: () => _client.auth.signOutDevice(),
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
