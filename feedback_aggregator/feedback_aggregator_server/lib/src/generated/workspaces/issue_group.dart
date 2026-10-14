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

abstract class IssueGroup
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  IssueGroup._({
    this.id,
    required this.workspaceId,
    required this.status,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory IssueGroup({
    int? id,
    required int workspaceId,
    required String status,
    DateTime? createdAt,
  }) = _IssueGroupImpl;

  factory IssueGroup.fromJson(Map<String, dynamic> jsonSerialization) {
    return IssueGroup(
      id: jsonSerialization['id'] as int?,
      workspaceId: jsonSerialization['workspaceId'] as int,
      status: jsonSerialization['status'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = IssueGroupTable();

  static const db = IssueGroupRepository._();

  @override
  int? id;

  int workspaceId;

  String status;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [IssueGroup]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  IssueGroup copyWith({
    int? id,
    int? workspaceId,
    String? status,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IssueGroup',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'status': status,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static IssueGroupInclude include() {
    return IssueGroupInclude._();
  }

  static IssueGroupIncludeList includeList({
    _is.WhereExpressionBuilder<IssueGroupTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IssueGroupTable>? orderBy,
    _is.OrderByListBuilder<IssueGroupTable>? orderByList,
    IssueGroupInclude? include,
  }) {
    return IssueGroupIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(IssueGroup.t),
      orderByList: orderByList?.call(IssueGroup.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IssueGroupImpl extends IssueGroup {
  _IssueGroupImpl({
    int? id,
    required int workspaceId,
    required String status,
    DateTime? createdAt,
  }) : super._(
         id: id,
         workspaceId: workspaceId,
         status: status,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [IssueGroup]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  IssueGroup copyWith({
    Object? id = _Undefined,
    int? workspaceId,
    String? status,
    DateTime? createdAt,
  }) {
    return IssueGroup(
      id: id is int? ? id : this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class IssueGroupUpdateTable extends _is.UpdateTable<IssueGroupTable> {
  IssueGroupUpdateTable(super.table);

  _is.ColumnValue<int, int> workspaceId(int value) => _is.ColumnValue(
    table.workspaceId,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class IssueGroupTable extends _is.Table<int?> {
  IssueGroupTable({super.tableRelation}) : super(tableName: 'app_issue_group') {
    updateTable = IssueGroupUpdateTable(this);
    workspaceId = _is.ColumnInt(
      'workspaceId',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final IssueGroupUpdateTable updateTable;

  late final _is.ColumnInt workspaceId;

  late final _is.ColumnString status;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    workspaceId,
    status,
    createdAt,
  ];
}

class IssueGroupInclude extends _is.IncludeObject {
  IssueGroupInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => IssueGroup.t;
}

class IssueGroupIncludeList extends _is.IncludeList {
  IssueGroupIncludeList._({
    _is.WhereExpressionBuilder<IssueGroupTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(IssueGroup.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => IssueGroup.t;
}

class IssueGroupRepository {
  const IssueGroupRepository._();

  /// Returns a list of [IssueGroup]s matching the given query parameters.
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
  Future<List<IssueGroup>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IssueGroupTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IssueGroupTable>? orderBy,
    _is.OrderByListBuilder<IssueGroupTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<IssueGroup>(
      where: where?.call(IssueGroup.t),
      orderBy: orderBy?.call(IssueGroup.t),
      orderByList: orderByList?.call(IssueGroup.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [IssueGroup] matching the given query parameters.
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
  Future<IssueGroup?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IssueGroupTable>? where,
    int? offset,
    _is.OrderByBuilder<IssueGroupTable>? orderBy,
    _is.OrderByListBuilder<IssueGroupTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<IssueGroup>(
      where: where?.call(IssueGroup.t),
      orderBy: orderBy?.call(IssueGroup.t),
      orderByList: orderByList?.call(IssueGroup.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [IssueGroup] by its [id] or null if no such row exists.
  Future<IssueGroup?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<IssueGroup>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [IssueGroup]s in the list and returns the inserted rows.
  ///
  /// The returned [IssueGroup]s will have their `id` fields set.
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
  Future<List<IssueGroup>> insert(
    _is.DatabaseSession session,
    List<IssueGroup> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<IssueGroup>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [IssueGroup] and returns the inserted row.
  ///
  /// The returned [IssueGroup] will have its `id` field set.
  Future<IssueGroup> insertRow(
    _is.DatabaseSession session,
    IssueGroup row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<IssueGroup>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [IssueGroup]s in the list and returns the resulting rows.
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
  /// The returned [IssueGroup]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<IssueGroup>> upsert(
    _is.DatabaseSession session,
    List<IssueGroup> rows, {
    required _is.ColumnSelections<IssueGroupTable> conflictColumns,
    _is.ColumnSelections<IssueGroupTable>? updateColumns,
    _is.WhereExpressionBuilder<IssueGroupTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<IssueGroup>(
      rows,
      conflictColumns: conflictColumns(IssueGroup.t),
      updateColumns: updateColumns?.call(IssueGroup.t),
      updateWhere: updateWhere?.call(IssueGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [IssueGroup] and returns the resulting row.
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
  /// The returned [IssueGroup] will have its `id` field set.
  Future<IssueGroup?> upsertRow(
    _is.DatabaseSession session,
    IssueGroup row, {
    required _is.ColumnSelections<IssueGroupTable> conflictColumns,
    _is.ColumnSelections<IssueGroupTable>? updateColumns,
    _is.WhereExpressionBuilder<IssueGroupTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<IssueGroup>(
      row,
      conflictColumns: conflictColumns(IssueGroup.t),
      updateColumns: updateColumns?.call(IssueGroup.t),
      updateWhere: updateWhere?.call(IssueGroup.t),
      transaction: transaction,
    );
  }

  /// Updates all [IssueGroup]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<IssueGroup>> update(
    _is.DatabaseSession session,
    List<IssueGroup> rows, {
    _is.ColumnSelections<IssueGroupTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<IssueGroup>(
      rows,
      columns: columns?.call(IssueGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [IssueGroup]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<IssueGroup> updateRow(
    _is.DatabaseSession session,
    IssueGroup row, {
    _is.ColumnSelections<IssueGroupTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<IssueGroup>(
      row,
      columns: columns?.call(IssueGroup.t),
      transaction: transaction,
    );
  }

  /// Updates a single [IssueGroup] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<IssueGroup?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<IssueGroupUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<IssueGroup>(
      id,
      columnValues: columnValues(IssueGroup.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [IssueGroup]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<IssueGroup>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<IssueGroupUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<IssueGroupTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IssueGroupTable>? orderBy,
    _is.OrderByListBuilder<IssueGroupTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<IssueGroup>(
      columnValues: columnValues(IssueGroup.t.updateTable),
      where: where(IssueGroup.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(IssueGroup.t),
      orderByList: orderByList?.call(IssueGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [IssueGroup]s in the list and returns the deleted rows.
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
  Future<List<IssueGroup>> delete(
    _is.DatabaseSession session,
    List<IssueGroup> rows, {
    _is.OrderByBuilder<IssueGroupTable>? orderBy,
    _is.OrderByListBuilder<IssueGroupTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<IssueGroup>(
      rows,
      orderBy: orderBy?.call(IssueGroup.t),
      orderByList: orderByList?.call(IssueGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [IssueGroup].
  Future<IssueGroup> deleteRow(
    _is.DatabaseSession session,
    IssueGroup row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<IssueGroup>(
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
  Future<List<IssueGroup>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<IssueGroupTable> where,
    _is.OrderByBuilder<IssueGroupTable>? orderBy,
    _is.OrderByListBuilder<IssueGroupTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<IssueGroup>(
      where: where(IssueGroup.t),
      orderBy: orderBy?.call(IssueGroup.t),
      orderByList: orderByList?.call(IssueGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IssueGroupTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<IssueGroup>(
      where: where?.call(IssueGroup.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [IssueGroup] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<IssueGroupTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<IssueGroup>(
      where: where(IssueGroup.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
