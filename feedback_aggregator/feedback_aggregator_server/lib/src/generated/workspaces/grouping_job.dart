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

abstract class GroupingJob
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  GroupingJob._({
    this.id,
    required this.workspaceId,
    required this.requestedBy,
    String? status,
    this.scheduledAt,
    this.leaseToken,
    this.leaseUntil,
    this.retryAt,
    int? failures,
    this.lastError,
  }) : status = status ?? 'idle',
       failures = failures ?? 0;

  factory GroupingJob({
    int? id,
    required int workspaceId,
    required _is.UuidValue requestedBy,
    String? status,
    DateTime? scheduledAt,
    String? leaseToken,
    DateTime? leaseUntil,
    DateTime? retryAt,
    int? failures,
    String? lastError,
  }) = _GroupingJobImpl;

  factory GroupingJob.fromJson(Map<String, dynamic> jsonSerialization) {
    return GroupingJob(
      id: jsonSerialization['id'] as int?,
      workspaceId: jsonSerialization['workspaceId'] as int,
      requestedBy: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['requestedBy'],
      ),
      status: jsonSerialization['status'] as String?,
      scheduledAt: jsonSerialization['scheduledAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['scheduledAt'],
            ),
      leaseToken: jsonSerialization['leaseToken'] as String?,
      leaseUntil: jsonSerialization['leaseUntil'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['leaseUntil']),
      retryAt: jsonSerialization['retryAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['retryAt']),
      failures: jsonSerialization['failures'] as int?,
      lastError: jsonSerialization['lastError'] as String?,
    );
  }

  static final t = GroupingJobTable();

  static const db = GroupingJobRepository._();

  @override
  int? id;

  int workspaceId;

  _is.UuidValue requestedBy;

  String status;

  DateTime? scheduledAt;

  String? leaseToken;

  DateTime? leaseUntil;

  DateTime? retryAt;

  int failures;

  String? lastError;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [GroupingJob]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  GroupingJob copyWith({
    int? id,
    int? workspaceId,
    _is.UuidValue? requestedBy,
    String? status,
    DateTime? scheduledAt,
    String? leaseToken,
    DateTime? leaseUntil,
    DateTime? retryAt,
    int? failures,
    String? lastError,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GroupingJob',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'requestedBy': requestedBy.toJson(),
      'status': status,
      if (scheduledAt != null) 'scheduledAt': scheduledAt?.toJson(),
      if (leaseToken != null) 'leaseToken': leaseToken,
      if (leaseUntil != null) 'leaseUntil': leaseUntil?.toJson(),
      if (retryAt != null) 'retryAt': retryAt?.toJson(),
      'failures': failures,
      if (lastError != null) 'lastError': lastError,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static GroupingJobInclude include() {
    return GroupingJobInclude._();
  }

  static GroupingJobIncludeList includeList({
    _is.WhereExpressionBuilder<GroupingJobTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GroupingJobTable>? orderBy,
    _is.OrderByListBuilder<GroupingJobTable>? orderByList,
    GroupingJobInclude? include,
  }) {
    return GroupingJobIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupingJob.t),
      orderByList: orderByList?.call(GroupingJob.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GroupingJobImpl extends GroupingJob {
  _GroupingJobImpl({
    int? id,
    required int workspaceId,
    required _is.UuidValue requestedBy,
    String? status,
    DateTime? scheduledAt,
    String? leaseToken,
    DateTime? leaseUntil,
    DateTime? retryAt,
    int? failures,
    String? lastError,
  }) : super._(
         id: id,
         workspaceId: workspaceId,
         requestedBy: requestedBy,
         status: status,
         scheduledAt: scheduledAt,
         leaseToken: leaseToken,
         leaseUntil: leaseUntil,
         retryAt: retryAt,
         failures: failures,
         lastError: lastError,
       );

  /// Returns a shallow copy of this [GroupingJob]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  GroupingJob copyWith({
    Object? id = _Undefined,
    int? workspaceId,
    _is.UuidValue? requestedBy,
    String? status,
    Object? scheduledAt = _Undefined,
    Object? leaseToken = _Undefined,
    Object? leaseUntil = _Undefined,
    Object? retryAt = _Undefined,
    int? failures,
    Object? lastError = _Undefined,
  }) {
    return GroupingJob(
      id: id is int? ? id : this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      requestedBy: requestedBy ?? this.requestedBy,
      status: status ?? this.status,
      scheduledAt: scheduledAt is DateTime? ? scheduledAt : this.scheduledAt,
      leaseToken: leaseToken is String? ? leaseToken : this.leaseToken,
      leaseUntil: leaseUntil is DateTime? ? leaseUntil : this.leaseUntil,
      retryAt: retryAt is DateTime? ? retryAt : this.retryAt,
      failures: failures ?? this.failures,
      lastError: lastError is String? ? lastError : this.lastError,
    );
  }
}

class GroupingJobUpdateTable extends _is.UpdateTable<GroupingJobTable> {
  GroupingJobUpdateTable(super.table);

  _is.ColumnValue<int, int> workspaceId(int value) => _is.ColumnValue(
    table.workspaceId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> requestedBy(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.requestedBy,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> scheduledAt(DateTime? value) =>
      _is.ColumnValue(
        table.scheduledAt,
        value,
      );

  _is.ColumnValue<String, String> leaseToken(String? value) => _is.ColumnValue(
    table.leaseToken,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> leaseUntil(DateTime? value) =>
      _is.ColumnValue(
        table.leaseUntil,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> retryAt(DateTime? value) =>
      _is.ColumnValue(
        table.retryAt,
        value,
      );

  _is.ColumnValue<int, int> failures(int value) => _is.ColumnValue(
    table.failures,
    value,
  );

  _is.ColumnValue<String, String> lastError(String? value) => _is.ColumnValue(
    table.lastError,
    value,
  );
}

class GroupingJobTable extends _is.Table<int?> {
  GroupingJobTable({super.tableRelation})
    : super(tableName: 'app_grouping_job') {
    updateTable = GroupingJobUpdateTable(this);
    workspaceId = _is.ColumnInt(
      'workspaceId',
      this,
    );
    requestedBy = _is.ColumnUuid(
      'requestedBy',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
      hasDefault: true,
    );
    scheduledAt = _is.ColumnDateTime(
      'scheduledAt',
      this,
    );
    leaseToken = _is.ColumnString(
      'leaseToken',
      this,
    );
    leaseUntil = _is.ColumnDateTime(
      'leaseUntil',
      this,
    );
    retryAt = _is.ColumnDateTime(
      'retryAt',
      this,
    );
    failures = _is.ColumnInt(
      'failures',
      this,
      hasDefault: true,
    );
    lastError = _is.ColumnString(
      'lastError',
      this,
    );
  }

  late final GroupingJobUpdateTable updateTable;

  late final _is.ColumnInt workspaceId;

  late final _is.ColumnUuid requestedBy;

  late final _is.ColumnString status;

  late final _is.ColumnDateTime scheduledAt;

  late final _is.ColumnString leaseToken;

  late final _is.ColumnDateTime leaseUntil;

  late final _is.ColumnDateTime retryAt;

  late final _is.ColumnInt failures;

  late final _is.ColumnString lastError;

  @override
  List<_is.Column> get columns => [
    id,
    workspaceId,
    requestedBy,
    status,
    scheduledAt,
    leaseToken,
    leaseUntil,
    retryAt,
    failures,
    lastError,
  ];
}

class GroupingJobInclude extends _is.IncludeObject {
  GroupingJobInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => GroupingJob.t;
}

class GroupingJobIncludeList extends _is.IncludeList {
  GroupingJobIncludeList._({
    _is.WhereExpressionBuilder<GroupingJobTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(GroupingJob.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => GroupingJob.t;
}

class GroupingJobRepository {
  const GroupingJobRepository._();

  /// Returns a list of [GroupingJob]s matching the given query parameters.
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
  Future<List<GroupingJob>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GroupingJobTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GroupingJobTable>? orderBy,
    _is.OrderByListBuilder<GroupingJobTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<GroupingJob>(
      where: where?.call(GroupingJob.t),
      orderBy: orderBy?.call(GroupingJob.t),
      orderByList: orderByList?.call(GroupingJob.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [GroupingJob] matching the given query parameters.
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
  Future<GroupingJob?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GroupingJobTable>? where,
    int? offset,
    _is.OrderByBuilder<GroupingJobTable>? orderBy,
    _is.OrderByListBuilder<GroupingJobTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<GroupingJob>(
      where: where?.call(GroupingJob.t),
      orderBy: orderBy?.call(GroupingJob.t),
      orderByList: orderByList?.call(GroupingJob.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [GroupingJob] by its [id] or null if no such row exists.
  Future<GroupingJob?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<GroupingJob>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [GroupingJob]s in the list and returns the inserted rows.
  ///
  /// The returned [GroupingJob]s will have their `id` fields set.
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
  Future<List<GroupingJob>> insert(
    _is.DatabaseSession session,
    List<GroupingJob> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<GroupingJob>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [GroupingJob] and returns the inserted row.
  ///
  /// The returned [GroupingJob] will have its `id` field set.
  Future<GroupingJob> insertRow(
    _is.DatabaseSession session,
    GroupingJob row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<GroupingJob>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [GroupingJob]s in the list and returns the resulting rows.
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
  /// The returned [GroupingJob]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupingJob>> upsert(
    _is.DatabaseSession session,
    List<GroupingJob> rows, {
    required _is.ColumnSelections<GroupingJobTable> conflictColumns,
    _is.ColumnSelections<GroupingJobTable>? updateColumns,
    _is.WhereExpressionBuilder<GroupingJobTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<GroupingJob>(
      rows,
      conflictColumns: conflictColumns(GroupingJob.t),
      updateColumns: updateColumns?.call(GroupingJob.t),
      updateWhere: updateWhere?.call(GroupingJob.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [GroupingJob] and returns the resulting row.
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
  /// The returned [GroupingJob] will have its `id` field set.
  Future<GroupingJob?> upsertRow(
    _is.DatabaseSession session,
    GroupingJob row, {
    required _is.ColumnSelections<GroupingJobTable> conflictColumns,
    _is.ColumnSelections<GroupingJobTable>? updateColumns,
    _is.WhereExpressionBuilder<GroupingJobTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<GroupingJob>(
      row,
      conflictColumns: conflictColumns(GroupingJob.t),
      updateColumns: updateColumns?.call(GroupingJob.t),
      updateWhere: updateWhere?.call(GroupingJob.t),
      transaction: transaction,
    );
  }

  /// Updates all [GroupingJob]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupingJob>> update(
    _is.DatabaseSession session,
    List<GroupingJob> rows, {
    _is.ColumnSelections<GroupingJobTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<GroupingJob>(
      rows,
      columns: columns?.call(GroupingJob.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [GroupingJob]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<GroupingJob> updateRow(
    _is.DatabaseSession session,
    GroupingJob row, {
    _is.ColumnSelections<GroupingJobTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<GroupingJob>(
      row,
      columns: columns?.call(GroupingJob.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GroupingJob] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<GroupingJob?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<GroupingJobUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<GroupingJob>(
      id,
      columnValues: columnValues(GroupingJob.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [GroupingJob]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupingJob>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<GroupingJobUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<GroupingJobTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GroupingJobTable>? orderBy,
    _is.OrderByListBuilder<GroupingJobTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<GroupingJob>(
      columnValues: columnValues(GroupingJob.t.updateTable),
      where: where(GroupingJob.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupingJob.t),
      orderByList: orderByList?.call(GroupingJob.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [GroupingJob]s in the list and returns the deleted rows.
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
  Future<List<GroupingJob>> delete(
    _is.DatabaseSession session,
    List<GroupingJob> rows, {
    _is.OrderByBuilder<GroupingJobTable>? orderBy,
    _is.OrderByListBuilder<GroupingJobTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<GroupingJob>(
      rows,
      orderBy: orderBy?.call(GroupingJob.t),
      orderByList: orderByList?.call(GroupingJob.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [GroupingJob].
  Future<GroupingJob> deleteRow(
    _is.DatabaseSession session,
    GroupingJob row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<GroupingJob>(
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
  Future<List<GroupingJob>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GroupingJobTable> where,
    _is.OrderByBuilder<GroupingJobTable>? orderBy,
    _is.OrderByListBuilder<GroupingJobTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<GroupingJob>(
      where: where(GroupingJob.t),
      orderBy: orderBy?.call(GroupingJob.t),
      orderByList: orderByList?.call(GroupingJob.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GroupingJobTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<GroupingJob>(
      where: where?.call(GroupingJob.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [GroupingJob] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GroupingJobTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<GroupingJob>(
      where: where(GroupingJob.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
