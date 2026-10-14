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

abstract class MockSourceConnection
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  MockSourceConnection._({
    this.id,
    required this.workspaceId,
    required this.source,
    bool? connected,
    this.connectedAt,
    this.lastSyncedAt,
    int? syncedCount,
    int? availableCount,
  }) : connected = connected ?? false,
       syncedCount = syncedCount ?? 0,
       availableCount = availableCount ?? 0;

  factory MockSourceConnection({
    int? id,
    required int workspaceId,
    required String source,
    bool? connected,
    DateTime? connectedAt,
    DateTime? lastSyncedAt,
    int? syncedCount,
    int? availableCount,
  }) = _MockSourceConnectionImpl;

  factory MockSourceConnection.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MockSourceConnection(
      id: jsonSerialization['id'] as int?,
      workspaceId: jsonSerialization['workspaceId'] as int,
      source: jsonSerialization['source'] as String,
      connected: jsonSerialization['connected'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['connected']),
      connectedAt: jsonSerialization['connectedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['connectedAt'],
            ),
      lastSyncedAt: jsonSerialization['lastSyncedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSyncedAt'],
            ),
      syncedCount: jsonSerialization['syncedCount'] as int?,
      availableCount: jsonSerialization['availableCount'] as int?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int workspaceId;

  String source;

  bool connected;

  DateTime? connectedAt;

  DateTime? lastSyncedAt;

  int syncedCount;

  int availableCount;

  /// Returns a shallow copy of this [MockSourceConnection]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  MockSourceConnection copyWith({
    int? id,
    int? workspaceId,
    String? source,
    bool? connected,
    DateTime? connectedAt,
    DateTime? lastSyncedAt,
    int? syncedCount,
    int? availableCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MockSourceConnection',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'source': source,
      'connected': connected,
      if (connectedAt != null) 'connectedAt': connectedAt?.toJson(),
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
      'syncedCount': syncedCount,
      'availableCount': availableCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MockSourceConnection',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'source': source,
      'connected': connected,
      if (connectedAt != null) 'connectedAt': connectedAt?.toJson(),
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
      'syncedCount': syncedCount,
      'availableCount': availableCount,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MockSourceConnectionImpl extends MockSourceConnection {
  _MockSourceConnectionImpl({
    int? id,
    required int workspaceId,
    required String source,
    bool? connected,
    DateTime? connectedAt,
    DateTime? lastSyncedAt,
    int? syncedCount,
    int? availableCount,
  }) : super._(
         id: id,
         workspaceId: workspaceId,
         source: source,
         connected: connected,
         connectedAt: connectedAt,
         lastSyncedAt: lastSyncedAt,
         syncedCount: syncedCount,
         availableCount: availableCount,
       );

  /// Returns a shallow copy of this [MockSourceConnection]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  MockSourceConnection copyWith({
    Object? id = _Undefined,
    int? workspaceId,
    String? source,
    bool? connected,
    Object? connectedAt = _Undefined,
    Object? lastSyncedAt = _Undefined,
    int? syncedCount,
    int? availableCount,
  }) {
    return MockSourceConnection(
      id: id is int? ? id : this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      source: source ?? this.source,
      connected: connected ?? this.connected,
      connectedAt: connectedAt is DateTime? ? connectedAt : this.connectedAt,
      lastSyncedAt: lastSyncedAt is DateTime?
          ? lastSyncedAt
          : this.lastSyncedAt,
      syncedCount: syncedCount ?? this.syncedCount,
      availableCount: availableCount ?? this.availableCount,
    );
  }
}
