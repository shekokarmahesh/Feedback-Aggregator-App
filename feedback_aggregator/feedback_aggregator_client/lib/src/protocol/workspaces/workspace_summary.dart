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

abstract class WorkspaceSummary
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  WorkspaceSummary._({
    required this.id,
    required this.name,
    required this.role,
  });

  factory WorkspaceSummary({
    required int id,
    required String name,
    required _ibbf7qu4.WorkspaceRole role,
  }) = _WorkspaceSummaryImpl;

  factory WorkspaceSummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return WorkspaceSummary(
      id: jsonSerialization['id'] as int,
      name: jsonSerialization['name'] as String,
      role: _ibbf7qu4.WorkspaceRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
    );
  }

  int id;

  String name;

  _ibbf7qu4.WorkspaceRole role;

  /// Returns a shallow copy of this [WorkspaceSummary]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  WorkspaceSummary copyWith({
    int? id,
    String? name,
    _ibbf7qu4.WorkspaceRole? role,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WorkspaceSummary',
      'id': id,
      'name': name,
      'role': role.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WorkspaceSummary',
      'id': id,
      'name': name,
      'role': role.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _WorkspaceSummaryImpl extends WorkspaceSummary {
  _WorkspaceSummaryImpl({
    required int id,
    required String name,
    required _ibbf7qu4.WorkspaceRole role,
  }) : super._(
         id: id,
         name: name,
         role: role,
       );

  /// Returns a shallow copy of this [WorkspaceSummary]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  WorkspaceSummary copyWith({
    int? id,
    String? name,
    _ibbf7qu4.WorkspaceRole? role,
  }) {
    return WorkspaceSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
    );
  }
}
