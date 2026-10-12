/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;
import '../workspaces/workspace_role.dart' as _ibbf7qu4;

abstract class InvitationInfo
    implements _is.SerializableModel, _is.ProtocolSerialization {
  InvitationInfo._({
    required this.id,
    required this.workspaceName,
    required this.email,
    required this.role,
    required this.expiresAt,
    required this.status,
  });

  factory InvitationInfo({
    required int id,
    required String workspaceName,
    required String email,
    required _ibbf7qu4.WorkspaceRole role,
    required DateTime expiresAt,
    required String status,
  }) = _InvitationInfoImpl;

  factory InvitationInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return InvitationInfo(
      id: jsonSerialization['id'] as int,
      workspaceName: jsonSerialization['workspaceName'] as String,
      email: jsonSerialization['email'] as String,
      role: _ibbf7qu4.WorkspaceRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      status: jsonSerialization['status'] as String,
    );
  }

  int id;

  String workspaceName;

  String email;

  _ibbf7qu4.WorkspaceRole role;

  DateTime expiresAt;

  String status;

  /// Returns a shallow copy of this [InvitationInfo]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  InvitationInfo copyWith({
    int? id,
    String? workspaceName,
    String? email,
    _ibbf7qu4.WorkspaceRole? role,
    DateTime? expiresAt,
    String? status,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'InvitationInfo',
      'id': id,
      'workspaceName': workspaceName,
      'email': email,
      'role': role.toJson(),
      'expiresAt': expiresAt.toJson(),
      'status': status,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'InvitationInfo',
      'id': id,
      'workspaceName': workspaceName,
      'email': email,
      'role': role.toJson(),
      'expiresAt': expiresAt.toJson(),
      'status': status,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _InvitationInfoImpl extends InvitationInfo {
  _InvitationInfoImpl({
    required int id,
    required String workspaceName,
    required String email,
    required _ibbf7qu4.WorkspaceRole role,
    required DateTime expiresAt,
    required String status,
  }) : super._(
         id: id,
         workspaceName: workspaceName,
         email: email,
         role: role,
         expiresAt: expiresAt,
         status: status,
       );

  /// Returns a shallow copy of this [InvitationInfo]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  InvitationInfo copyWith({
    int? id,
    String? workspaceName,
    String? email,
    _ibbf7qu4.WorkspaceRole? role,
    DateTime? expiresAt,
    String? status,
  }) {
    return InvitationInfo(
      id: id ?? this.id,
      workspaceName: workspaceName ?? this.workspaceName,
      email: email ?? this.email,
      role: role ?? this.role,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
    );
  }
}
