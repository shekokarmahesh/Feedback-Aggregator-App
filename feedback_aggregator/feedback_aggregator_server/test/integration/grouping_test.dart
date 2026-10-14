import 'dart:async';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';
import 'package:feedback_aggregator_server/src/generated/protocol.dart';
import 'package:feedback_aggregator_server/src/feedback/grouping_service.dart';
import 'package:feedback_aggregator_server/src/feedback/laya_matcher.dart';
import 'package:feedback_aggregator_server/src/feedback/mock_source_service.dart';
import 'package:feedback_aggregator_server/src/laya_poc/laya_client.dart';
import 'package:feedback_aggregator_server/src/workspaces/workspace_service.dart';
import 'test_tools/serverpod_test_tools.dart';

class _Matcher implements GroupingMatcher {
  bool fail = false;
  int calls = 0;
  Completer<void>? entered;
  Completer<void>? release;
  @override
  Future<GroupingDecision> match(
    WorkspaceTicket report,
    List<IssueCandidate> candidates,
  ) async {
    calls++;
    if (entered != null && !entered!.isCompleted) entered!.complete();
    if (release != null) await release!.future;
    if (fail) throw const LayaFailure('Model offline');
    return GroupingDecision(
      groupId: candidates.firstOrNull?.id,
      confidence: .91,
      severity: 3,
    );
  }
}

