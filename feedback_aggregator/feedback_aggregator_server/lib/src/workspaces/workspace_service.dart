import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../auth/auth_email.dart';
import '../generated/protocol.dart';

typedef InvitationMailer =
    Future<void> Function(
      Session session,
      String email,
      String workspaceName,
      WorkspaceRole role,
      String url,
      int invitationId,
    );

/// All tenant data access lives behind this service. Never trust a client role
/// or tenant ID without checking its membership using the signed-in identity.
class WorkspaceService {
  final InvitationMailer mailer;
  WorkspaceService({InvitationMailer? mailer}) : mailer = mailer ?? _sendInvite;

  static Future<void> _sendInvite(
    Session session,
    String email,
    String name,
    WorkspaceRole role,
    String url,
    int id,
  ) =>
      AuthEmailSender(
        apiKey: session.serverpod.getPassword('resendApiKey') ?? '',
        from:
            session.serverpod.getPassword('resendFromEmail') ??
            'Feedback Aggregator <onboarding@resend.dev>',
      ).sendInvitation(
        session,
        email: email,
        workspaceName: name,
        role: role.name,
        url: url,
        invitationId: id,
      );

  UuidValue userId(Session session) {
    final auth = session.authenticated;
    if (auth == null) throw WorkspaceException(message: 'Please sign in.');
    return UuidValue.fromString(auth.userIdentifier);
  }

  Future<WorkspaceMember> _member(Session s, int id, {Transaction? tx}) async {
    final member = await WorkspaceMember.db.findFirstRow(
      s,
      where: (t) => t.workspaceId.equals(id) & t.authUserId.equals(userId(s)),
      transaction: tx,
    );
    if (member == null) {
      throw WorkspaceException(message: 'Workspace access denied.');
    }
    return member;
  }

  void _admin(WorkspaceMember member) {
    if (member.role != WorkspaceRole.admin) {
      throw WorkspaceException(message: 'Only an Admin can manage the team.');
    }
  }

  /// Serialize membership changes, invite acceptance and writes in each tenant.
  /// This also prevents two Admins from removing/demoting the last Admin at once.
  Future<Workspace> _lock(Session s, int id, Transaction tx) async {
    final org = await Workspace.db.findById(
      s,
      id,
      transaction: tx,
      lockMode: LockMode.forUpdate,
    );
    if (org == null) {
      throw WorkspaceException(message: 'Workspace access denied.');
    }
    return org;
  }

  WorkspaceSummary _summary(Workspace org, WorkspaceRole role) =>
      WorkspaceSummary(id: org.id!, name: org.name, role: role);

  Future<List<WorkspaceSummary>> list(Session s) async {
    final members = await WorkspaceMember.db.find(
      s,
      where: (t) => t.authUserId.equals(userId(s)),
      orderBy: (t) => t.id,
    );
    if (members.isEmpty) return [];
    final orgs = await Workspace.db.find(
      s,
      where: (t) => t.id.inSet(members.map((m) => m.workspaceId).toSet()),
    );
    return [
      for (final org in orgs)
        _summary(org, members.firstWhere((m) => m.workspaceId == org.id).role),
    ];
  }

  Future<WorkspaceSummary> create(Session s, String name) async {
    name = name.trim();
    if (name.isEmpty || name.length > 80) {
      throw WorkspaceException(
        message: 'Use a workspace name of 1–80 characters.',
      );
    }
    final id = userId(s);
    final profile = await AuthServices.instance.userProfiles
        .findUserProfileByUserId(s, id);
    return s.db.transaction((tx) async {
      final org = await Workspace.db.insertRow(
        s,
        Workspace(name: name),
        transaction: tx,
      );
      await WorkspaceMember.db.insertRow(
        s,
        WorkspaceMember(
          workspaceId: org.id!,
          authUserId: id,
          email: profile.email?.toLowerCase() ?? '',
          name:
              profile.fullName ?? profile.userName ?? profile.email ?? 'Member',
          role: WorkspaceRole.admin,
        ),
        transaction: tx,
      );
      return _summary(org, WorkspaceRole.admin);
    });
  }

