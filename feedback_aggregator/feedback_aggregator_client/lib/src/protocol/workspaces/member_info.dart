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
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../workspaces/workspace_role.dart' as _ibbf7qu4;

abstract class MemberInfo
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  MemberInfo._({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isCurrentUser,
  });

  factory MemberInfo({
    required int id,
    required String name,
    required String email,
    required _ibbf7qu4.WorkspaceRole role,
    required bool isCurrentUser,
  }) = _MemberInfoImpl;

  factory MemberInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return MemberInfo(
      id: jsonSerialization['id'] as int,
      name: jsonSerialization['name'] as String,
      email: jsonSerialization['email'] as String,
      role: _ibbf7qu4.WorkspaceRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      isCurrentUser: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['isCurrentUser'],
      ),
    );
  }

  int id;

  String name;

  String email;

  _ibbf7qu4.WorkspaceRole role;

  bool isCurrentUser;

  /// Returns a shallow copy of this [MemberInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  MemberInfo copyWith({
    int? id,
    String? name,
    String? email,
    _ibbf7qu4.WorkspaceRole? role,
    bool? isCurrentUser,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MemberInfo',
      'id': id,
      'name': name,
      'email': email,
      'role': role.toJson(),
      'isCurrentUser': isCurrentUser,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MemberInfo',
      'id': id,
      'name': name,
      'email': email,
      'role': role.toJson(),
      'isCurrentUser': isCurrentUser,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _MemberInfoImpl extends MemberInfo {
  _MemberInfoImpl({
    required int id,
    required String name,
    required String email,
    required _ibbf7qu4.WorkspaceRole role,
    required bool isCurrentUser,
  }) : super._(
         id: id,
         name: name,
         email: email,
         role: role,
         isCurrentUser: isCurrentUser,
       );

  /// Returns a shallow copy of this [MemberInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  MemberInfo copyWith({
    int? id,
    String? name,
    String? email,
    _ibbf7qu4.WorkspaceRole? role,
    bool? isCurrentUser,
  }) {
    return MemberInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}
