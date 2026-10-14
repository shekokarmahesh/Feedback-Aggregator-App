import 'dart:io';
import 'dart:math';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../generated/future_calls.dart';
import '../laya_poc/laya_client.dart';
import '../workspaces/workspace_service.dart';
import 'laya_matcher.dart';

typedef GroupingScheduler =
    Future<void> Function(Session session, int workspaceId, Duration delay);

class GroupingService {
  final GroupingMatcher? matcher;
  final GroupingScheduler? scheduler;
  GroupingService({this.matcher, this.scheduler});

  Future<void> _lock(Session s, int id, Transaction tx) async {
    if (await Workspace.db.findById(
          s,
          id,
          transaction: tx,
          lockMode: LockMode.forUpdate,
        ) ==
        null) {
      throw WorkspaceException(message: 'Workspace access denied.');
    }
  }

  Future<bool> _authorized(Session s, GroupingJob job, Transaction tx) async {
    final member = await WorkspaceMember.db.findFirstRow(
      s,
      where: (t) =>
          t.workspaceId.equals(job.workspaceId) &
          t.authUserId.equals(job.requestedBy),
      transaction: tx,
    );
    return member != null && member.role != WorkspaceRole.viewer;
  }

  Future<List<WorkspaceTicket>> _visible(
    Session s,
    int id,
    Transaction tx,
  ) async {
    final disconnected = await MockSourceConnection.db.find(
      s,
      where: (t) => t.workspaceId.equals(id) & t.connected.equals(false),
      transaction: tx,
    );
    return WorkspaceTicket.db.find(
      s,
      where: (t) =>
          t.workspaceId.equals(id) &
          t.source.notInSet(disconnected.map((c) => c.source).toSet()),
      orderBy: (t) => t.id,
      limit: 500,
      transaction: tx,
    );
  }

  Future<void> _schedule(Session s, int id, Duration delay) async {
    if (scheduler != null) return scheduler!(s, id, delay);
    await s.serverpod.futureCalls.callWithDelay(delay).grouping.process(id);
  }

  Future<void> enqueue(Session s, int id, {bool retry = false}) async {
    await WorkspaceService().requireAccess(s, id, write: true);
    await enqueueFor(s, id, WorkspaceService().userId(s), retry: retry);
  }

  /// Internal ingestion jobs retain a verified workspace member as their actor.
  Future<void> enqueueFor(
    Session s,
    int id,
    UuidValue actor, {
    bool retry = false,
  }) async {
    final delay = await s.db.transaction<Duration?>((tx) async {
      await _lock(s, id, tx);
      final now = DateTime.now().toUtc();
      var job = await GroupingJob.db.findFirstRow(
        s,
        where: (t) => t.workspaceId.equals(id),
        transaction: tx,
      );
      job ??= GroupingJob(workspaceId: id, requestedBy: actor);
      final permission = job.copyWith(requestedBy: actor);
      if (!await _authorized(s, permission, tx)) {
        throw WorkspaceException(
          message: 'Only an Admin or Editor can group feedback.',
        );
      }
      if ((await _visible(s, id, tx)).every((r) => r.issueGroupId != null)) {
        return null;
      }
      if (job.leaseUntil?.isAfter(now) == true) return null;
      if (!retry &&
          job.scheduledAt != null &&
          now.difference(job.scheduledAt!).inMinutes < 5) {
        return null;
      }
      if (!retry && job.retryAt?.isAfter(now) == true) return null;
      job.requestedBy = actor;
      job.status = 'queued';
      job.scheduledAt = now;
      job.leaseToken = null;
      job.leaseUntil = null;
      if (retry) {
        job.failures = 0;
        job.lastError = null;
        job.retryAt = null;
      }
      if (job.id == null) {
        await GroupingJob.db.insertRow(s, job, transaction: tx);
      } else {
        await GroupingJob.db.updateRow(s, job, transaction: tx);
      }
      return Duration.zero;
    });
    if (delay != null) {
      try {
        await _schedule(s, id, delay);
      } catch (_) {
        // Import remains successful. The next authorized inbox read retries scheduling.
        await s.db.transaction((tx) async {
          await _lock(s, id, tx);
          final job = await GroupingJob.db.findFirstRow(
            s,
            where: (t) => t.workspaceId.equals(id),
            transaction: tx,
          );
          if (job != null && job.leaseToken == null) {
            job.scheduledAt = null;
            job.status = 'retrying';
            job.lastError = 'Automatic grouping is waiting to retry.';
            await GroupingJob.db.updateRow(s, job, transaction: tx);
          }
        });
        s.log(
          'Workspace grouping scheduling will be retried.',
          level: LogLevel.warning,
        );
      }
    }
  }

