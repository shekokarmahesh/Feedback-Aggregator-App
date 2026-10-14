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

/// Server-only mapping from a hashed ingestion key to a team.
abstract class FeedbackWebhookKey
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  FeedbackWebhookKey._({
    this.id,
    required this.teamId,
    required this.keyHash,
    required this.createdByUserId,
    DateTime? createdAt,
    this.revokedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory FeedbackWebhookKey({
    int? id,
    required int teamId,
    required String keyHash,
    required String createdByUserId,
    DateTime? createdAt,
    DateTime? revokedAt,
  }) = _FeedbackWebhookKeyImpl;

  factory FeedbackWebhookKey.fromJson(Map<String, dynamic> jsonSerialization) {
    return FeedbackWebhookKey(
      id: jsonSerialization['id'] as int?,
      teamId: jsonSerialization['teamId'] as int,
      keyHash: jsonSerialization['keyHash'] as String,
      createdByUserId: jsonSerialization['createdByUserId'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
    );
  }

  static final t = FeedbackWebhookKeyTable();

  static const db = FeedbackWebhookKeyRepository._();

  @override
  int? id;

  int teamId;

  String keyHash;

  String createdByUserId;

  DateTime createdAt;

  DateTime? revokedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [FeedbackWebhookKey]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FeedbackWebhookKey copyWith({
    int? id,
    int? teamId,
    String? keyHash,
    String? createdByUserId,
    DateTime? createdAt,
    DateTime? revokedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FeedbackWebhookKey',
      if (id != null) 'id': id,
      'teamId': teamId,
      'keyHash': keyHash,
      'createdByUserId': createdByUserId,
      'createdAt': createdAt.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static FeedbackWebhookKeyInclude include() {
    return FeedbackWebhookKeyInclude._();
  }

  static FeedbackWebhookKeyIncludeList includeList({
    _is.WhereExpressionBuilder<FeedbackWebhookKeyTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FeedbackWebhookKeyTable>? orderBy,
    _is.OrderByListBuilder<FeedbackWebhookKeyTable>? orderByList,
    FeedbackWebhookKeyInclude? include,
  }) {
    return FeedbackWebhookKeyIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FeedbackWebhookKey.t),
      orderByList: orderByList?.call(FeedbackWebhookKey.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FeedbackWebhookKeyImpl extends FeedbackWebhookKey {
  _FeedbackWebhookKeyImpl({
    int? id,
    required int teamId,
    required String keyHash,
    required String createdByUserId,
    DateTime? createdAt,
    DateTime? revokedAt,
  }) : super._(
         id: id,
         teamId: teamId,
         keyHash: keyHash,
         createdByUserId: createdByUserId,
         createdAt: createdAt,
         revokedAt: revokedAt,
       );

  /// Returns a shallow copy of this [FeedbackWebhookKey]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FeedbackWebhookKey copyWith({
    Object? id = _Undefined,
    int? teamId,
    String? keyHash,
    String? createdByUserId,
    DateTime? createdAt,
    Object? revokedAt = _Undefined,
  }) {
    return FeedbackWebhookKey(
      id: id is int? ? id : this.id,
      teamId: teamId ?? this.teamId,
      keyHash: keyHash ?? this.keyHash,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      revokedAt: revokedAt is DateTime? ? revokedAt : this.revokedAt,
    );
  }
}

class FeedbackWebhookKeyUpdateTable
    extends _is.UpdateTable<FeedbackWebhookKeyTable> {
  FeedbackWebhookKeyUpdateTable(super.table);

  _is.ColumnValue<int, int> teamId(int value) => _is.ColumnValue(
    table.teamId,
    value,
  );

  _is.ColumnValue<String, String> keyHash(String value) => _is.ColumnValue(
    table.keyHash,
    value,
  );

  _is.ColumnValue<String, String> createdByUserId(String value) =>
      _is.ColumnValue(
        table.createdByUserId,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> revokedAt(DateTime? value) =>
      _is.ColumnValue(
        table.revokedAt,
        value,
      );
}

class FeedbackWebhookKeyTable extends _is.Table<int?> {
  FeedbackWebhookKeyTable({super.tableRelation})
    : super(tableName: 'feedback_webhook_key') {
    updateTable = FeedbackWebhookKeyUpdateTable(this);
    teamId = _is.ColumnInt(
      'team_id',
      this,
      fieldName: 'teamId',
    );
    keyHash = _is.ColumnString(
      'keyHash',
      this,
    );
    createdByUserId = _is.ColumnString(
      'createdByUserId',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    revokedAt = _is.ColumnDateTime(
      'revokedAt',
      this,
    );
  }

  late final FeedbackWebhookKeyUpdateTable updateTable;

  late final _is.ColumnInt teamId;

  late final _is.ColumnString keyHash;

  late final _is.ColumnString createdByUserId;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime revokedAt;

  @override
  List<_is.Column> get columns => [
    id,
    teamId,
    keyHash,
    createdByUserId,
    createdAt,
    revokedAt,
  ];
}

class FeedbackWebhookKeyInclude extends _is.IncludeObject {
  FeedbackWebhookKeyInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => FeedbackWebhookKey.t;
}

class FeedbackWebhookKeyIncludeList extends _is.IncludeList {
  FeedbackWebhookKeyIncludeList._({
    _is.WhereExpressionBuilder<FeedbackWebhookKeyTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FeedbackWebhookKey.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => FeedbackWebhookKey.t;
}

class FeedbackWebhookKeyRepository {
  const FeedbackWebhookKeyRepository._();

  /// Returns a list of [FeedbackWebhookKey]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<FeedbackWebhookKey>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FeedbackWebhookKeyTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FeedbackWebhookKeyTable>? orderBy,
    _is.OrderByListBuilder<FeedbackWebhookKeyTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<FeedbackWebhookKey>(
      where: where?.call(FeedbackWebhookKey.t),
      orderBy: orderBy?.call(FeedbackWebhookKey.t),
      orderByList: orderByList?.call(FeedbackWebhookKey.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [FeedbackWebhookKey] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<FeedbackWebhookKey?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FeedbackWebhookKeyTable>? where,
    int? offset,
    _is.OrderByBuilder<FeedbackWebhookKeyTable>? orderBy,
    _is.OrderByListBuilder<FeedbackWebhookKeyTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<FeedbackWebhookKey>(
      where: where?.call(FeedbackWebhookKey.t),
      orderBy: orderBy?.call(FeedbackWebhookKey.t),
      orderByList: orderByList?.call(FeedbackWebhookKey.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [FeedbackWebhookKey] by its [id] or null if no such row exists.
  Future<FeedbackWebhookKey?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<FeedbackWebhookKey>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [FeedbackWebhookKey]s in the list and returns the inserted rows.
  ///
  /// The returned [FeedbackWebhookKey]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FeedbackWebhookKey>> insert(
    _is.DatabaseSession session,
    List<FeedbackWebhookKey> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<FeedbackWebhookKey>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [FeedbackWebhookKey] and returns the inserted row.
  ///
  /// The returned [FeedbackWebhookKey] will have its `id` field set.
  Future<FeedbackWebhookKey> insertRow(
    _is.DatabaseSession session,
    FeedbackWebhookKey row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<FeedbackWebhookKey>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [FeedbackWebhookKey]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [FeedbackWebhookKey]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FeedbackWebhookKey>> upsert(
    _is.DatabaseSession session,
    List<FeedbackWebhookKey> rows, {
    required _is.ColumnSelections<FeedbackWebhookKeyTable> conflictColumns,
    _is.ColumnSelections<FeedbackWebhookKeyTable>? updateColumns,
    _is.WhereExpressionBuilder<FeedbackWebhookKeyTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<FeedbackWebhookKey>(
      rows,
      conflictColumns: conflictColumns(FeedbackWebhookKey.t),
      updateColumns: updateColumns?.call(FeedbackWebhookKey.t),
      updateWhere: updateWhere?.call(FeedbackWebhookKey.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [FeedbackWebhookKey] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [FeedbackWebhookKey] will have its `id` field set.
  Future<FeedbackWebhookKey?> upsertRow(
    _is.DatabaseSession session,
    FeedbackWebhookKey row, {
    required _is.ColumnSelections<FeedbackWebhookKeyTable> conflictColumns,
    _is.ColumnSelections<FeedbackWebhookKeyTable>? updateColumns,
    _is.WhereExpressionBuilder<FeedbackWebhookKeyTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<FeedbackWebhookKey>(
      row,
      conflictColumns: conflictColumns(FeedbackWebhookKey.t),
      updateColumns: updateColumns?.call(FeedbackWebhookKey.t),
      updateWhere: updateWhere?.call(FeedbackWebhookKey.t),
      transaction: transaction,
    );
  }

  /// Updates all [FeedbackWebhookKey]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FeedbackWebhookKey>> update(
    _is.DatabaseSession session,
    List<FeedbackWebhookKey> rows, {
    _is.ColumnSelections<FeedbackWebhookKeyTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<FeedbackWebhookKey>(
      rows,
      columns: columns?.call(FeedbackWebhookKey.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [FeedbackWebhookKey]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FeedbackWebhookKey> updateRow(
    _is.DatabaseSession session,
    FeedbackWebhookKey row, {
    _is.ColumnSelections<FeedbackWebhookKeyTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<FeedbackWebhookKey>(
      row,
      columns: columns?.call(FeedbackWebhookKey.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FeedbackWebhookKey] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<FeedbackWebhookKey?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<FeedbackWebhookKeyUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<FeedbackWebhookKey>(
      id,
      columnValues: columnValues(FeedbackWebhookKey.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [FeedbackWebhookKey]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FeedbackWebhookKey>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<FeedbackWebhookKeyUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<FeedbackWebhookKeyTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FeedbackWebhookKeyTable>? orderBy,
    _is.OrderByListBuilder<FeedbackWebhookKeyTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<FeedbackWebhookKey>(
      columnValues: columnValues(FeedbackWebhookKey.t.updateTable),
      where: where(FeedbackWebhookKey.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FeedbackWebhookKey.t),
      orderByList: orderByList?.call(FeedbackWebhookKey.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [FeedbackWebhookKey]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FeedbackWebhookKey>> delete(
    _is.DatabaseSession session,
    List<FeedbackWebhookKey> rows, {
    _is.OrderByBuilder<FeedbackWebhookKeyTable>? orderBy,
    _is.OrderByListBuilder<FeedbackWebhookKeyTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<FeedbackWebhookKey>(
      rows,
      orderBy: orderBy?.call(FeedbackWebhookKey.t),
      orderByList: orderByList?.call(FeedbackWebhookKey.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [FeedbackWebhookKey].
  Future<FeedbackWebhookKey> deleteRow(
    _is.DatabaseSession session,
    FeedbackWebhookKey row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FeedbackWebhookKey>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FeedbackWebhookKey>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FeedbackWebhookKeyTable> where,
    _is.OrderByBuilder<FeedbackWebhookKeyTable>? orderBy,
    _is.OrderByListBuilder<FeedbackWebhookKeyTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<FeedbackWebhookKey>(
      where: where(FeedbackWebhookKey.t),
      orderBy: orderBy?.call(FeedbackWebhookKey.t),
      orderByList: orderByList?.call(FeedbackWebhookKey.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FeedbackWebhookKeyTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<FeedbackWebhookKey>(
      where: where?.call(FeedbackWebhookKey.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [FeedbackWebhookKey] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FeedbackWebhookKeyTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<FeedbackWebhookKey>(
      where: where(FeedbackWebhookKey.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
