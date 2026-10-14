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

abstract class WorkspaceTicket
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  WorkspaceTicket._({
    this.id,
    required this.workspaceId,
    required this.title,
    required this.description,
    required this.source,
    required this.status,
    required this.priority,
    required this.supporters,
    required this.requester,
    bool? isMock,
    this.externalId,
    this.issueGroupId,
    String? groupingState,
    this.groupingConfidence,
    this.severity,
    DateTime? createdAt,
  }) : isMock = isMock ?? false,
       groupingState = groupingState ?? 'pending',
       createdAt = createdAt ?? DateTime.now();

  factory WorkspaceTicket({
    int? id,
    required int workspaceId,
    required String title,
    required String description,
    required String source,
    required String status,
    required String priority,
    required int supporters,
    required String requester,
    bool? isMock,
    String? externalId,
    int? issueGroupId,
    String? groupingState,
    double? groupingConfidence,
    double? severity,
    DateTime? createdAt,
  }) = _WorkspaceTicketImpl;

  factory WorkspaceTicket.fromJson(Map<String, dynamic> jsonSerialization) {
    return WorkspaceTicket(
      id: jsonSerialization['id'] as int?,
      workspaceId: jsonSerialization['workspaceId'] as int,
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String,
      source: jsonSerialization['source'] as String,
      status: jsonSerialization['status'] as String,
      priority: jsonSerialization['priority'] as String,
      supporters: jsonSerialization['supporters'] as int,
      requester: jsonSerialization['requester'] as String,
      isMock: jsonSerialization['isMock'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['isMock']),
      externalId: jsonSerialization['externalId'] as String?,
      issueGroupId: jsonSerialization['issueGroupId'] as int?,
      groupingState: jsonSerialization['groupingState'] as String?,
      groupingConfidence: (jsonSerialization['groupingConfidence'] as num?)
          ?.toDouble(),
      severity: (jsonSerialization['severity'] as num?)?.toDouble(),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int workspaceId;

  String title;

  String description;

  String source;

  String status;

  String priority;

  int supporters;

  String requester;

  bool isMock;

  String? externalId;

  int? issueGroupId;

  String groupingState;

  double? groupingConfidence;

  double? severity;

  DateTime createdAt;

  /// Returns a shallow copy of this [WorkspaceTicket]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  WorkspaceTicket copyWith({
    int? id,
    int? workspaceId,
    String? title,
    String? description,
    String? source,
    String? status,
    String? priority,
    int? supporters,
    String? requester,
    bool? isMock,
    String? externalId,
    int? issueGroupId,
    String? groupingState,
    double? groupingConfidence,
    double? severity,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WorkspaceTicket',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'title': title,
      'description': description,
      'source': source,
      'status': status,
      'priority': priority,
      'supporters': supporters,
      'requester': requester,
      'isMock': isMock,
      if (externalId != null) 'externalId': externalId,
      if (issueGroupId != null) 'issueGroupId': issueGroupId,
      'groupingState': groupingState,
      if (groupingConfidence != null) 'groupingConfidence': groupingConfidence,
      if (severity != null) 'severity': severity,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WorkspaceTicket',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'title': title,
      'description': description,
      'source': source,
      'status': status,
      'priority': priority,
      'supporters': supporters,
      'requester': requester,
      'isMock': isMock,
      if (externalId != null) 'externalId': externalId,
      if (issueGroupId != null) 'issueGroupId': issueGroupId,
      'groupingState': groupingState,
      if (groupingConfidence != null) 'groupingConfidence': groupingConfidence,
      if (severity != null) 'severity': severity,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WorkspaceTicketImpl extends WorkspaceTicket {
  _WorkspaceTicketImpl({
    int? id,
    required int workspaceId,
    required String title,
    required String description,
    required String source,
    required String status,
    required String priority,
    required int supporters,
    required String requester,
    bool? isMock,
    String? externalId,
    int? issueGroupId,
    String? groupingState,
    double? groupingConfidence,
    double? severity,
    DateTime? createdAt,
  }) : super._(
         id: id,
         workspaceId: workspaceId,
         title: title,
         description: description,
         source: source,
         status: status,
         priority: priority,
         supporters: supporters,
         requester: requester,
         isMock: isMock,
         externalId: externalId,
         issueGroupId: issueGroupId,
         groupingState: groupingState,
         groupingConfidence: groupingConfidence,
         severity: severity,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [WorkspaceTicket]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  WorkspaceTicket copyWith({
    Object? id = _Undefined,
    int? workspaceId,
    String? title,
    String? description,
    String? source,
    String? status,
    String? priority,
    int? supporters,
    String? requester,
    bool? isMock,
    Object? externalId = _Undefined,
    Object? issueGroupId = _Undefined,
    String? groupingState,
    Object? groupingConfidence = _Undefined,
    Object? severity = _Undefined,
    DateTime? createdAt,
  }) {
    return WorkspaceTicket(
      id: id is int? ? id : this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      title: title ?? this.title,
      description: description ?? this.description,
      source: source ?? this.source,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      supporters: supporters ?? this.supporters,
      requester: requester ?? this.requester,
      isMock: isMock ?? this.isMock,
      externalId: externalId is String? ? externalId : this.externalId,
      issueGroupId: issueGroupId is int? ? issueGroupId : this.issueGroupId,
      groupingState: groupingState ?? this.groupingState,
      groupingConfidence: groupingConfidence is double?
          ? groupingConfidence
          : this.groupingConfidence,
      severity: severity is double? ? severity : this.severity,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
