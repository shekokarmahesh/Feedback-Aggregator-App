import 'dart:convert';
import 'package:feedback_aggregator_client/feedback_aggregator_client.dart';
import 'package:flutter/material.dart';
import '../client.dart';

typedef PocRequest =
    Future<Map<String, dynamic>> Function(
      String method,
      Map<String, dynamic> arguments,
    );

Future<Map<String, dynamic>> requestLayaPoc(
  String method,
  Map<String, dynamic> arguments,
) async =>
    jsonDecode(
          await client.callServerEndpoint<String>('layaPoc', method, arguments),
        )
        as Map<String, dynamic>;

/// Synthetic feedback only. Results are shared inside the selected workspace.
class LayaPocPanel extends StatefulWidget {
  final WorkspaceSummary workspace;
  final PocRequest request;
  const LayaPocPanel({
    super.key,
    required this.workspace,
    this.request = requestLayaPoc,
  });
  @override
  State<LayaPocPanel> createState() => _LayaPocPanelState();
}

class _LayaPocPanelState extends State<LayaPocPanel> {
  static const _sources = ['Discord', 'Slack', 'Email', 'Forms', 'Support'];
  final _selected = _sources.toSet();
  Map<String, dynamic>? _snapshot;
  String? _error;
  bool _busy = false;
  bool _disposed = false;
  String _query = '';
  String _source = 'All';
  String _status = 'All';
  String _view = 'Grouped issues';
  bool get _canWrite => widget.workspace.role != WorkspaceRole.viewer;
  Map<String, dynamic>? get _run => _snapshot?['run'] as Map<String, dynamic>?;
  List<Map<String, dynamic>> _maps(dynamic value) =>
      (value as List? ?? []).cast<Map<String, dynamic>>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<Map<String, dynamic>> _request(
    String method, [
    Map<String, dynamic> arguments = const {},
  ]) => widget.request(method, {
    'workspaceId': widget.workspace.id,
    ...arguments,
  });

  String _message(Object e) => e is WorkspaceException
      ? e.message
      : 'Could not reach the POC. Refresh and try again.';

