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
import 'package:feedback_aggregator_server/src/generated/protocol.dart'
    as _iwl9u20j;
import 'package:serverpod/serverpod.dart' as _is;
import '../workspaces/workspace_ticket.dart' as _ivn4ujqx;

abstract class GroupedTicket
    implements _is.SerializableModel, _is.ProtocolSerialization {
  GroupedTicket._({
    required this.id,
    required this.primaryTicketId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.priorityScore,
    required this.sources,
    required this.reports,
    required this.groupingState,
    this.confidence,
    required this.createdAt,
  });

  factory GroupedTicket({
    required int id,
    required int primaryTicketId,
    required String title,
    required String description,
    required String status,
    required String priority,
    required int priorityScore,
    required List<String> sources,
    required List<_ivn4ujqx.WorkspaceTicket> reports,
    required String groupingState,
    double? confidence,
    required DateTime createdAt,
  }) = _GroupedTicketImpl;

  factory GroupedTicket.fromJson(Map<String, dynamic> jsonSerialization) {
    return GroupedTicket(
      id: jsonSerialization['id'] as int,
      primaryTicketId: jsonSerialization['primaryTicketId'] as int,
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String,
      status: jsonSerialization['status'] as String,
      priority: jsonSerialization['priority'] as String,
      priorityScore: jsonSerialization['priorityScore'] as int,
      sources: _iwl9u20j.Protocol().deserialize<List<String>>(
        jsonSerialization['sources'],
      ),
      reports: _iwl9u20j.Protocol()
          .deserialize<List<_ivn4ujqx.WorkspaceTicket>>(
            jsonSerialization['reports'],
          ),
      groupingState: jsonSerialization['groupingState'] as String,
      confidence: (jsonSerialization['confidence'] as num?)?.toDouble(),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  int id;

  int primaryTicketId;

  String title;

  String description;

  String status;

  String priority;

  int priorityScore;

  List<String> sources;

  List<_ivn4ujqx.WorkspaceTicket> reports;

  String groupingState;

  double? confidence;

  DateTime createdAt;

  /// Returns a shallow copy of this [GroupedTicket]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  GroupedTicket copyWith({
    int? id,
    int? primaryTicketId,
    String? title,
    String? description,
    String? status,
    String? priority,
    int? priorityScore,
    List<String>? sources,
    List<_ivn4ujqx.WorkspaceTicket>? reports,
    String? groupingState,
    double? confidence,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GroupedTicket',
      'id': id,
      'primaryTicketId': primaryTicketId,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'priorityScore': priorityScore,
      'sources': sources.toJson(),
      'reports': reports.toJson(valueToJson: (v) => v.toJson()),
      'groupingState': groupingState,
      if (confidence != null) 'confidence': confidence,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GroupedTicket',
      'id': id,
      'primaryTicketId': primaryTicketId,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'priorityScore': priorityScore,
      'sources': sources.toJson(),
      'reports': reports.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'groupingState': groupingState,
      if (confidence != null) 'confidence': confidence,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GroupedTicketImpl extends GroupedTicket {
  _GroupedTicketImpl({
    required int id,
    required int primaryTicketId,
    required String title,
    required String description,
    required String status,
    required String priority,
    required int priorityScore,
    required List<String> sources,
    required List<_ivn4ujqx.WorkspaceTicket> reports,
    required String groupingState,
    double? confidence,
    required DateTime createdAt,
  }) : super._(
         id: id,
         primaryTicketId: primaryTicketId,
         title: title,
         description: description,
         status: status,
         priority: priority,
         priorityScore: priorityScore,
         sources: sources,
         reports: reports,
         groupingState: groupingState,
         confidence: confidence,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [GroupedTicket]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  GroupedTicket copyWith({
    int? id,
    int? primaryTicketId,
    String? title,
    String? description,
    String? status,
    String? priority,
    int? priorityScore,
    List<String>? sources,
    List<_ivn4ujqx.WorkspaceTicket>? reports,
    String? groupingState,
    Object? confidence = _Undefined,
    DateTime? createdAt,
  }) {
    return GroupedTicket(
      id: id ?? this.id,
      primaryTicketId: primaryTicketId ?? this.primaryTicketId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      priorityScore: priorityScore ?? this.priorityScore,
      sources: sources ?? this.sources.map((e0) => e0).toList(),
      reports: reports ?? this.reports.map((e0) => e0.copyWith()).toList(),
      groupingState: groupingState ?? this.groupingState,
      confidence: confidence is double? ? confidence : this.confidence,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
