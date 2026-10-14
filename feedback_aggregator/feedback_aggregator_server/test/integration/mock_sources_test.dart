import 'package:feedback_aggregator_server/src/feedback/mock_source_service.dart';
import 'package:feedback_aggregator_server/src/generated/protocol.dart';
import 'package:feedback_aggregator_server/src/workspaces/workspace_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Workspace demo source sync', (sessions, endpoints) {
    final opened = <Session>[];
    final sources = MockSourceService();
    final workspaces = WorkspaceService();
    late Session admin;
    late WorkspaceSummary workspace;

    Future<Session> account(String email) async {
      final setup = sessions.build();
      opened.add(setup);
      final user = await AuthServices.instance.authUsers.create(setup);
      await AuthServices.instance.userProfiles.createUserProfile(
        setup,
        user.id,
        UserProfileData(email: email),
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

    Future<Session> member(WorkspaceRole role) async {
      final email = '${role.name}-${Uuid().v4()}@example.com';
      final session = await account(email);
      final invitation = await workspaces.invite(
        admin,
        workspace.id,
        email,
        role,
        sendEmail: false,
      );
      final token = Uri.splitQueryString(
        Uri.parse(invitation.url).fragment.split('?')[1],
      )['token']!;
      await workspaces.accept(session, token);
      return session;
    }

    setUp(() async {
      AuthServices.set(
        tokenManagerBuilders: [JwtConfigFromPasswords()],
        identityProviderBuilders: [],
      );
      admin = await account('mock-admin-${Uuid().v4()}@example.com');
      workspace = await workspaces.create(admin, 'Demo sync workspace');
    });
    tearDown(() async {
      for (final session in opened) {
        await session.close();
      }
      opened.clear();
    });

    test(
      'connect persists five labeled tickets and provider-shaped evidence',
      () async {
        final result = await sources.connect(admin, workspace.id, 'Email');
        final rows = await workspaces.tickets(admin, workspace.id);
        expect(result.addedCount, 5);
        expect(result.connection.connected, isTrue);
        expect(result.connection.syncedCount, 5);
        expect(result.connection.availableCount, 12);
        expect(result.connection.connectedAt, isNotNull);
        expect(result.connection.lastSyncedAt, isNotNull);
        expect(rows, hasLength(5));
        expect(
          rows.every(
            (t) => t.source == 'Email' && t.isMock && t.externalId != null,
          ),
          isTrue,
        );
        expect(rows.first.description, contains('From:'));
        expect(rows.first.requester, contains('@example.com'));
        expect(
          (await MockSourceService().list(admin, workspace.id)).single.id,
          result.connection.id,
        );
      },
    );

    test(
      'delta sync finishes a bounded inbox without duplicating or overwriting edits',
      () async {
        await workspaces.createTicket(
          admin,
          workspace.id,
          'Real customer report',
          'Keep this',
          'Email',
          'High',
        );
        await sources.connect(admin, workspace.id, 'Email');
        final first = (await workspaces.tickets(
          admin,
          workspace.id,
        )).firstWhere((t) => t.isMock);
        await workspaces.updateTicketStatus(
          admin,
          workspace.id,
          first.id!,
          'Resolved',
        );
        final counts = <int>[];
        for (var i = 0; i < 4; i++) {
          counts.add(
            (await sources.sync(admin, workspace.id, 'Email')).addedCount,
          );
        }
        expect(counts, [3, 3, 1, 0]);
        expect(
          (await sources.connect(admin, workspace.id, 'Email')).addedCount,
          0,
        );
        final rows = await workspaces.tickets(admin, workspace.id);
        expect(rows, hasLength(13));
        expect(
          rows.where((t) => t.isMock).map((t) => t.externalId).toSet(),
          hasLength(12),
        );
        expect(rows.singleWhere((t) => t.id == first.id).status, 'Resolved');
        expect(rows.singleWhere((t) => !t.isMock).description, 'Keep this');
      },
    );

    test(
      'concurrent Connect and sync requests preserve one connection and unique reports',
      () async {
        final results = await Future.wait([
          sources.connect(admin, workspace.id, 'Slack'),
          sources.connect(admin, workspace.id, 'Slack'),
        ]);
        expect(
          results.map((r) => r.addedCount).fold<int>(0, (a, b) => a + b),
          5,
        );
        await Future.wait([
          sources.sync(admin, workspace.id, 'Slack'),
          sources.sync(admin, workspace.id, 'Slack'),
        ]);
        final rows = await workspaces.tickets(admin, workspace.id);
        expect(rows, hasLength(11));
        expect(rows.map((t) => t.externalId).toSet(), hasLength(11));
        expect(await sources.list(admin, workspace.id), hasLength(1));
      },
    );

    test(
      'different workspaces can import the same fixture IDs without sharing rows',
      () async {
        final other = await account('other-${Uuid().v4()}@example.com');
        final beta = await workspaces.create(other, 'Beta');
        await sources.connect(admin, workspace.id, 'Slack');
        await sources.connect(other, beta.id, 'Slack');
        final alphaTickets = await workspaces.tickets(admin, workspace.id);
        final betaTickets = await workspaces.tickets(other, beta.id);
        expect(
          alphaTickets.map((t) => t.externalId),
          betaTickets.map((t) => t.externalId),
        );
        expect(
          alphaTickets
              .map((t) => t.id)
              .toSet()
              .intersection(betaTickets.map((t) => t.id).toSet()),
          isEmpty,
        );
        for (final action in [
          () => sources.list(other, workspace.id),
          () => sources.connect(other, workspace.id, 'Email'),
          () => sources.sync(other, workspace.id, 'Slack'),
          () => sources.disconnect(other, workspace.id, 'Slack'),
        ]) {
          await expectLater(action(), throwsA(isA<WorkspaceException>()));
        }
        expect(await workspaces.tickets(admin, workspace.id), hasLength(5));
      },
    );

    test(
      'Editors sync; only Admins manage connections; Viewers only read',
      () async {
        final editor = await member(WorkspaceRole.editor);
        final viewer = await member(WorkspaceRole.viewer);
        await sources.connect(admin, workspace.id, 'Slack');
        expect(
          (await sources.sync(editor, workspace.id, 'Slack')).addedCount,
          3,
        );
        expect(
          (await sources.list(viewer, workspace.id)).single.syncedCount,
          8,
        );
        for (final session in [editor, viewer]) {
          await expectLater(
            sources.connect(session, workspace.id, 'Email'),
            throwsA(isA<WorkspaceException>()),
          );
          await expectLater(
            sources.disconnect(session, workspace.id, 'Slack'),
            throwsA(isA<WorkspaceException>()),
          );
        }
        await expectLater(
          sources.sync(viewer, workspace.id, 'Slack'),
          throwsA(isA<WorkspaceException>()),
        );
        expect(await workspaces.tickets(viewer, workspace.id), hasLength(8));
      },
    );

    test(
      'disconnect stops sync; reconnect resumes while preserving existing tickets',
      () async {
        await sources.connect(admin, workspace.id, 'Email');
        final first = (await workspaces.tickets(admin, workspace.id)).first;
        await workspaces.updateTicketStatus(
          admin,
          workspace.id,
          first.id!,
          'Planned',
        );
        expect(
          (await sources.disconnect(admin, workspace.id, 'Email')).connected,
          isFalse,
        );
        await expectLater(
          sources.sync(admin, workspace.id, 'Email'),
          throwsA(isA<WorkspaceException>()),
        );
        expect(await workspaces.tickets(admin, workspace.id), hasLength(5));
        expect(
          (await sources.connect(admin, workspace.id, 'Email')).addedCount,
          5,
        );
        final rows = await workspaces.tickets(admin, workspace.id);
        expect(rows, hasLength(10));
        expect(rows.singleWhere((t) => t.id == first.id).status, 'Planned');
      },
    );

    test(
      'unsupported and unconnected sources cannot populate tickets',
      () async {
        for (final source in ['Discord', 'Forms', 'email', 'Anything']) {
          await expectLater(
            sources.connect(admin, workspace.id, source),
            throwsA(isA<WorkspaceException>()),
          );
        }
        await expectLater(
          sources.sync(admin, workspace.id, 'Slack'),
          throwsA(isA<WorkspaceException>()),
        );
        expect(await sources.list(admin, workspace.id), isEmpty);
        expect(await workspaces.tickets(admin, workspace.id), isEmpty);
      },
    );

    test(
      'existing and manually added tickets can share nullable external IDs',
      () async {
        for (var i = 0; i < 2; i++) {
          await workspaces.createTicket(
            admin,
            workspace.id,
            'Existing feedback',
            '',
            'Email',
            'Medium',
          );
        }
        final tickets = await workspaces.tickets(admin, workspace.id);
        expect(tickets, hasLength(2));
        expect(tickets.every((t) => t.externalId == null && !t.isMock), isTrue);
      },
    );

    test(
      'endpoint requires authentication before exposing connection state',
      () async {
        await expectLater(
          endpoints.sources.list(sessions, workspace.id),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      },
    );
  }, rollbackDatabase: RollbackDatabase.disabled);
}