  Future<void> _load() async {
    try {
      final snapshot = await _request('read');
      if (mounted) {
        setState(() {
          _snapshot = snapshot;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = _message(e));
    }
  }

  Future<void> _evaluate({bool restart = false}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      var snapshot = _snapshot!;
      if (_run == null || _run!['complete'] == true || restart) {
        snapshot = await _request('start', {'sources': _selected.toList()});
        if (!mounted) return;
        setState(() => _snapshot = snapshot);
      }
      while (!_disposed && (snapshot['run'] as Map)['complete'] != true) {
        final run = snapshot['run'] as Map<String, dynamic>;
        snapshot = await _request('step', {
          'runId': run['id'],
          'expectedIndex': run['processed'],
        });
        if (!mounted) return;
        setState(() => _snapshot = snapshot);
        if ((snapshot['run'] as Map)['busy'] == true) {
          // Another team member is advancing this shared run; avoid polling.
          break;
        }
      }
    } catch (e) {
      if (mounted) setState(() => _error = _message(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setStatus(Map<String, dynamic> issue, String status) async {
    final run = _run!;
    try {
      final snapshot = await _request('updateStatus', {
        'runId': run['id'],
        'issueId': issue['id'],
        'status': status,
      });
      if (mounted) {
        setState(() {
          _snapshot = snapshot;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = _message(e));
    }
  }

  Widget _card(Widget child, {Color color = Colors.white}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: child,
  );

  Widget _badge(String label, [Color color = const Color(0xFF4F46E5)]) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  String _percent(dynamic value) =>
      value == null ? '—' : '${((value as num) * 100).toStringAsFixed(1)}%';

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    if (snapshot == null) {
      return _card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Laya feedback lab',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            if (_error != null) ...[
              Text(_error!),
              TextButton(onPressed: _load, child: const Text('Retry')),
            ] else
              const LinearProgressIndicator(),
          ],
        ),
      );
    }
    final run = _run;
    final samples = _maps(snapshot['samples']);
    final decisions = _maps(run?['decisions']);
    final metrics = run?['metrics'] as Map? ?? {};
    final complete = run?['complete'] == true;
    final available = snapshot['available'] == true;
    final processed = run?['processed'] as int? ?? 0;
    final total =
        run?['total'] as int? ??
        samples.where((r) => _selected.contains(r['source'])).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'Laya feedback lab',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -.8,
              ),
            ),
            _badge('POC · Synthetic data'),
            _badge(
              available ? 'Local model ready' : 'Local model offline',
              available ? const Color(0xFF047857) : const Color(0xFFB45309),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Different channels. One issue. Test whether Laya finds the duplicates your team should address together.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 24),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sample integrations',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select channels for the next run. These cards load generated feedback; no real accounts are connected.',
                style: TextStyle(color: Color(0xFF64748B), height: 1.5),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, c) {
                  final columns = c.maxWidth > 850
                      ? 5
                      : c.maxWidth > 500
                      ? 3
                      : c.maxWidth > 300
                      ? 2
                      : 1;
                  final width = (c.maxWidth - (columns - 1) * 12) / columns;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final source in _sources)
                        SizedBox(
                          width: width,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _busy || !_canWrite
                                ? null
                                : () => setState(() {
                                    _selected.contains(source)
                                        ? _selected.remove(source)
                                        : _selected.add(source);
                                  }),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _selected.contains(source)
                                    ? const Color(0xFFF5F3FF)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selected.contains(source)
                                      ? const Color(0xFFC4B5FD)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        switch (source) {
                                          'Email' => Icons.mail_outline,
                                          'Forms' => Icons.description_outlined,
                                          'Support' => Icons.support_agent,
                                          _ => Icons.forum_outlined,
                                        },
                                        size: 24,
                                        color: const Color(0xFF4F46E5),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        _selected.contains(source)
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        size: 18,
                                        color: const Color(0xFF7C3AED),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    source,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${samples.where((r) => r['source'] == source).length} sample reports',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Demo source',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed:
                        _busy || !_canWrite || !available || _selected.isEmpty
                        ? null
                        : () => _evaluate(),
                    icon: Icon(
                      _busy ? Icons.hourglass_top : Icons.auto_awesome,
                      size: 18,
                    ),
                    label: Text(
                      _busy
                          ? 'Evaluating $processed / $total'
                          : run != null && !complete
                          ? 'Resume Laya run'
                          : 'Run Laya grouping',
                    ),
                  ),
                  if (run != null)
                    OutlinedButton(
                      onPressed:
                          _busy || !_canWrite || !available || _selected.isEmpty
                          ? null
                          : () => _evaluate(restart: true),
                      child: const Text('Start fresh run'),
                    ),
                  TextButton.icon(
                    onPressed: _busy ? null : _load,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Refresh team results'),
                  ),
                ],
              ),
              if (_busy || run != null && !complete) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: total == 0 ? 0 : processed / total,
                ),
                const SizedBox(height: 8),
                Text(
                  '$processed of $total reports evaluated. You can leave and resume later.',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
              if (!_canWrite)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Viewer access: you can inspect results. An Admin or Editor can run Laya and update issue status.',
                  ),
                ),
              if (!available)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Start the local Laya model service, then refresh. No paid API key or channel credentials are needed.',
                  ),
                ),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          _card(
            Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
            color: const Color(0xFFFEF2F2),
          ),
        ],
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, c) {
            final columns = c.maxWidth > 900
                ? 4
                : c.maxWidth > 450
                ? 2
                : 1;
            final width = (c.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final stat in [
                  (
                    'Reports evaluated',
                    '$processed / $total',
                    '${samples.length} generated reports available',
                  ),
                  (
                    'Grouped issues',
                    '${_maps(run?['issues']).length}',
                    '${metrics['mergedCount'] ?? 0} repeat reports consolidated',
                  ),
                  (
                    'Merge precision',
                    _percent(metrics['precision']),
                    '${metrics['falseMergePairs'] ?? 0} incorrect merged pairs',
                  ),
                  (
                    'Duplicate recall',
                    _percent(metrics['recall']),
                    '${metrics['reviewCount'] ?? 0} reports need human review',
                  ),
                ])
                  SizedBox(
                    width: width,
                    child: _card(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stat.$1,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            stat.$2,
                            style: const TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            stat.$3,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final view in [
                    'Grouped issues',
                    'Original reports',
                    'Needs review',
                  ])
                    ChoiceChip(
                      label: Text(
                        view == 'Needs review'
                            ? '$view (${metrics['reviewCount'] ?? 0})'
                            : view,
                      ),
                      selected: _view == view,
                      onSelected: (_) => setState(() => _view = view),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width < 500 ? 200 : 260,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search feedback',
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                      ),
                      onChanged: (s) =>
                          setState(() => _query = s.toLowerCase().trim()),
                    ),
                  ),
                  DropdownButton<String>(
                    value: _source,
                    items: ['All', ..._sources]
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(s == 'All' ? 'All channels' : s),
                          ),
                        )
                        .toList(),
                    onChanged: (s) => setState(() => _source = s!),
                  ),
                  if (_view == 'Grouped issues')
                    DropdownButton<String>(
                      value: _status,
                      items:
                          ['All', 'Open', 'Planned', 'In progress', 'Resolved']
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s == 'All' ? 'All statuses' : s),
                                ),
                              )
                              .toList(),
                      onChanged: (s) => setState(() => _status = s!),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (_view == 'Grouped issues')
                _issuesTable(run)
              else
                _reportsList(
                  samples,
                  decisions,
                  reviewOnly: _view == 'Needs review',
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                complete
                    ? 'Completed synthetic benchmark'
                    : 'How this experiment is evaluated',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Merge precision counts correct same-issue pairs among all merged pairs. Recall counts recovered duplicate pairs among evaluated, labeled reports, including misses sent to review. Vague reports are excluded from these two metrics. ${complete ? '' : 'Metrics are provisional until the run finishes.'}',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  height: 1.5,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Priority /100: severity up to 40 + distinct reporters up to 30 (cap 10) + reports in the last 24 hours up to 20 (cap 5) + channel breadth up to 10. High-confidence critical incidents get a minimum of 95. Matching confidence is separate from priority.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  height: 1.5,
                  fontSize: 12,
                ),
              ),
              if (processed > 0) ...[
                const SizedBox(height: 8),
                Text(
                  '${run?['actualModel']} · ${run?['inputTokens']} input tokens · API time ${((run?['latencyMs'] as num? ?? 0) / 1000).toStringAsFixed(1)}s · API fees ${run?['costUsd'] == null ? 'unavailable' : '\$${(run!['costUsd'] as num).toStringAsFixed(6)}'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              const Text(
                'POC results and statuses are shared with this workspace and clear when the backend restarts. Live tickets are unchanged. Synthetic results do not establish accuracy on real customer feedback.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  height: 1.5,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _issuesTable(Map<String, dynamic>? run) {
    final issues = _maps(run?['issues'])
        .where(
          (i) =>
              (_source == 'All' || (i['sources'] as List).contains(_source)) &&
              (_status == 'All' || i['status'] == _status) &&
              '${i['title']} ${i['description']}'.toLowerCase().contains(
                _query,
              ),
        )
        .toList();
    if (issues.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Text(
          run == null
              ? 'Run Laya to turn these reports into grouped issues. No AI results have been generated yet.'
              : 'No grouped issues match. Check Original reports or Needs review.',
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
        dataRowMinHeight: 76,
        dataRowMaxHeight: 96,
        columnSpacing: 24,
        columns: const [
          DataColumn(label: Text('Issue')),
          DataColumn(label: Text('Priority')),
          DataColumn(label: Text('Reports / people')),
          DataColumn(label: Text('Channels')),
          DataColumn(label: Text('Answer confidence')),
          DataColumn(label: Text('Status')),
        ],
        rows: [
          for (final issue in issues)
            DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 280,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () => _showIssue(issue),
                      child: Text(
                        issue['title'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _badge(
                        '${issue['score']} / 100',
                        (issue['score'] as num) >= 70
                            ? const Color(0xFFB91C1C)
                            : const Color(0xFFB45309),
                      ),
                      if (issue['severityNeedsReview'] == true)
                        const Text(
                          'Review severity',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFB45309),
                          ),
                        ),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    '${issue['reportCount']} reports\n${issue['uniqueReporters']} people',
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 150,
                    child: Text(
                      (issue['sources'] as List).join(' · '),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                DataCell(Text(_percent(issue['confidence']))),
                DataCell(
                  _canWrite
                      ? DropdownButton<String>(
                          value: issue['status'] as String,
                          items: ['Open', 'Planned', 'In progress', 'Resolved']
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    s,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: _busy
                              ? null
                              : (s) {
                                  if (s != null) _setStatus(issue, s);
                                },
                        )
                      : Text(issue['status'] as String),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _reportsList(
    List<Map<String, dynamic>> samples,
    List<Map<String, dynamic>> decisions, {
    bool reviewOnly = false,
  }) {
    final byId = {for (final d in decisions) d['reportId']: d};
    final reports = samples
        .where(
          (r) =>
              (!reviewOnly || byId[r['id']]?['outcome'] == 'review') &&
              (_source == 'All' || r['source'] == _source) &&
              '${r['title']} ${r['text']}'.toLowerCase().contains(_query),
        )
        .toList();
    if (reports.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text('No reports match this view.'),
      );
    }
    return Column(
      children: [
        for (final report in reports)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _badge(report['source'] as String),
                    _badge(report['id'] as String, const Color(0xFF64748B)),
                    _badge(switch (byId[report['id']]?['outcome']) {
                      'merged' => 'Merged → ${byId[report['id']]?['issueId']}',
                      'new' => 'New issue → ${byId[report['id']]?['issueId']}',
                      'noise' => 'Chatter',
                      'review' => 'Needs review',
                      _ => 'Not evaluated',
                    }, const Color(0xFF047857)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  report['text'] as String,
                  style: const TextStyle(height: 1.5),
                ),
                const SizedBox(height: 6),
                Text(
                  '${report['reporterId']} · ${report['hoursAgo']} hours ago${byId[report['id']] == null ? '' : ' · Answer confidence ${_percent(byId[report['id']]?['confidence'])}'}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
                if (byId[report['id']] != null)
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text(
                      'Inspect Laya decision',
                      style: TextStyle(fontSize: 12),
                    ),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SelectableText(
                          const JsonEncoder.withIndent(
                            '  ',
                          ).convert(byId[report['id']]),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                const Divider(),
              ],
            ),
          ),
      ],
    );
  }

  void _showIssue(Map<String, dynamic> issue) {
    final reports = _maps(
      _snapshot?['samples'],
    ).where((r) => (issue['reportIds'] as List).contains(r['id'])).toList();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(issue['title'] as String),
        content: SizedBox(
          width: 640,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${issue['reportCount']} reports · ${issue['uniqueReporters']} identified people · ${(issue['sources'] as List).length} channels',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  'Priority ${issue['score']}/100 · ${_percent(issue['confidence'])} minimum answer confidence',
                ),
                const SizedBox(height: 8),
                Text('Score components: ${issue['scoreBreakdown']}'),
                const SizedBox(height: 8),
                const Text(
                  'The issue title is taken from its first report; Laya selects matches and does not write summaries.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 20),
                for (final report in reports)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _badge(report['source'] as String),
                        const SizedBox(height: 8),
                        Text(report['text'] as String),
                        const SizedBox(height: 5),
                        Text(
                          '${report['reporterId']} · ${report['hoursAgo']}h ago',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
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
}
