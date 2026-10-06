import 'package:flutter/material.dart';
import '../client.dart';
import '../models/demo_ticket.dart';

class AccountProfile {
  final String name;
  final String email;
  final String id;
  const AccountProfile({
    required this.name,
    required this.email,
    required this.id,
  });
}

Future<AccountProfile> loadAccountProfile() async {
  final profile = await client.modules.serverpod_auth_core.userProfileInfo
      .get();
  return AccountProfile(
    name:
        profile.fullName ??
        profile.userName ??
        profile.email?.split('@').first ??
        'Your account',
    email: profile.email ?? 'Email unavailable',
    id: profile.authUserId.toString(),
  );
}

class DashboardScreen extends StatefulWidget {
  final Future<void> Function() onSignOut;
  final Future<AccountProfile> Function() loadProfile;
  const DashboardScreen({
    super.key,
    required this.onSignOut,
    this.loadProfile = loadAccountProfile,
  });
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _tab = 'Inbox';
  String _query = '';
  String _status = 'All';
  String _source = 'All';
  String _priority = 'All';
  String _sort = 'Most requested';
  final _search = TextEditingController();
  AccountProfile? _profile;
  bool _profileFailed = false;
  bool _signingOut = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _profileFailed = false);
    try {
      final profile = await widget.loadProfile();
      if (mounted) setState(() => _profile = profile);
    } catch (_) {
      if (mounted) setState(() => _profileFailed = true);
    }
  }

  bool get _hasFilters =>
      _query.isNotEmpty ||
      _status != 'All' ||
      _source != 'All' ||
      _priority != 'All';
  void _resetFilters() {
    _search.clear();
    setState(() {
      _query = '';
      _status = 'All';
      _source = 'All';
      _priority = 'All';
    });
  }

  Future<void> _signOut() async {
    setState(() => _signingOut = true);
    try {
      await widget.onSignOut();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not sign out. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  void _showProfile() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your profile'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _avatar(size: 56),
              const SizedBox(height: 24),
              if (_profile != null) ...[
                _detail('Name', _profile!.name),
                _detail('Email', _profile!.email),
                _detail('Account ID', _profile!.id),
              ] else
                Text(
                  _profileFailed
                      ? 'Unable to load your profile. Close this window and use Retry profile in the account menu.'
                      : 'Your profile is loading. Please reopen this window in a moment.',
                ),
            ],
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
  }

  void _showSecurity() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account security'),
        content: const SizedBox(
          width: 400,
          child: Text(
            'Your session belongs to your signed-in account. You can sign in with Google or an email and password.\n\nTo reset an email password, sign out and choose “Forgot password?” on the sign-in screen. A reset code will be sent to your inbox.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: const Color(0xFF64748B)),
        ),
        const SizedBox(height: 5),
        SelectableText(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    ),
  );

  Widget _avatar({double size = 34}) {
    final name = _profile?.name.trim() ?? '';
    final initials = name.isEmpty
        ? '?'
        : name
              .split(RegExp(r'\s+'))
              .take(2)
              .map((word) => word.substring(0, 1))
              .join()
              .toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: const Color(0xFF4F46E5),
          fontSize: size * .36,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _navigation() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final entry in [
        ('Inbox', Icons.inbox_outlined),
        ('Sources', Icons.hub_outlined),
        ('Activity', Icons.history_outlined),
      ])
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: TextButton.icon(
            onPressed: () => setState(() => _tab = entry.$1),
            icon: Icon(entry.$2, size: 18),
            label: Text(entry.$1),
            style: TextButton.styleFrom(
              foregroundColor: _tab == entry.$1
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFF64748B),
              backgroundColor: _tab == entry.$1
                  ? const Color(0xFFEEF2FF)
                  : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
    ],
  );

  Widget _topBar(bool wide) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
    ),
    padding: EdgeInsets.symmetric(horizontal: wide ? 40 : 16, vertical: 16),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.forum_rounded,
                color: Colors.white,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Feedback',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -.6,
              ),
            ),
            const Spacer(),
            if (wide) _navigation(),
            const Spacer(),
            if (_signingOut)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              PopupMenuButton<String>(
                tooltip: 'Account menu',
                offset: const Offset(0, 52),
                onSelected: (value) {
                  switch (value) {
                    case 'profile':
                      _showProfile();
                    case 'security':
                      _showSecurity();
                    case 'retry':
                      _loadProfile();
                    case 'signout':
                      _signOut();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _profile?.name ?? 'Your account',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _profile?.email ??
                              (_profileFailed
                                  ? 'Profile unavailable'
                                  : 'Loading profile…'),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'profile',
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.person_outline),
                      title: Text('View profile'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'security',
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.shield_outlined),
                      title: Text('Account security'),
                    ),
                  ),
                  if (_profileFailed)
                    const PopupMenuItem(
                      value: 'retry',
                      child: Text('Retry profile'),
                    ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'signout',
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.logout, color: Color(0xFFDC2626)),
                      title: Text(
                        'Sign out',
                        style: TextStyle(color: Color(0xFFDC2626)),
                      ),
                    ),
                  ),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _avatar(),
                    if (wide) ...[
                      const SizedBox(width: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 140),
                        child: Text(
                          _profile?.name ?? 'Your account',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                    const SizedBox(width: 6),
                    const Icon(Icons.keyboard_arrow_down, size: 18),
                  ],
                ),
              ),
          ],
        ),
        if (!wide) ...[
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _navigation(),
          ),
        ],
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= 850;
      return Column(
        children: [
          _topBar(wide),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1360),
                  child: Padding(
                    padding: EdgeInsets.all(wide ? 40 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'PERSONAL WORKSPACE',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    letterSpacing: 1.4,
                                    color: const Color(0xFF64748B),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            _pill('Sample data', const Color(0xFF7C3AED)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _tab == 'Inbox'
                            ? _inbox(wide)
                            : _tab == 'Sources'
                            ? _sources(wide)
                            : _activity(),
                        const SizedBox(height: 28),
                        const Text(
                          'Built for better product decisions. All tickets shown are sample data.',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );

  Widget _heading(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          letterSpacing: -.8,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        subtitle,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 15,
          height: 1.5,
        ),
      ),
    ],
  );

  Widget _inbox(bool wide) {
    final tickets = filterTickets(
      query: _query,
      status: _status,
      source: _source,
      priority: _priority,
      sort: _sort,
    );
    final open = demoTickets.where((t) => t.status != 'Resolved').length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 20,
          runSpacing: 16,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _heading(
              'Feedback inbox',
              'Turn scattered support conversations into a clear product roadmap.',
            ),
            OutlinedButton.icon(
              onPressed: () => setState(() => _tab = 'Sources'),
              icon: const Icon(Icons.hub_outlined, size: 18),
              label: const Text('Manage sources'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 900
                ? 4
                : constraints.maxWidth > 450
                ? 2
                : 1;
            final width = (constraints.maxWidth - (columns - 1) * 16) / columns;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _metric(
                  'Feedback groups',
                  '${demoTickets.length}',
                  'Similar requests, brought together',
                  Icons.layers_outlined,
                  const Color(0xFF4F46E5),
                  width,
                ),
                _metric(
                  'Customer requests',
                  '${demoTickets.fold<int>(0, (sum, t) => sum + t.supporters)}',
                  'People behind the feedback',
                  Icons.people_outline,
                  const Color(0xFF0891B2),
                  width,
                ),
                _metric(
                  'Active tickets',
                  '$open',
                  'Open, planned, or in progress',
                  Icons.confirmation_number_outlined,
                  const Color(0xFFD97706),
                  width,
                ),
                _metric(
                  'Sources represented',
                  '${ticketSources.length}',
                  'Across your sample inbox',
                  Icons.hub_outlined,
                  const Color(0xFF059669),
                  width,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        _surface(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'All feedback',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        _pill('${tickets.length}', const Color(0xFF64748B)),
                        if (_hasFilters)
                          TextButton(
                            onPressed: _resetFilters,
                            child: const Text('Clear filters'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _search,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: 'Search tickets, requests, or people…',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear search',
                                onPressed: () {
                                  _search.clear();
                                  setState(() => _query = '');
                                },
                                icon: const Icon(Icons.close, size: 18),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _filter(
                          'Status',
                          _status,
                          ticketStatuses,
                          (value) => setState(() => _status = value),
                        ),
                        _filter(
                          'Source',
                          _source,
                          ticketSources,
                          (value) => setState(() => _source = value),
                        ),
                        _filter(
                          'Priority',
                          _priority,
                          ticketPriorities,
                          (value) => setState(() => _priority = value),
                        ),
                        _filter(
                          'Sort',
                          _sort,
                          ['Most requested', 'Most recent', 'Priority'],
                          (value) => setState(() => _sort = value),
                          includeAll: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (wide)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  color: const Color(0xFFF8FAFC),
                  child: const Row(
                    children: [
                      Expanded(child: Text('FEEDBACK', style: _columnStyle)),
                      SizedBox(
                        width: 115,
                        child: Text('SOURCE', style: _columnStyle),
                      ),
                      SizedBox(
                        width: 120,
                        child: Text('STATUS', style: _columnStyle),
                      ),
                      SizedBox(
                        width: 95,
                        child: Text('PRIORITY', style: _columnStyle),
                      ),
                      SizedBox(
                        width: 90,
                        child: Text('REQUESTS', style: _columnStyle),
                      ),
                      SizedBox(
                        width: 85,
                        child: Text('UPDATED', style: _columnStyle),
                      ),
                      SizedBox(width: 20),
                    ],
                  ),
                ),
              if (tickets.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(48),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 42,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No feedback matches',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try a different search or clear your filters.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: _resetFilters,
                          child: const Text('Reset filters'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                for (final ticket in tickets) _ticketRow(ticket, wide),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Showing ${tickets.length} of ${demoTickets.length} feedback groups',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static const _columnStyle = TextStyle(
    fontSize: 10,
    letterSpacing: 1,
    fontWeight: FontWeight.w700,
    color: Color(0xFF64748B),
  );
  Widget _surface(Widget child) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE2E8F0)),
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );
  Widget _metric(
    String label,
    String value,
    String hint,
    IconData icon,
    Color color,
    double width,
  ) => SizedBox(
    width: width,
    child: _surface(
      Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(icon, color: color, size: 22),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hint,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _filter(
    String label,
    String value,
    List<String> choices,
    ValueChanged<String> onChanged, {
    bool includeAll = true,
  }) => SizedBox(
    width: label == 'Sort' ? 190 : 160,
    child: DropdownButtonFormField<String>(
      initialValue: value,
      key: ValueKey('$label-$value'),
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      items: [
        if (includeAll)
          DropdownMenuItem(
            value: 'All',
            child: Text('All ${label.toLowerCase()}'),
          ),
        for (final choice in choices)
          DropdownMenuItem(value: choice, child: Text(choice)),
      ],
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    ),
  );

  Widget _pill(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
    ),
  );
  Color _statusColor(String value) => switch (value) {
    'Planned' => const Color(0xFF7C3AED),
    'In progress' => const Color(0xFF2563EB),
    'Resolved' => const Color(0xFF059669),
    _ => const Color(0xFF64748B),
  };
  Color _priorityColor(String value) => switch (value) {
    'High' => const Color(0xFFDC2626),
    'Medium' => const Color(0xFFD97706),
    _ => const Color(0xFF64748B),
  };
  IconData _sourceIcon(String value) => switch (value) {
    'Slack' => Icons.tag,
    'Email' => Icons.mail_outline,
    'Forms' => Icons.article_outlined,
    'Support' => Icons.headset_mic_outlined,
    _ => Icons.star_outline,
  };

  Widget _ticketRow(DemoTicket ticket, bool wide) => Material(
    color: Colors.white,
    child: InkWell(
      onTap: () => _openTicket(ticket),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: wide
            ? Row(
                children: [
                  Expanded(child: _ticketTitle(ticket)),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 115,
                    child: Row(
                      children: [
                        Icon(
                          _sourceIcon(ticket.source),
                          size: 15,
                          color: const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            ticket.source,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _pill(ticket.status, _statusColor(ticket.status)),
                    ),
                  ),
                  SizedBox(
                    width: 95,
                    child: Text(
                      ticket.priority,
                      style: TextStyle(
                        fontSize: 12,
                        color: _priorityColor(ticket.priority),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${ticket.supporters}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 85,
                    child: Text(
                      _updated(ticket),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Color(0xFFCBD5E1),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ticketTitle(ticket),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _pill(ticket.source, const Color(0xFF64748B)),
                      _pill(ticket.status, _statusColor(ticket.status)),
                      _pill(ticket.priority, _priorityColor(ticket.priority)),
                      _pill(
                        '${ticket.supporters} requests',
                        const Color(0xFF4F46E5),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    ),
  );

  Widget _ticketTitle(DemoTicket ticket) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        ticket.title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 7),
      Text(
        '${ticket.id} · ${ticket.requester}',
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
      ),
    ],
  );
  String _updated(DemoTicket ticket) => ticket.hoursAgo < 24
      ? '${ticket.hoursAgo}h ago'
      : '${ticket.hoursAgo ~/ 24}d ago';

  void _openTicket(DemoTicket ticket) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    ticket.id,
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                  const Spacer(),
                  _pill('Sample ticket', const Color(0xFF7C3AED)),
                  IconButton(
                    tooltip: 'Close ticket',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ticket.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _pill(ticket.status, _statusColor(ticket.status)),
                  _pill(
                    '${ticket.priority} priority',
                    _priorityColor(ticket.priority),
                  ),
                  _pill(ticket.source, const Color(0xFF64748B)),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'What customers are saying',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Text(
                ticket.description,
                style: const TextStyle(height: 1.7, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 28),
              _detail('First reported by', ticket.requester),
              _detail(
                'Requests grouped together',
                '${ticket.supporters} customer requests',
              ),
              _detail('Last updated', _updated(ticket)),
              const Text(
                'This is a preview of a grouped support ticket. Live feedback ingestion and status changes will be connected later.',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _sources(bool wide) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading(
        'Feedback sources',
        'A shared inbox for every place your customers talk to you.',
      ),
      const SizedBox(height: 24),
      _surface(
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF4F46E5)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'These are planned integrations. Sample tickets show how each source will appear once connected.',
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      for (final source in ticketSources)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _surface(
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _sourceIcon(source),
                      color: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          source,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${demoTickets.where((t) => t.source == source).length} sample feedback groups',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _pill('Not connected', const Color(0xFF64748B)),
                ],
              ),
            ),
          ),
        ),
    ],
  );

  Widget _activity() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading(
        'Workspace activity',
        'A preview of how feedback moves from a request to a release.',
      ),
      const SizedBox(height: 24),
      _surface(
        Column(
          children: [
            for (final ticket in demoTickets.where((t) => t.status != 'Open'))
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                leading: Icon(
                  ticket.status == 'Resolved'
                      ? Icons.check_circle_outline
                      : Icons.update,
                  color: _statusColor(ticket.status),
                ),
                title: Text(
                  ticket.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${ticket.id} moved to ${ticket.status.toLowerCase()} · Sample activity',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                trailing: Text(
                  _updated(ticket),
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}