  Future<List<MemberInfo>> members(Session s, int id) async {
    await _member(s, id);
    final rows = await WorkspaceMember.db.find(
      s,
      where: (t) => t.workspaceId.equals(id),
      orderBy: (t) => t.id,
    );
    return [
      for (final m in rows)
        MemberInfo(
          id: m.id!,
          name: m.name,
          email: m.email,
          role: m.role,
          isCurrentUser: m.authUserId == userId(s),
        ),
    ];
  }

  Future<void> changeRole(
    Session s,
    int id,
    int memberId,
    WorkspaceRole role,
  ) => s.db.transaction((tx) async {
    await _lock(s, id, tx);
    _admin(await _member(s, id, tx: tx));
    final target = await WorkspaceMember.db.findFirstRow(
      s,
      where: (t) => t.id.equals(memberId) & t.workspaceId.equals(id),
      transaction: tx,
    );
    if (target == null) throw WorkspaceException(message: 'Member not found.');
    await _protectLastAdmin(s, target, role == WorkspaceRole.admin, tx);
    target.role = role;
    await WorkspaceMember.db.updateRow(s, target, transaction: tx);
  });

  Future<void> removeMember(Session s, int id, int memberId) =>
      s.db.transaction((tx) async {
        await _lock(s, id, tx);
        _admin(await _member(s, id, tx: tx));
        final target = await WorkspaceMember.db.findFirstRow(
          s,
          where: (t) => t.id.equals(memberId) & t.workspaceId.equals(id),
          transaction: tx,
        );
        if (target == null) {
          throw WorkspaceException(message: 'Member not found.');
        }
        await _protectLastAdmin(s, target, false, tx);
        await WorkspaceMember.db.deleteRow(s, target, transaction: tx);
      });

  Future<void> _protectLastAdmin(
    Session s,
    WorkspaceMember target,
    bool remainsAdmin,
    Transaction tx,
  ) async {
    if (target.role != WorkspaceRole.admin || remainsAdmin) return;
    final count = await WorkspaceMember.db.count(
      s,
      where: (t) =>
          t.workspaceId.equals(target.workspaceId) &
          t.role.equals(WorkspaceRole.admin),
      transaction: tx,
    );
    if (count <= 1) {
      throw WorkspaceException(
        message: 'Keep at least one Admin in the workspace.',
      );
    }
  }

  InvitationInfo _inviteInfo(WorkspaceInvitation i, String name) =>
      InvitationInfo(
        id: i.id!,
        workspaceName: name,
        email: i.email,
        role: i.role,
        expiresAt: i.expiresAt,
        status: i.revokedAt != null
            ? 'Revoked'
            : i.acceptedAt != null
            ? 'Accepted'
            : i.expiresAt.isBefore(DateTime.now().toUtc())
            ? 'Expired'
            : 'Pending',
      );

  Future<List<InvitationInfo>> invitations(Session s, int id) async {
    _admin(await _member(s, id));
    final org = await Workspace.db.findById(s, id);
    final rows = await WorkspaceInvitation.db.find(
      s,
      where: (t) => t.workspaceId.equals(id),
      orderBy: (t) => t.createdAt.desc(),
      limit: 100,
    );
    return rows.map((i) => _inviteInfo(i, org!.name)).toList();
  }

