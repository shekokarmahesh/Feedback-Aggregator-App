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

/// Feedback received from a user through a source channel.
abstract class Feedback
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Feedback._({
    this.id,
    required this.teamId,
    required this.title,
    required this.body,
    required this.source,
    required this.userEmail,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Feedback({
    int? id,
    required int teamId,
    required String title,
    required String body,
    required String source,
    required String userEmail,
    DateTime? createdAt,
  }) = _FeedbackImpl;

  factory Feedback.fromJson(Map<String, dynamic> jsonSerialization) {
    return Feedback(
      id: jsonSerialization['id'] as int?,
      teamId: jsonSerialization['teamId'] as int,
      title: jsonSerialization['title'] as String,
      body: jsonSerialization['body'] as String,
      source: jsonSerialization['source'] as String,
      userEmail: jsonSerialization['userEmail'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// Workspace determined by the authenticated ingestion key, never by payload.
  int teamId;

  /// Short summary of the feedback.
  String title;

  /// Full feedback text.
  String body;

  /// Originating channel, such as email, Slack, forms, or support.
  String source;

  /// Submitter's email address; does not prove ownership or grant access.
  String userEmail;

  /// Time the feedback was recorded, in UTC.
  DateTime createdAt;

  /// Returns a shallow copy of this [Feedback]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Feedback copyWith({
    int? id,
    int? teamId,
    String? title,
    String? body,
    String? source,
    String? userEmail,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Feedback',
      if (id != null) 'id': id,
      'teamId': teamId,
      'title': title,
      'body': body,
      'source': source,
      'userEmail': userEmail,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Feedback',
      if (id != null) 'id': id,
      'teamId': teamId,
      'title': title,
      'body': body,
      'source': source,
      'userEmail': userEmail,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FeedbackImpl extends Feedback {
  _FeedbackImpl({
    int? id,
    required int teamId,
    required String title,
    required String body,
    required String source,
    required String userEmail,
    DateTime? createdAt,
  }) : super._(
         id: id,
         teamId: teamId,
         title: title,
         body: body,
         source: source,
         userEmail: userEmail,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Feedback]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Feedback copyWith({
    Object? id = _Undefined,
    int? teamId,
    String? title,
    String? body,
    String? source,
    String? userEmail,
    DateTime? createdAt,
  }) {
    return Feedback(
      id: id is int? ? id : this.id,
      teamId: teamId ?? this.teamId,
      title: title ?? this.title,
      body: body ?? this.body,
      source: source ?? this.source,
      userEmail: userEmail ?? this.userEmail,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