  Future<List<GroupedTicket>> read(Session s, int id) async {
    await WorkspaceService().requireAccess(s, id);
    final member = await WorkspaceMember.db.findFirstRow(
      s,
      where: (t) =>
          t.workspaceId.equals(id) &
          t.authUserId.equals(WorkspaceService().userId(s)),
    );
    if (member?.role != WorkspaceRole.viewer) await enqueue(s, id);
    return s.db.transaction((tx) async {
      await _lock(s, id, tx);
      await WorkspaceService().requireAccess(s, id, transaction: tx);
      final reports = await _visible(s, id, tx);
      final groups = await IssueGroup.db.find(
        s,
        where: (t) => t.workspaceId.equals(id),
        transaction: tx,
      );
      final byId = {for (final g in groups) g.id!: g};
      final buckets = <int, List<WorkspaceTicket>>{};
      for (final report in reports) {
        (buckets[report.issueGroupId ?? -report.id!] ??= []).add(report);
      }
      final rows = <GroupedTicket>[];
      for (final entry in buckets.entries) {
        final visible = entry.value;
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
        final priority = visible.any((r) => r.priority == 'High')
            ? 'High'
            : visible.any((r) => r.priority == 'Medium')
            ? 'Medium'
            : 'Low';
        rows.add(
          GroupedTicket(
            id: entry.key,
            primaryTicketId: first.id!,
            title: first.title,
            description: first.description,
            status: byId[entry.key]?.status ?? first.status,
            priority: priority,
            priorityScore: score.toInt(),
            sources: sources,
            reports: visible,
            groupingState: visible.any((r) => r.groupingState == 'review')
                ? 'review'
                : first.issueGroupId == null
                ? first.groupingState
                : 'complete',
            confidence: first.issueGroupId == null
                ? null
                : visible.any((r) => r.groupingConfidence != null)
                ? visible
                      .where((r) => r.groupingConfidence != null)
                      .map((r) => r.groupingConfidence!)
                      .reduce(min)
                : null,
            createdAt: visible
                .map((r) => r.createdAt)
                .reduce((a, b) => a.isAfter(b) ? a : b),
          ),
        );
      }
      rows.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
      return rows;
    });
  }

  GroupingMatcher _matcher(Session s) =>
      matcher ??
      LayaGroupingMatcher(
        LayaClient(
          apiKey: s.serverpod.getPassword('layaApiKey') ?? '',
          endpoint: Uri.parse(
            Platform.environment['LAYA_URL'] ??
                'http://127.0.0.1:8093/v1/systemone',
          ),
          requestTimeout: Duration(
            seconds:
                (int.tryParse(
                          Platform.environment['LAYA_REQUEST_TIMEOUT_SECONDS'] ??
                              '',
                        ) ??
                        45)
                    .clamp(1, 90),
          ),
        ),
      );