  Future<InvitationDelivery> invite(
    Session s,
    int id,
    String email,
    WorkspaceRole role, {
    bool sendEmail = true,
  }) async {
    email = email.trim().toLowerCase();
    if (email.length > 254 ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      throw WorkspaceException(message: 'Enter a valid invitation email.');
    }
    final random = Random.secure();
    final token = base64Url
        .encode(List.generate(32, (_) => random.nextInt(256)))
        .replaceAll('=', '');
    final hash = sha256.convert(utf8.encode(token)).toString();
    final result = await s.db.transaction((tx) async {
      final org = await _lock(s, id, tx);
      _admin(await _member(s, id, tx: tx));
      final existing = await WorkspaceMember.db.findFirstRow(
        s,
        where: (t) => t.workspaceId.equals(id) & t.email.equals(email),
        transaction: tx,
      );
      if (existing != null) {
        throw WorkspaceException(message: 'This email is already a member.');
      }
      // Reissuing revokes older links to the same inbox, including changed roles.
      final old = await WorkspaceInvitation.db.find(
        s,
        where: (t) =>
            t.workspaceId.equals(id) &
            t.email.equals(email) &
            t.acceptedAt.equals(null) &
            t.revokedAt.equals(null),
        transaction: tx,
      );
      for (final i in old) {
        i.revokedAt = DateTime.now().toUtc();
        await WorkspaceInvitation.db.updateRow(s, i, transaction: tx);
      }
      final row = await WorkspaceInvitation.db.insertRow(
        s,
        WorkspaceInvitation(
          workspaceId: id,
          email: email,
          role: role,
          tokenHash: hash,
          createdBy: userId(s),
          expiresAt: DateTime.now().toUtc().add(const Duration(days: 7)),
        ),
        transaction: tx,
      );
      return (org, row);
    });
    final config = s.serverpod.config.webServer!;
    final origin = Uri(
      scheme: config.publicScheme,
      host: config.publicHost,
      port: config.publicPort,
      path: '/',
      fragment: '/invite?token=$token',
    );
    if (!sendEmail) {
      return InvitationDelivery(
        invitation: _inviteInfo(result.$2, result.$1.name),
        url: origin.toString(),
        emailSent: false,
      );
    }
    try {
      await mailer(
        s,
        email,
        result.$1.name,
        role,
        origin.toString(),
        result.$2.id!,
      );
    } catch (_) {
      // A failed delivery must not leave a usable link or silently claim success.
      await s.db.transaction((tx) async {
        await _lock(s, id, tx);
        final failed = await WorkspaceInvitation.db.findById(
          s,
          result.$2.id!,
          transaction: tx,
        );
        if (failed != null) {
          failed.revokedAt = DateTime.now().toUtc();
          await WorkspaceInvitation.db.updateRow(s, failed, transaction: tx);
        }
      });
      throw WorkspaceException(
        message:
            'Invitation email could not be sent. Check Resend and the verified sender domain, then try again.',
      );
    }
    return InvitationDelivery(
      invitation: _inviteInfo(result.$2, result.$1.name),
      url: origin.toString(),
      emailSent: true,
    );
  }

  Future<void> revoke(Session s, int id, int invitationId) => s.db.transaction((
    tx,
  ) async {
    await _lock(s, id, tx);
    _admin(await _member(s, id, tx: tx));
    final i = await WorkspaceInvitation.db.findFirstRow(
      s,
      where: (t) => t.id.equals(invitationId) & t.workspaceId.equals(id),
      transaction: tx,
    );
    if (i == null) throw WorkspaceException(message: 'Invitation not found.');
    i.revokedAt = DateTime.now().toUtc();
    await WorkspaceInvitation.db.updateRow(s, i, transaction: tx);
  });

  Future<WorkspaceInvitation> _token(
    Session s,
    String token, {
    Transaction? tx,
  }) async {
    if (!RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(token)) {
      throw WorkspaceException(
        message: 'This invitation is invalid or no longer available.',
      );
    }
    final hash = sha256.convert(utf8.encode(token)).toString();
    final i = await WorkspaceInvitation.db.findFirstRow(
      s,
      where: (t) => t.tokenHash.equals(hash),
      transaction: tx,
    );
    if (i == null ||
        i.acceptedAt != null ||
        i.revokedAt != null ||
        !i.expiresAt.isAfter(DateTime.now().toUtc())) {
      throw WorkspaceException(
        message: 'This invitation is invalid or no longer available.',
      );
    }
    final profile = await AuthServices.instance.userProfiles
        .findUserProfileByUserId(s, userId(s), transaction: tx);
    if (profile.email?.trim().toLowerCase() != i.email) {
      throw WorkspaceException(
        message: 'Sign in with the email address this invitation was sent to.',
      );
    }
    return i;
  }

