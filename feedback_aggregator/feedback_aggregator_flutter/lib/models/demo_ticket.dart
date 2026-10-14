import 'dart:math';
import 'package:feedback_aggregator_client/feedback_aggregator_client.dart';

class DemoTicket {
  final String id;
  final String title;
  final String description;
  final String source;
  final String status;
  final String priority;
  final int supporters;
  final int hoursAgo;
  final String requester;
  final bool isMock;
  final List<String> platforms;
  final List<WorkspaceTicket> reports;
  final int priorityScore;
  final String groupingState;
  final double? confidence;
  final int? primaryTicketId;
  List<String> get sources => platforms.isEmpty ? [source] : platforms;
  int reportsFrom(String name) => reports.isEmpty
      ? (source == name ? supporters : 0)
      : reports.where((r) => r.source == name).length;

  static DemoTicket? fromGroup(GroupedTicket group, Set<String> hidden) {
    final visible = group.reports
        .where((r) => !hidden.contains(r.source))
        .toList();
    if (visible.isEmpty) return null;
    final first = visible.first;
    final sources = visible.map((r) => r.source).toSet().toList()..sort();
    final severity = visible
        .map(
          (r) =>
              r.severity ??
              switch (r.priority) {
                'High' => 3.0,
                'Medium' => 2.0,
                _ => 1.0,
              },
        )
        .reduce(max);
    final score =
        ((25 * severity / 4).round() +
                min(45, visible.length * 5) +
                min(30, sources.length * 6))
            .clamp(0, 100);
    final created = visible
        .map((r) => r.createdAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    return DemoTicket(
      group.id > 0 ? 'ISS-${group.id}' : 'FB-${first.id}',
      first.title,
      first.description,
      sources.join(' + '),
      group.status,
      visible.any((r) => r.priority == 'High')
          ? 'High'
          : visible.any((r) => r.priority == 'Medium')
          ? 'Medium'
          : 'Low',
      visible.length,
      DateTime.now().toUtc().difference(created).inHours,
      first.requester,
      platforms: sources,
      reports: visible,
      priorityScore: score.toInt(),
      groupingState: group.groupingState,
      confidence: visible.any((r) => r.groupingConfidence != null)
          ? visible
                .where((r) => r.groupingConfidence != null)
                .map((r) => r.groupingConfidence!)
                .reduce(min)
          : null,
      primaryTicketId: first.id,
    );
  }

  const DemoTicket(
    this.id,
    this.title,
    this.description,
    this.source,
    this.status,
    this.priority,
    this.supporters,
    this.hoursAgo,
    this.requester, {
    this.isMock = false,
    this.platforms = const [],
    this.reports = const [],
    this.priorityScore = 0,
    this.groupingState = 'unprocessed',
    this.confidence,
    this.primaryTicketId,
  });
}

const demoTickets = [
  DemoTicket(
    'FB-1042',
    'Add dark mode to the dashboard',
    'The dashboard is used throughout the day. A dark theme would make late-night reviews easier on the eyes.',
    'Slack',
    'Planned',
    'Medium',
    28,
    2,
    'Alex Morgan',
  ),
  DemoTicket(
    'FB-1041',
    'Export feedback as CSV',
    'Let teams export filtered feedback with its status, source, and request count for weekly planning.',
    'Email',
    'In progress',
    'High',
    24,
    4,
    'Priya Shah',
  ),
  DemoTicket(
    'FB-1040',
    'Group duplicate feature requests automatically',
    'Requests from different channels describe the same feature. Combine them into one actionable feedback group.',
    'Forms',
    'Open',
    'High',
    19,
    6,
    'Jordan Lee',
  ),
  DemoTicket(
    'FB-1039',
    'Slack notifications for status changes',
    'Notify the team when a request is planned, started, or completed without needing to check the dashboard.',
    'Slack',
    'Open',
    'Medium',
    15,
    8,
    'Sam Rivera',
  ),
  DemoTicket(
    'FB-1038',
    'Dashboard takes too long to load',
    'The initial dashboard load is slow when a workspace contains a large amount of feedback.',
    'Support',
    'In progress',
    'High',
    12,
    12,
    'Taylor Chen',
  ),
  DemoTicket(
    'FB-1037',
    'Let viewers vote on feature requests',
    'Invite stakeholders to add their vote while keeping feedback moderation limited to admins.',
    'Forms',
    'Open',
    'Low',
    10,
    18,
    'Jamie Patel',
  ),
  DemoTicket(
    'FB-1036',
    'Filter requests by customer segment',
    'Separate feedback from trial users, paying customers, and internal teammates to improve prioritization.',
    'Email',
    'Planned',
    'Medium',
    8,
    24,
    'Casey Williams',
  ),
  DemoTicket(
    'FB-1035',
    'Improve search on mobile',
    'Search and filter controls should be easier to use on smaller screens.',
    'App reviews',
    'Resolved',
    'Low',
    5,
    48,
    'Riley Kim',
  ),
];

const ticketStatuses = ['Open', 'Planned', 'In progress', 'Resolved'];
const ticketSources = [
  'Forms',
  'Email',
  'Slack',
  'Discord',
  'Support',
  'App reviews',
];
const ticketPriorities = ['High', 'Medium', 'Low'];

List<DemoTicket> filterTickets({
  List<DemoTicket> tickets = demoTickets,
  String query = '',
  String status = 'All',
  String source = 'All',
  String priority = 'All',
  String sort = 'Most requested',
}) {
  final search = query.trim().toLowerCase();
  // All criteria combine; text search also includes the sample requester's name.
  final filtered = tickets
      .where(
        (ticket) =>
            (status == 'All' || ticket.status == status) &&
            (source == 'All' || ticket.sources.contains(source)) &&
            (priority == 'All' || ticket.priority == priority) &&
            '${ticket.id} ${ticket.title} ${ticket.description} ${ticket.requester}'
                .toLowerCase()
                .contains(search),
      )
      .toList();
  filtered.sort(
    (a, b) => switch (sort) {
      'Priority score' => b.priorityScore.compareTo(a.priorityScore),
      'Most recent' => a.hoursAgo.compareTo(b.hoursAgo),
      'Priority' =>
        ticketPriorities
            .indexOf(a.priority)
            .compareTo(ticketPriorities.indexOf(b.priority)),
      _ => b.supporters.compareTo(a.supporters),
    },
  );
  return filtered;
}
