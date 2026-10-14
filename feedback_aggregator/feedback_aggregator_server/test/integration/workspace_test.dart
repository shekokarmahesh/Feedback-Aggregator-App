import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:feedback_aggregator_server/src/generated/protocol.dart';
import 'package:feedback_aggregator_server/src/workspaces/workspace_service.dart';
import 'package:feedback_aggregator_server/src/auth/auth_email.dart';
import 'package:feedback_aggregator_server/src/web/routes/feedback_webhook_route.dart';
import 'package:feedback_aggregator_server/src/feedback/webhook_key_service.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Workspace isolation and roles', (sessions, endpoints) {
    late WorkspaceService service;
    late Session admin;
    final opened = <Session>[];
    late String sentUrl;

    Future<Session> account(String email) async {
      final setup = sessions.build();
      opened.add(setup);
      final auth = AuthServices.instance;
      final user = await auth.authUsers.create(setup);
      await auth.userProfiles.createUserProfile(
        setup,
        user.id,
        UserProfileData(email: email),
      );
      final s = sessions
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              user.id.toString(),
              {},
            ),
          )
          .build();
      opened.add(s);
      return s;
    }

    String token(String url) =>
        Uri.splitQueryString(Uri.parse(url).fragment.split('?')[1])['token']!;

    setUp(() async {
      AuthServices.set(
        tokenManagerBuilders: [JwtConfigFromPasswords()],
        identityProviderBuilders: [],
      );
      service = WorkspaceService(
        mailer: (s, email, org, role, url, id) async {
          sentUrl = url;
        },
      );
      admin = await account('admin-${Uuid().v4()}@example.com');
    });
    tearDown(() async {
      for (final s in opened) {
        await s.close();
      }
      opened.clear();
    });

    test(
      'creator is Admin and unrelated users cannot access any tenant data',
      () async {
        final org = await service.create(admin, 'Alpha');
        final outsider = await account('outsider@example.com');
        final beta = await service.create(outsider, 'Beta');
        await service.requireAccess(admin, org.id, write: true);
        await expectLater(
          service.requireAccess(outsider, org.id),
          throwsA(isA<WorkspaceException>()),
        );
        final ticket = await service.createTicket(
          admin,
          org.id,
          'Private request',
          'Alpha only',
          'Forms',
          'High',
        );
        expect(org.role, WorkspaceRole.admin);
        expect((await service.list(outsider)).map((o) => o.id), [beta.id]);
        await expectLater(
          service.tickets(outsider, org.id),
          throwsA(isA<WorkspaceException>()),
        );
        await expectLater(
          service.members(outsider, org.id),
          throwsA(isA<WorkspaceException>()),
        );
        await expectLater(
          service.invitations(outsider, org.id),
          throwsA(isA<WorkspaceException>()),
        );
        await expectLater(
          service.updateTicketStatus(outsider, beta.id, ticket.id!, 'Resolved'),
          throwsA(isA<WorkspaceException>()),
        );
        await expectLater(
          service.changeRole(
            outsider,
            beta.id,
            (await service.members(admin, org.id)).first.id,
            WorkspaceRole.viewer,
          ),
          throwsA(isA<WorkspaceException>()),
        );
      },
    );

    test(
      'invites bind to inbox, store a hash, and can only be accepted once',
      () async {
        final org = await service.create(admin, 'Alpha');
        final recipient = await account('invited@example.com');
        final wrong = await account('wrong@example.com');
        final delivered = await service.invite(
          admin,
          org.id,
          ' INVITED@Example.com ',
          WorkspaceRole.viewer,
        );
        final linkToken = token(sentUrl);
        expect(delivered.url, sentUrl);
        final stored = await WorkspaceInvitation.db.findById(
          admin,
          delivered.invitation.id,
        );
        expect(stored!.tokenHash, isNot(linkToken));
        expect(stored.tokenHash.length, 64);
        await expectLater(
          service.accept(wrong, linkToken),
          throwsA(isA<WorkspaceException>()),
        );
        final preview = await service.preview(recipient, linkToken);
        expect(preview.workspaceName, 'Alpha');
        final joined = await service.accept(recipient, linkToken);
        expect(joined.role, WorkspaceRole.viewer);
        await service.requireAccess(recipient, org.id);
        await expectLater(
          service.requireAccess(recipient, org.id, write: true),
          throwsA(isA<WorkspaceException>()),
        );
        await expectLater(
          service.accept(recipient, linkToken),
          throwsA(isA<WorkspaceException>()),
        );
        await expectLater(
          service.createTicket(
            recipient,
            org.id,
            'Viewer write',
            '',
            'Forms',
            'Low',
          ),
          throwsA(isA<WorkspaceException>()),
        );
        await expectLater(
          service.invite(
            recipient,
            org.id,
            'other@example.com',
            WorkspaceRole.admin,
          ),
          throwsA(isA<WorkspaceException>()),
        );
      },
    );

    test(
      'Editor can write tickets but only Admin can manage members',
      () async {
        final org = await service.create(admin, 'Alpha');
        final editor = await account('editor@example.com');
        await service.invite(
          admin,
          org.id,
          'editor@example.com',
          WorkspaceRole.editor,
        );
        await service.accept(editor, token(sentUrl));
        await service.requireAccess(editor, org.id, write: true);
        final ticket = await service.createTicket(
          editor,
          org.id,
          'Editor request',
          'Description',
          'Email',
          'Medium',
        );
        expect(
          (await service.updateTicketStatus(
            editor,
            org.id,
            ticket.id!,
            'Planned',
          )).status,
          'Planned',
        );
        final member = (await service.members(
          admin,
          org.id,
        )).firstWhere((m) => m.role == WorkspaceRole.editor);
        await expectLater(
          service.changeRole(editor, org.id, member.id, WorkspaceRole.admin),
          throwsA(isA<WorkspaceException>()),
        );
        await service.changeRole(
          admin,
          org.id,
          member.id,
          WorkspaceRole.viewer,
        );
        await expectLater(
          service.requireAccess(editor, org.id, write: true),
          throwsA(isA<WorkspaceException>()),
        );
        await expectLater(
          service.updateTicketStatus(editor, org.id, ticket.id!, 'Resolved'),
          throwsA(isA<WorkspaceException>()),
        );
        await service.removeMember(admin, org.id, member.id);
        await expectLater(
          service.requireAccess(editor, org.id),
          throwsA(isA<WorkspaceException>()),
        );
        await expectLater(
          service.tickets(editor, org.id),
          throwsA(isA<WorkspaceException>()),
        );
      },
    );

    test('cannot demote or remove the last Admin', () async {
      final org = await service.create(admin, 'Alpha');
      final own = (await service.members(admin, org.id)).single;
      await expectLater(
        service.changeRole(admin, org.id, own.id, WorkspaceRole.editor),
        throwsA(isA<WorkspaceException>()),
      );
      await expectLater(
        service.removeMember(admin, org.id, own.id),
        throwsA(isA<WorkspaceException>()),
      );
    });

    test(
      'Discord setup is Admin-only and guilds cannot cross workspaces',
      () async {
        final org = await service.create(admin, 'Discord Alpha');
        final outsider = await account('discord-outsider@example.com');
        final beta = await service.create(outsider, 'Discord Beta');
        const guild = '123456789012345678';
        await expectLater(
          service.setDiscordGuild(outsider, org.id, guild),
          throwsA(isA<WorkspaceException>()),
        );
        await expectLater(
          service.discordGuild(outsider, org.id),
          throwsA(isA<WorkspaceException>()),
        );
        await expectLater(
          service.setDiscordGuild(admin, org.id, 'invalid'),
          throwsA(isA<WorkspaceException>()),
        );
        await service.setDiscordGuild(admin, org.id, guild);
        expect(await service.discordGuild(admin, org.id), guild);
        await expectLater(
          service.setDiscordGuild(outsider, beta.id, guild),
          throwsA(isA<WorkspaceException>()),
        );
        await service.invite(
          admin,
          org.id,
          'discord-outsider@example.com',
          WorkspaceRole.editor,
        );
        await service.accept(outsider, token(sentUrl));
        await expectLater(
          service.setDiscordGuild(outsider, org.id, guild),
          throwsA(isA<WorkspaceException>()),
        );
        await expectLater(
          service.disconnectDiscord(outsider, org.id),
          throwsA(isA<WorkspaceException>()),
        );
        await service.setDiscordGuild(admin, org.id, '223456789012345678');
        expect(await service.discordGuild(admin, org.id), '223456789012345678');
        await service.disconnectDiscord(admin, org.id);
        expect(await service.discordGuild(admin, org.id), isNull);
        await service.setDiscordGuild(outsider, beta.id, guild);
        expect(await service.discordGuild(outsider, beta.id), guild);
      },
    );

    test(
      'Discord HTTP ingestion routes by guild, without a key or email',
      () async {
        final org = await service.create(admin, 'Discord HTTP');
        const guild = '323456789012345678';
        await service.setDiscordGuild(admin, org.id, guild);
        final web = admin.serverpod.webServer;
        web.addRoute(FeedbackWebhookRoute(), '/webhooks/feedback');
        web.addRoute(
          FlutterRoute(Directory('web/app'), enableWasmHeaders: false),
          '/',
        );
        expect(await web.start(), isTrue);
        addTearDown(web.stop);
        final http = HttpClient();
        addTearDown(http.close);
        Future<int> post(
          Object data, {
          String contentType = 'application/json',
          String? key,
        }) async {
          final request = await http.postUrl(
            Uri.parse('http://localhost:${web.port}/webhooks/feedback'),
          );
          request.headers.set('Content-Type', contentType);
          if (key != null) request.headers.set('X-Feedback-Webhook-Key', key);
          request.write(data is String ? data : jsonEncode(data));
          final response = await request.close();
          await response.drain<void>();
          return response.statusCode;
        }

        const payload = {
          'platform': 'discord',
          'guild_id': guild,
          'title': ' Export ',
          'body': 'Please add CSV export.',
          'requester': 'Alice',
          'workspaceId': 999,
        };
        expect(await post(payload), 201);
        final tickets = await service.tickets(admin, org.id);
        expect(tickets, hasLength(1));
        expect(tickets.single.workspaceId, org.id);
        expect(tickets.single.title, 'Export');
        expect(tickets.single.source, 'Discord');
        expect(tickets.single.requester, 'Alice');
        expect(await post({...payload, 'guild_id': '423456789012345678'}), 422);
        expect(await post({...payload, 'guild_id': 123}), 400);
        expect(await post({...payload, 'body': ''}), 400);
        expect(await post({...payload, 'body': 'x' * 65536}), 413);
        expect(await post(payload, contentType: 'text/plain'), 415);
        expect(await post({'title': 'Non-Discord'}), 401);
        final team = await Team.db.insertRow(
          admin,
          Team(
            name: 'Regular webhook',
            ownerUserId: admin.authenticated!.userIdentifier,
            createdAt: DateTime.now().toUtc(),
          ),
        );
        final key = generateWebhookKey();
        await FeedbackWebhookKey.db.insertRow(
          admin,
          FeedbackWebhookKey(
            teamId: team.id!,
            keyHash: hashWebhookKey(key),
            createdByUserId: admin.authenticated!.userIdentifier,
            createdAt: DateTime.now().toUtc(),
          ),
        );
        const regular = {
          'title': 'Regular feedback',
          'body': 'Still requires a key',
          'source': 'website-support',
          'userEmail': 'USER@example.com',
        };
        expect(await post(regular), 401);
        expect(await post(regular, key: key), 201);
        expect(
          await post(
            Uri(queryParameters: regular).query,
            key: key,
            contentType: 'application/x-www-form-urlencoded',
          ),
          201,
        );
        final rows = await Feedback.db.find(
          admin,
          where: (t) => t.teamId.equals(team.id!),
        );
        expect(rows, hasLength(2));
        expect(
          rows.every((row) => row.userEmail == 'user@example.com'),
          isTrue,
        );
        await service.disconnectDiscord(admin, org.id);
        expect(await post(payload), 422);
        expect(await service.tickets(admin, org.id), hasLength(1));
      },
    );

    test('revoked, expired, and superseded invitations cannot join', () async {
      final org = await service.create(admin, 'Alpha');
      final recipient = await account('revoked@example.com');
      final first = await service.invite(
        admin,
        org.id,
        'revoked@example.com',
        WorkspaceRole.editor,
      );
      final oldToken = token(sentUrl);
      final second = await service.invite(
        admin,
        org.id,
        'revoked@example.com',
        WorkspaceRole.viewer,
      );
      final newToken = token(sentUrl);
      await expectLater(
        service.accept(recipient, oldToken),
        throwsA(isA<WorkspaceException>()),
      );
      await service.revoke(admin, org.id, second.invitation.id);
      await expectLater(
        service.accept(recipient, newToken),
        throwsA(isA<WorkspaceException>()),
      );
      final expired = await service.invite(
        admin,
        org.id,
        'revoked@example.com',
        WorkspaceRole.viewer,
      );
      final expireToken = token(sentUrl);
      final row = (await WorkspaceInvitation.db.findById(
        admin,
        expired.invitation.id,
      ))!;
      row.expiresAt = DateTime.now().toUtc().subtract(
        const Duration(seconds: 1),
      );
      await WorkspaceInvitation.db.updateRow(admin, row);
      await expectLater(
        service.accept(recipient, expireToken),
        throwsA(isA<WorkspaceException>()),
      );
      expect(
        (await service.invitations(
          admin,
          org.id,
        )).firstWhere((i) => i.id == first.invitation.id).status,
        'Revoked',
      );
    });

    test(
      'mail failure is reported and revokes the undelivered invitation',
      () async {
        final org = await service.create(admin, 'Alpha');
        final failed = WorkspaceService(
          mailer: (s, email, org, role, url, id) async {
            throw StateError('mail unavailable');
          },
        );
        await expectLater(
          failed.invite(
            admin,
            org.id,
            'failed@example.com',
            WorkspaceRole.viewer,
          ),
          throwsA(isA<WorkspaceException>()),
        );
        expect(
          (await service.invitations(admin, org.id)).single.status,
          'Revoked',
        );
      },
    );

    test(
      'concurrent accepts create one membership; concurrent Admin changes preserve one Admin',
      () async {
        final org = await service.create(admin, 'Alpha');
        final other = await account('second-admin@example.com');
        await service.invite(
          admin,
          org.id,
          'second-admin@example.com',
          WorkspaceRole.admin,
        );
        final raw = token(sentUrl);
        final accepts = await Future.wait([
          service.accept(other, raw).then((_) => true).catchError((_) => false),
          service.accept(other, raw).then((_) => true).catchError((_) => false),
        ]);
        expect(accepts.where((ok) => ok), hasLength(1));
        final members = await service.members(admin, org.id);
        final own = members.firstWhere((m) => m.isCurrentUser);
        final second = members.firstWhere((m) => !m.isCurrentUser);
        final changes = await Future.wait([
          service
              .changeRole(admin, org.id, own.id, WorkspaceRole.viewer)
              .then((_) => true)
              .catchError((_) => false),
          service
              .changeRole(other, org.id, second.id, WorkspaceRole.viewer)
              .then((_) => true)
              .catchError((_) => false),
        ]);
        expect(changes.where((ok) => ok), hasLength(1));
        final remaining = (await WorkspaceMember.db.find(
          admin,
          where: (t) => t.workspaceId.equals(org.id),
        )).where((m) => m.role == WorkspaceRole.admin);
        expect(remaining, hasLength(1));
      },
    );

    test(
      'share links join the addressed teammate without invoking email delivery',
      () async {
        final org = await service.create(admin, 'Alpha');
        final recipient = await account('share@example.com');
        final links = WorkspaceService(
          mailer: (s, email, org, role, url, id) async {
            fail('Share links must not send email.');
          },
        );
        final delivery = await links.invite(
          admin,
          org.id,
          'share@example.com',
          WorkspaceRole.editor,
          sendEmail: false,
        );
        expect(delivery.emailSent, isFalse);
        final joined = await service.accept(recipient, token(delivery.url));
        expect(joined.role, WorkspaceRole.editor);
      },
    );

    test('workspace endpoints reject anonymous sessions', () async {
      await expectLater(
        endpoints.workspace.list(sessions),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });
  }, rollbackDatabase: RollbackDatabase.disabled);

  test('invitation email escapes untrusted workspace names', () {
    final html = invitationHtml(
      '<img src=x onerror=alert(1)>',
      'viewer',
      'https://app.example/#/invite?token=safe&x=1',
    );
    expect(html, contains('&lt;img'));
    expect(html, isNot(contains('<img src=x')));
    expect(html, contains('7 days'));
    expect(html, contains('Join workspace'));
  });
}