  Future<void> processBatch(Session s, int id) async {
    final lease = Uuid().v4();
    final claimed = await s.db.transaction((tx) async {
      await _lock(s, id, tx);
      final job = await GroupingJob.db.findFirstRow(
        s,
        where: (t) => t.workspaceId.equals(id),
        transaction: tx,
      );
      if (job == null ||
          job.leaseUntil?.isAfter(DateTime.now().toUtc()) == true) {
        return false;
      }
      if (!await _authorized(s, job, tx)) {
        job.status = 'blocked';
        job.scheduledAt = null;
        await GroupingJob.db.updateRow(s, job, transaction: tx);
        return false;
      }
      job.status = 'processing';
      job.leaseToken = lease;
      job.leaseUntil = DateTime.now().toUtc().add(const Duration(minutes: 6));
      job.scheduledAt = null;
      await GroupingJob.db.updateRow(s, job, transaction: tx);
      return true;
    });
    if (!claimed) return;
    Duration? retryDelay;
    try {
      for (var n = 0; n < 3; n++) {
        final context = await s.db.transaction((tx) async {
          await _lock(s, id, tx);
          final job = await GroupingJob.db.findFirstRow(
            s,
            where: (t) => t.workspaceId.equals(id),
            transaction: tx,
          );
          if (job == null ||
              job.leaseToken != lease ||
              !await _authorized(s, job, tx)) {
            return null;
          }
          final reports = await _visible(s, id, tx);
          final report = reports
              .where((r) => r.issueGroupId == null)
              .firstOrNull;
          if (report == null) return null;
          final grouped = <int, List<WorkspaceTicket>>{};
          for (final row in reports.where((r) => r.issueGroupId != null)) {
            (grouped[row.issueGroupId!] ??= []).add(row);
          }
          final candidates = [
            for (final entry in grouped.entries)
              IssueCandidate(
                entry.key,
                entry.value.first.title,
                reportText(entry.value.first),
              ),
          ];
          return (report: report, candidates: shortlist(report, candidates));
        });
        if (context == null) break;
        final decision = await _matcher(
          s,
        ).match(context.report, context.candidates);
        await s.db.transaction((tx) async {
          await _lock(s, id, tx);
          final job = await GroupingJob.db.findFirstRow(
            s,
            where: (t) => t.workspaceId.equals(id),
            transaction: tx,
          );
          if (job == null ||
              job.leaseToken != lease ||
              !await _authorized(s, job, tx)) {
            return;
          }
          final visible = await _visible(s, id, tx);
          final report = visible
              .where((r) => r.id == context.report.id && r.issueGroupId == null)
              .firstOrNull;
          if (report == null) return;
          IssueGroup? group;
          if (decision.groupId != null) {
            if (!context.candidates.any((c) => c.id == decision.groupId) ||
                !visible.any((r) => r.issueGroupId == decision.groupId)) {
              return;
            }
            group = await IssueGroup.db.findFirstRow(
              s,
              where: (t) =>
                  t.workspaceId.equals(id) & t.id.equals(decision.groupId),
              transaction: tx,
            );
            if (group == null) return;
          }
          group ??= await IssueGroup.db.insertRow(
            s,
            IssueGroup(workspaceId: id, status: report.status),
            transaction: tx,
          );
          report.issueGroupId = group.id;
          report.groupingState = decision.review ? 'review' : 'complete';
          report.groupingConfidence = decision.groupId == null
              ? null
              : decision.confidence;
          report.severity = decision.severity;
          await WorkspaceTicket.db.updateRow(s, report, transaction: tx);
        });
      }
    } catch (_) {
      retryDelay = const Duration(seconds: 30);
      s.log(
        'Automatic feedback grouping is temporarily unavailable; queued reports will retry.',
        level: LogLevel.warning,
      );
    } finally {
      final next = await s.db.transaction<Duration?>((tx) async {
        await _lock(s, id, tx);
        final job = await GroupingJob.db.findFirstRow(
          s,
          where: (t) => t.workspaceId.equals(id),
          transaction: tx,
        );
        if (job == null || job.leaseToken != lease) return null;
        job.leaseToken = null;
        job.leaseUntil = null;
        if (!await _authorized(s, job, tx)) {
          job.status = 'blocked';
          job.scheduledAt = null;
          await GroupingJob.db.updateRow(s, job, transaction: tx);
          return null;
        }
        final pending = (await _visible(
          s,
          id,
          tx,
        )).where((r) => r.issueGroupId == null).toList();
        if (pending.isEmpty) {
          job.status = 'idle';
          job.failures = 0;
          job.retryAt = null;
          job.lastError = null;
          job.scheduledAt = null;
          await GroupingJob.db.updateRow(s, job, transaction: tx);
          return null;
        }
        var delay = const Duration(seconds: 1);
        if (retryDelay != null) {
          job.failures++;
          delay = Duration(
            seconds: min(300, 30 * pow(2, min(job.failures - 1, 4)).toInt()),
          );
          job.status = 'retrying';
          job.lastError = 'Automatic grouping is waiting to retry.';
          for (final report in pending) {
            report.groupingState = 'retrying';
            await WorkspaceTicket.db.updateRow(s, report, transaction: tx);
          }
        } else {
          job.status = 'queued';
          job.failures = 0;
          job.lastError = null;
        }
        job.retryAt = DateTime.now().toUtc().add(delay);
        job.scheduledAt = DateTime.now().toUtc();
        await GroupingJob.db.updateRow(s, job, transaction: tx);
        return delay;
      });
      if (next != null) await _schedule(s, id, next);
    }
  }
}