  Future<InvitationInfo> preview(Session s, String token) async {
    final i = await _token(s, token);
    final org = await Workspace.db.findById(s, i.workspaceId);
    if (org == null) {
      throw WorkspaceException(message: 'Workspace no longer exists.');
    }
    return _inviteInfo(i, org.name);
  }

  Future<WorkspaceSummary> accept(Session s, String token) async {
    final initial = await _token(s, token);
    return s.db.transaction((tx) async {
      final org = await _lock(s, initial.workspaceId, tx);
      final i = await _token(s, token, tx: tx);
      final profile = await AuthServices.instance.userProfiles
          .findUserProfileByUserId(s, userId(s), transaction: tx);
      var member = await WorkspaceMember.db.findFirstRow(
        s,
        where: (t) =>
            t.workspaceId.equals(i.workspaceId) &
            t.authUserId.equals(userId(s)),
        transaction: tx,
      );
      // An invite never overwrites privileges of an existing membership.
      member ??= await WorkspaceMember.db.insertRow(
        s,
        WorkspaceMember(
          workspaceId: i.workspaceId,
          authUserId: userId(s),
          email: i.email,
          name: profile.fullName ?? profile.userName ?? i.email,
          role: i.role,
        ),
        transaction: tx,
      );
      i.acceptedAt = DateTime.now().toUtc();
      await WorkspaceInvitation.db.updateRow(s, i, transaction: tx);
      return _summary(org, member.role);
    });
  }

  Future<List<WorkspaceTicket>> tickets(Session s, int id) async {
    await _member(s, id);
    return WorkspaceTicket.db.find(
      s,
      where: (t) => t.workspaceId.equals(id),
      orderBy: (t) => t.createdAt.desc(),
      limit: 500,
    );
  }

  Future<WorkspaceTicket> createTicket(
    Session s,
    int id,
    String title,
    String description,
    String source,
    String priority,
  ) => s.db.transaction((tx) async {
    await _lock(s, id, tx);
    final member = await _member(s, id, tx: tx);
    if (member.role == WorkspaceRole.viewer) {
      throw WorkspaceException(message: 'Viewers have read-only access.');
    }
    title = title.trim();
    description = description.trim();
    if (title.isEmpty ||
        title.length > 200 ||
        description.length > 5000 ||
        ![
          'Forms',
          'Email',
          'Slack',
          'Support',
          'App reviews',
        ].contains(source) ||
        !['High', 'Medium', 'Low'].contains(priority)) {
      throw WorkspaceException(
        message: 'Check the ticket title, description, source, and priority.',
      );
    }
    return WorkspaceTicket.db.insertRow(
      s,
      WorkspaceTicket(
        workspaceId: id,
        title: title,
        description: description,
        source: source,
        status: 'Open',
        priority: priority,
        supporters: 1,
        requester: member.name,
      ),
      transaction: tx,
    );
  });

  Future<WorkspaceTicket> updateTicketStatus(
    Session s,
    int id,
    int ticketId,
    String status,
  ) => s.db.transaction((tx) async {
    await _lock(s, id, tx);
    if ((await _member(s, id, tx: tx)).role == WorkspaceRole.viewer) {
      throw WorkspaceException(message: 'Viewers have read-only access.');
    }
    if (!['Open', 'Planned', 'In progress', 'Resolved'].contains(status)) {
      throw WorkspaceException(message: 'Invalid ticket status.');
    }
    final ticket = await WorkspaceTicket.db.findFirstRow(
      s,
      where: (t) => t.workspaceId.equals(id) & t.id.equals(ticketId),
      transaction: tx,
    );
    if (ticket == null) {
      throw WorkspaceException(message: 'Ticket not found in this workspace.');
    }
    ticket.status = status;
    return WorkspaceTicket.db.updateRow(s, ticket, transaction: tx);
  });
}
