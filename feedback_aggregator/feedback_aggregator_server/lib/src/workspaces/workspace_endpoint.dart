import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../generated/protocol.dart';
import 'workspace_service.dart';

class WorkspaceEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;
  final _service = WorkspaceService();

  Future<List<WorkspaceSummary>> list(Session session) =>
      _service.list(session);
  Future<WorkspaceSummary> create(Session session, String name) async {
    await _limit(session, 'create', 10);
    return _service.create(session, name);
  }

  Future<List<MemberInfo>> members(Session session, int workspaceId) =>
      _service.members(session, workspaceId);
  Future<List<InvitationInfo>> invitations(Session session, int workspaceId) =>
      _service.invitations(session, workspaceId);
  Future<InvitationDelivery> invite(
    Session session,
    int workspaceId,
    String email,
    WorkspaceRole role,
  ) async {
    await _limit(session, 'invite', 30);
    return _service.invite(session, workspaceId, email, role);
  }

  Future<InvitationDelivery> createInvitationLink(
    Session session,
    int workspaceId,
    String email,
    WorkspaceRole role,
  ) async {
    await _limit(session, 'invite', 30);
    return _service.invite(session, workspaceId, email, role, sendEmail: false);
  }

  Future<void> revokeInvitation(
    Session session,
    int workspaceId,
    int invitationId,
  ) => _service.revoke(session, workspaceId, invitationId);
  Future<void> changeRole(
    Session session,
    int workspaceId,
    int memberId,
    WorkspaceRole role,
  ) => _service.changeRole(session, workspaceId, memberId, role);
  Future<void> removeMember(Session session, int workspaceId, int memberId) =>
      _service.removeMember(session, workspaceId, memberId);
  Future<InvitationInfo> previewInvitation(Session session, String token) =>
      _service.preview(session, token);
  Future<WorkspaceSummary> acceptInvitation(Session session, String token) =>
      _service.accept(session, token);
  Future<List<WorkspaceTicket>> tickets(Session session, int workspaceId) =>
      _service.tickets(session, workspaceId);
  Future<WorkspaceTicket> createTicket(
    Session session,
    int workspaceId,
    String title,
    String description,
    String source,
    String priority,
  ) => _service.createTicket(
    session,
    workspaceId,
    title,
    description,
    source,
    priority,
  );
  Future<WorkspaceTicket> updateTicketStatus(
    Session session,
    int workspaceId,
    int ticketId,
    String status,
  ) => _service.updateTicketStatus(session, workspaceId, ticketId, status);

  Future<void> _limit(Session session, String action, int count) async {
    final limiter = DatabaseRateLimiter(
      RateLimiterConfig(
        domain: 'workspace',
        source: action,
        maxAttempts: count,
        timeframe: const Duration(hours: 1),
      ),
    );
    if (!await limiter.tryRecordAttempt(
      session,
      key: _service.userId(session).toString(),
    )) {
      throw WorkspaceException(
        message: 'Too many requests. Please try again later.',
      );
    }
  }
}