void main() {
  withServerpod('Persisted automatic feedback grouping', (sessions, endpoints) {
    final opened = <Session>[];
    final workspaces = WorkspaceService();
    late Session admin;
    late WorkspaceSummary org;
    late _Matcher matcher;
    late GroupingService grouping;
    final scheduled = <Duration>[];
    Future<Session> account() async {
      final setup = sessions.build();
      opened.add(setup);
      final user = await AuthServices.instance.authUsers.create(setup);
      await AuthServices.instance.userProfiles.createUserProfile(
        setup,
        user.id,
        UserProfileData(email: 'group-${Uuid().v4()}@example.com'),
      );
      final session = sessions
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              user.id.toString(),
              {},
            ),
          )
          .build();
      opened.add(session);
      return session;
    }

    Future<void> reports() async {
      for (final source in ['Email', 'Slack', 'Forms']) {
        await MockSourceConnection.db.insertRow(
          admin,
          MockSourceConnection(
            workspaceId: org.id,
            source: source,
            connected: true,
          ),
        );
        await workspaces.createTicket(
          admin,
          org.id,
          'CSV export is empty on $source',
          'The CSV file contains headers and no ticket rows.',
          source,
          'High',
        );
      }
    }

    setUp(() async {
      AuthServices.set(
        tokenManagerBuilders: [JwtConfigFromPasswords()],
        identityProviderBuilders: [],
      );
      admin = await account();
      org = await workspaces.create(admin, 'Grouping verification');
      matcher = _Matcher();
      scheduled.clear();
      grouping = GroupingService(
        matcher: matcher,
        scheduler: (_, _, delay) async {
          scheduled.add(delay);
        },
      );
    });
    tearDown(() async {
      for (final s in opened) {
        await s.close();
      }
      opened.clear();
    });

    test(
      'three platform reports become one persisted issue with traceable evidence and score',
      () async {
        await reports();
        await grouping.enqueue(admin, org.id);
        await grouping.processBatch(admin, org.id);
        final issues = await grouping.read(admin, org.id);
        expect(matcher.calls, 3);
        expect(issues, hasLength(1));
        expect(issues.single.sources, containsAll(['Email', 'Slack', 'Forms']));
        expect(issues.single.reports, hasLength(3));
        expect(issues.single.priorityScore, greaterThan(40));
        expect(issues.single.confidence, .91);
        expect(
          await IssueGroup.db.find(
            admin,
            where: (t) => t.workspaceId.equals(org.id),
          ),
          hasLength(1),
        );
        await workspaces.updateTicketStatus(
          admin,
          org.id,
          issues.single.primaryTicketId,
          'Planned',
        );
        final fresh = GroupingService(scheduler: (_, _, _) async {});
        expect((await fresh.read(admin, org.id)).single.status, 'Planned');
        expect((await fresh.read(admin, org.id)).single.reports, hasLength(3));
      },
    );
    test(
      'disconnect removes source evidence and score; reconnect restores the same issue',
      () async {
        await reports();
        await grouping.enqueue(admin, org.id);
        await grouping.processBatch(admin, org.id);
        final before = (await grouping.read(admin, org.id)).single;
        await MockSourceService().disconnect(admin, org.id, 'Email');
        final after = (await grouping.read(admin, org.id)).single;
        expect(after.id, before.id);
        expect(after.reports, hasLength(2));
        expect(after.sources, isNot(contains('Email')));
        expect(after.description, isNot(contains('From:')));
        expect(after.priorityScore, lessThan(before.priorityScore));
        for (final source in ['Slack', 'Forms']) {
          await MockSourceService().disconnect(admin, org.id, source);
        }
        expect(await grouping.read(admin, org.id), isEmpty);
        final connection = (await MockSourceConnection.db.find(
          admin,
          where: (t) => t.workspaceId.equals(org.id) & t.source.equals('Email'),
        )).single;
        await MockSourceConnection.db.updateRow(
          admin,
          connection.copyWith(connected: true),
        );
        final restored = (await grouping.read(admin, org.id)).single;
        expect(restored.id, before.id);
        expect(restored.reports, hasLength(1));
        expect(
          await WorkspaceTicket.db.find(
            admin,
            where: (t) => t.workspaceId.equals(org.id),
          ),
          hasLength(3),
        );
      },
    );
    test(
      'model failure keeps raw feedback, records retry state, and resumes without duplicates',
      () async {
        await reports();
        matcher.fail = true;
        await grouping.enqueue(admin, org.id);
        await grouping.processBatch(admin, org.id);
        final waiting = await grouping.read(admin, org.id);
        expect(waiting, hasLength(3));
        expect(waiting.every((i) => i.groupingState == 'retrying'), isTrue);
        expect(
          await IssueGroup.db.find(
            admin,
            where: (t) => t.workspaceId.equals(org.id),
          ),
          isEmpty,
        );
        expect(scheduled.last, const Duration(seconds: 30));
        matcher.fail = false;
        await grouping.enqueue(admin, org.id, retry: true);
        await grouping.processBatch(admin, org.id);
        expect(
          (await grouping.read(admin, org.id)).single.reports,
          hasLength(3),
        );
        expect(
          (await GroupingJob.db.find(
            admin,
            where: (t) => t.workspaceId.equals(org.id),
          )).single.status,
          'idle',
        );
      },
    );
    test(
      'concurrent workers claim one workspace and never duplicate groups',
      () async {
        await reports();
        await grouping.enqueue(admin, org.id);
        await Future.wait([
          grouping.processBatch(admin, org.id),
          grouping.processBatch(admin, org.id),
        ]);
        expect(matcher.calls, 3);
        expect(await grouping.read(admin, org.id), hasLength(1));
        expect(
          await IssueGroup.db.find(
            admin,
            where: (t) => t.workspaceId.equals(org.id),
          ),
          hasLength(1),
        );
      },
    );
    test(
      'tenant isolation includes grouping jobs, candidate retrieval, and reads',
      () async {
        await reports();
        await grouping.enqueue(admin, org.id);
        await grouping.processBatch(admin, org.id);
        final other = await account();
        final beta = await workspaces.create(other, 'Other tenant');
        await workspaces.createTicket(
          other,
          beta.id,
          'CSV export empty',
          'A different organization report',
          'Email',
          'High',
        );
        await grouping.enqueue(other, beta.id);
        await grouping.processBatch(other, beta.id);
        final alpha = (await grouping.read(admin, org.id)).single;
        final second = (await grouping.read(other, beta.id)).single;
        expect(alpha.id, isNot(second.id));
        expect(second.reports, hasLength(1));
        await expectLater(
          grouping.read(other, org.id),
          throwsA(isA<WorkspaceException>()),
        );
        await expectLater(
          grouping.enqueue(other, org.id),
          throwsA(isA<WorkspaceException>()),
        );
      },
    );
    test(
      'membership downgrade during inference prevents its result from committing',
      () async {
        await reports();
        final editor = await account();
        final actor = await WorkspaceMember.db.insertRow(
          admin,
          WorkspaceMember(
            workspaceId: org.id,
            authUserId: workspaces.userId(editor),
            email: 'editor@example.com',
            name: 'Editor',
            role: WorkspaceRole.editor,
          ),
        );
        matcher.entered = Completer<void>();
        matcher.release = Completer<void>();
        await grouping.enqueue(editor, org.id);
        final running = grouping.processBatch(admin, org.id);
        await matcher.entered!.future;
        await workspaces.changeRole(
          admin,
          org.id,
          actor.id!,
          WorkspaceRole.viewer,
        );
        matcher.release!.complete();
        await running;
        expect(
          await IssueGroup.db.find(
            admin,
            where: (t) => t.workspaceId.equals(org.id),
          ),
          isEmpty,
        );
        expect(
          (await GroupingJob.db.find(
            admin,
            where: (t) => t.workspaceId.equals(org.id),
          )).single.status,
          'blocked',
        );
        await expectLater(
          grouping.enqueue(editor, org.id),
          throwsA(isA<WorkspaceException>()),
        );
      },
    );
    test(
      'disconnect during inference leaves its saved report invisible and ungrouped',
      () async {
        await workspaces.createTicket(
          admin,
          org.id,
          'Export is empty',
          'Only headers',
          'Email',
          'High',
        );
        await MockSourceConnection.db.insertRow(
          admin,
          MockSourceConnection(
            workspaceId: org.id,
            source: 'Email',
            connected: true,
          ),
        );
        matcher.entered = Completer<void>();
        matcher.release = Completer<void>();
        await grouping.enqueue(admin, org.id);
        final running = grouping.processBatch(admin, org.id);
        await matcher.entered!.future;
        await MockSourceService().disconnect(admin, org.id, 'Email');
        matcher.release!.complete();
        await running;
        expect(await grouping.read(admin, org.id), isEmpty);
        expect(
          await IssueGroup.db.find(
            admin,
            where: (t) => t.workspaceId.equals(org.id),
          ),
          isEmpty,
        );
        expect(
          (await WorkspaceTicket.db.find(
            admin,
            where: (t) => t.workspaceId.equals(org.id),
          )).single.issueGroupId,
          isNull,
        );
      },
    );
  }, rollbackDatabase: RollbackDatabase.disabled);
}
