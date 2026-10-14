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
import 'package:feedback_aggregator_client/src/protocol/protocol.dart'
    as _iji4d5h2;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../workspaces/mock_source_connection.dart' as _i7kjqdh5;

abstract class SourceSyncResult
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SourceSyncResult._({
    required this.connection,
    required this.addedCount,
  });

  factory SourceSyncResult({
    required _i7kjqdh5.MockSourceConnection connection,
    required int addedCount,
  }) = _SourceSyncResultImpl;

  factory SourceSyncResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return SourceSyncResult(
      connection: _iji4d5h2.Protocol()
          .deserialize<_i7kjqdh5.MockSourceConnection>(
            jsonSerialization['connection'],
          ),
      addedCount: jsonSerialization['addedCount'] as int,
    );
  }

  _i7kjqdh5.MockSourceConnection connection;

  int addedCount;

  /// Returns a shallow copy of this [SourceSyncResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SourceSyncResult copyWith({
    _i7kjqdh5.MockSourceConnection? connection,
    int? addedCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SourceSyncResult',
      'connection': connection.toJson(),
      'addedCount': addedCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SourceSyncResult',
      'connection': connection.toJsonForProtocol(),
      'addedCount': addedCount,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _SourceSyncResultImpl extends SourceSyncResult {
  _SourceSyncResultImpl({
    required _i7kjqdh5.MockSourceConnection connection,
    required int addedCount,
  }) : super._(
         connection: connection,
         addedCount: addedCount,
       );

  /// Returns a shallow copy of this [SourceSyncResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SourceSyncResult copyWith({
    _i7kjqdh5.MockSourceConnection? connection,
    int? addedCount,
  }) {
    return SourceSyncResult(
      connection: connection ?? this.connection.copyWith(),
      addedCount: addedCount ?? this.addedCount,
    );
  }
}
