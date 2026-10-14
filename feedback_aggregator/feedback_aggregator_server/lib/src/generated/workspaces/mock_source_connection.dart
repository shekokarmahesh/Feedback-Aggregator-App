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

abstract class MockSourceConnection
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
          : _is.BoolJsonExtension.fromJson(jsonSerialization['connected']),
      connectedAt: jsonSerialization['connectedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['connectedAt'],
            ),
      lastSyncedAt: jsonSerialization['lastSyncedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSyncedAt'],
            ),
      syncedCount: jsonSerialization['syncedCount'] as int?,
      availableCount: jsonSerialization['availableCount'] as int?,
    );
  }

  static final t = MockSourceConnectionTable();

  static const db = MockSourceConnectionRepository._();

  @override
  int? id;

  int workspaceId;

  String source;

  bool connected;

  DateTime? connectedAt;

  DateTime? lastSyncedAt;

  int syncedCount;

  int availableCount;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [MockSourceConnection]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static MockSourceConnectionInclude include() {
    return MockSourceConnectionInclude._();
  }

  static MockSourceConnectionIncludeList includeList({
    _is.WhereExpressionBuilder<MockSourceConnectionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MockSourceConnectionTable>? orderBy,
    _is.OrderByListBuilder<MockSourceConnectionTable>? orderByList,
    MockSourceConnectionInclude? include,
  }) {
    return MockSourceConnectionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MockSourceConnection.t),
      orderByList: orderByList?.call(MockSourceConnection.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class MockSourceConnectionUpdateTable
    extends _is.UpdateTable<MockSourceConnectionTable> {
  MockSourceConnectionUpdateTable(super.table);

  _is.ColumnValue<int, int> workspaceId(int value) => _is.ColumnValue(
    table.workspaceId,
    value,
  );

  _is.ColumnValue<String, String> source(String value) => _is.ColumnValue(
    table.source,
    value,
  );

  _is.ColumnValue<bool, bool> connected(bool value) => _is.ColumnValue(
    table.connected,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> connectedAt(DateTime? value) =>
      _is.ColumnValue(
        table.connectedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> lastSyncedAt(DateTime? value) =>
      _is.ColumnValue(
        table.lastSyncedAt,
        value,
      );

  _is.ColumnValue<int, int> syncedCount(int value) => _is.ColumnValue(
    table.syncedCount,
    value,
  );

  _is.ColumnValue<int, int> availableCount(int value) => _is.ColumnValue(
    table.availableCount,
    value,
  );
}

class MockSourceConnectionTable extends _is.Table<int?> {
  MockSourceConnectionTable({super.tableRelation})
    : super(tableName: 'app_mock_source_connection') {
    updateTable = MockSourceConnectionUpdateTable(this);
    workspaceId = _is.ColumnInt(
      'workspaceId',
      this,
    );
    source = _is.ColumnString(
      'source',
      this,
    );
    connected = _is.ColumnBool(
      'connected',
      this,
      hasDefault: true,
    );
    connectedAt = _is.ColumnDateTime(
      'connectedAt',
      this,
    );
    lastSyncedAt = _is.ColumnDateTime(
      'lastSyncedAt',
      this,
    );
    syncedCount = _is.ColumnInt(
      'syncedCount',
      this,
      hasDefault: true,
    );
    availableCount = _is.ColumnInt(
      'availableCount',
      this,
      hasDefault: true,
    );
  }

  late final MockSourceConnectionUpdateTable updateTable;

  late final _is.ColumnInt workspaceId;

  late final _is.ColumnString source;

  late final _is.ColumnBool connected;

  late final _is.ColumnDateTime connectedAt;

  late final _is.ColumnDateTime lastSyncedAt;

  late final _is.ColumnInt syncedCount;

  late final _is.ColumnInt availableCount;

  @override
  List<_is.Column> get columns => [
    id,
    workspaceId,
    source,
    connected,
    connectedAt,
    lastSyncedAt,
    syncedCount,
    availableCount,
  ];
}

class MockSourceConnectionInclude extends _is.IncludeObject {
  MockSourceConnectionInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => MockSourceConnection.t;
}

class MockSourceConnectionIncludeList extends _is.IncludeList {
  MockSourceConnectionIncludeList._({
    _is.WhereExpressionBuilder<MockSourceConnectionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MockSourceConnection.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => MockSourceConnection.t;
}

class MockSourceConnectionRepository {
  const MockSourceConnectionRepository._();

  /// Returns a list of [MockSourceConnection]s matching the given query parameters.
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
  Future<List<MockSourceConnection>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MockSourceConnectionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MockSourceConnectionTable>? orderBy,
    _is.OrderByListBuilder<MockSourceConnectionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MockSourceConnection>(
      where: where?.call(MockSourceConnection.t),
      orderBy: orderBy?.call(MockSourceConnection.t),
      orderByList: orderByList?.call(MockSourceConnection.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MockSourceConnection] matching the given query parameters.
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
  Future<MockSourceConnection?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MockSourceConnectionTable>? where,
    int? offset,
    _is.OrderByBuilder<MockSourceConnectionTable>? orderBy,
    _is.OrderByListBuilder<MockSourceConnectionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MockSourceConnection>(
      where: where?.call(MockSourceConnection.t),
      orderBy: orderBy?.call(MockSourceConnection.t),
      orderByList: orderByList?.call(MockSourceConnection.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MockSourceConnection] by its [id] or null if no such row exists.
  Future<MockSourceConnection?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MockSourceConnection>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MockSourceConnection]s in the list and returns the inserted rows.
  ///
  /// The returned [MockSourceConnection]s will have their `id` fields set.
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
  Future<List<MockSourceConnection>> insert(
    _is.DatabaseSession session,
    List<MockSourceConnection> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<MockSourceConnection>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [MockSourceConnection] and returns the inserted row.
  ///
  /// The returned [MockSourceConnection] will have its `id` field set.
  Future<MockSourceConnection> insertRow(
    _is.DatabaseSession session,
    MockSourceConnection row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<MockSourceConnection>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [MockSourceConnection]s in the list and returns the resulting rows.
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
  /// The returned [MockSourceConnection]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MockSourceConnection>> upsert(
    _is.DatabaseSession session,
    List<MockSourceConnection> rows, {
    required _is.ColumnSelections<MockSourceConnectionTable> conflictColumns,
    _is.ColumnSelections<MockSourceConnectionTable>? updateColumns,
    _is.WhereExpressionBuilder<MockSourceConnectionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<MockSourceConnection>(
      rows,
      conflictColumns: conflictColumns(MockSourceConnection.t),
      updateColumns: updateColumns?.call(MockSourceConnection.t),
      updateWhere: updateWhere?.call(MockSourceConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [MockSourceConnection] and returns the resulting row.
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
  /// The returned [MockSourceConnection] will have its `id` field set.
  Future<MockSourceConnection?> upsertRow(
    _is.DatabaseSession session,
    MockSourceConnection row, {
    required _is.ColumnSelections<MockSourceConnectionTable> conflictColumns,
    _is.ColumnSelections<MockSourceConnectionTable>? updateColumns,
    _is.WhereExpressionBuilder<MockSourceConnectionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<MockSourceConnection>(
      row,
      conflictColumns: conflictColumns(MockSourceConnection.t),
      updateColumns: updateColumns?.call(MockSourceConnection.t),
      updateWhere: updateWhere?.call(MockSourceConnection.t),
      transaction: transaction,
    );
  }

  /// Updates all [MockSourceConnection]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MockSourceConnection>> update(
    _is.DatabaseSession session,
    List<MockSourceConnection> rows, {
    _is.ColumnSelections<MockSourceConnectionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<MockSourceConnection>(
      rows,
      columns: columns?.call(MockSourceConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [MockSourceConnection]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MockSourceConnection> updateRow(
    _is.DatabaseSession session,
    MockSourceConnection row, {
    _is.ColumnSelections<MockSourceConnectionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<MockSourceConnection>(
      row,
      columns: columns?.call(MockSourceConnection.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MockSourceConnection] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MockSourceConnection?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<MockSourceConnectionUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<MockSourceConnection>(
      id,
      columnValues: columnValues(MockSourceConnection.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MockSourceConnection]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MockSourceConnection>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<MockSourceConnectionUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<MockSourceConnectionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MockSourceConnectionTable>? orderBy,
    _is.OrderByListBuilder<MockSourceConnectionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<MockSourceConnection>(
      columnValues: columnValues(MockSourceConnection.t.updateTable),
      where: where(MockSourceConnection.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MockSourceConnection.t),
      orderByList: orderByList?.call(MockSourceConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [MockSourceConnection]s in the list and returns the deleted rows.
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
  Future<List<MockSourceConnection>> delete(
    _is.DatabaseSession session,
    List<MockSourceConnection> rows, {
    _is.OrderByBuilder<MockSourceConnectionTable>? orderBy,
    _is.OrderByListBuilder<MockSourceConnectionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<MockSourceConnection>(
      rows,
      orderBy: orderBy?.call(MockSourceConnection.t),
      orderByList: orderByList?.call(MockSourceConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [MockSourceConnection].
  Future<MockSourceConnection> deleteRow(
    _is.DatabaseSession session,
    MockSourceConnection row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MockSourceConnection>(
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
  Future<List<MockSourceConnection>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MockSourceConnectionTable> where,
    _is.OrderByBuilder<MockSourceConnectionTable>? orderBy,
    _is.OrderByListBuilder<MockSourceConnectionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<MockSourceConnection>(
      where: where(MockSourceConnection.t),
      orderBy: orderBy?.call(MockSourceConnection.t),
      orderByList: orderByList?.call(MockSourceConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MockSourceConnectionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<MockSourceConnection>(
      where: where?.call(MockSourceConnection.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MockSourceConnection] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MockSourceConnectionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MockSourceConnection>(
      where: where(MockSourceConnection.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
