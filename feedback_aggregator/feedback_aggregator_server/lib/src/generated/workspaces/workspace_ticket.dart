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

abstract class WorkspaceTicket
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

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
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = WorkspaceTicketTable();

  static const db = WorkspaceTicketRepository._();

  @override
  int? id;

  int workspaceId;

  String title;

  String description;

  String source;

  String status;

  String priority;

  int supporters;

  String requester;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [WorkspaceTicket]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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
      'createdAt': createdAt.toJson(),
    };
  }

  static WorkspaceTicketInclude include() {
    return WorkspaceTicketInclude._();
  }

  static WorkspaceTicketIncludeList includeList({
    _is.WhereExpressionBuilder<WorkspaceTicketTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WorkspaceTicketTable>? orderBy,
    _is.OrderByListBuilder<WorkspaceTicketTable>? orderByList,
    WorkspaceTicketInclude? include,
  }) {
    return WorkspaceTicketIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WorkspaceTicket.t),
      orderByList: orderByList?.call(WorkspaceTicket.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [WorkspaceTicket]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class WorkspaceTicketUpdateTable extends _is.UpdateTable<WorkspaceTicketTable> {
  WorkspaceTicketUpdateTable(super.table);

  _is.ColumnValue<int, int> workspaceId(int value) => _is.ColumnValue(
    table.workspaceId,
    value,
  );

  _is.ColumnValue<String, String> title(String value) => _is.ColumnValue(
    table.title,
    value,
  );

  _is.ColumnValue<String, String> description(String value) => _is.ColumnValue(
    table.description,
    value,
  );

  _is.ColumnValue<String, String> source(String value) => _is.ColumnValue(
    table.source,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> priority(String value) => _is.ColumnValue(
    table.priority,
    value,
  );

  _is.ColumnValue<int, int> supporters(int value) => _is.ColumnValue(
    table.supporters,
    value,
  );

  _is.ColumnValue<String, String> requester(String value) => _is.ColumnValue(
    table.requester,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class WorkspaceTicketTable extends _is.Table<int?> {
  WorkspaceTicketTable({super.tableRelation})
    : super(tableName: 'app_workspace_ticket') {
    updateTable = WorkspaceTicketUpdateTable(this);
    workspaceId = _is.ColumnInt(
      'workspaceId',
      this,
    );
    title = _is.ColumnString(
      'title',
      this,
    );
    description = _is.ColumnString(
      'description',
      this,
    );
    source = _is.ColumnString(
      'source',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    priority = _is.ColumnString(
      'priority',
      this,
    );
    supporters = _is.ColumnInt(
      'supporters',
      this,
    );
    requester = _is.ColumnString(
      'requester',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final WorkspaceTicketUpdateTable updateTable;

  late final _is.ColumnInt workspaceId;

  late final _is.ColumnString title;

  late final _is.ColumnString description;

  late final _is.ColumnString source;

  late final _is.ColumnString status;

  late final _is.ColumnString priority;

  late final _is.ColumnInt supporters;

  late final _is.ColumnString requester;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    workspaceId,
    title,
    description,
    source,
    status,
    priority,
    supporters,
    requester,
    createdAt,
  ];
}

class WorkspaceTicketInclude extends _is.IncludeObject {
  WorkspaceTicketInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => WorkspaceTicket.t;
}

class WorkspaceTicketIncludeList extends _is.IncludeList {
  WorkspaceTicketIncludeList._({
    _is.WhereExpressionBuilder<WorkspaceTicketTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(WorkspaceTicket.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => WorkspaceTicket.t;
}

class WorkspaceTicketRepository {
  const WorkspaceTicketRepository._();

  /// Returns a list of [WorkspaceTicket]s matching the given query parameters.
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
  Future<List<WorkspaceTicket>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WorkspaceTicketTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WorkspaceTicketTable>? orderBy,
    _is.OrderByListBuilder<WorkspaceTicketTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<WorkspaceTicket>(
      where: where?.call(WorkspaceTicket.t),
      orderBy: orderBy?.call(WorkspaceTicket.t),
      orderByList: orderByList?.call(WorkspaceTicket.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [WorkspaceTicket] matching the given query parameters.
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
  Future<WorkspaceTicket?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WorkspaceTicketTable>? where,
    int? offset,
    _is.OrderByBuilder<WorkspaceTicketTable>? orderBy,
    _is.OrderByListBuilder<WorkspaceTicketTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<WorkspaceTicket>(
      where: where?.call(WorkspaceTicket.t),
      orderBy: orderBy?.call(WorkspaceTicket.t),
      orderByList: orderByList?.call(WorkspaceTicket.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [WorkspaceTicket] by its [id] or null if no such row exists.
  Future<WorkspaceTicket?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<WorkspaceTicket>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [WorkspaceTicket]s in the list and returns the inserted rows.
  ///
  /// The returned [WorkspaceTicket]s will have their `id` fields set.
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
  Future<List<WorkspaceTicket>> insert(
    _is.DatabaseSession session,
    List<WorkspaceTicket> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<WorkspaceTicket>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [WorkspaceTicket] and returns the inserted row.
  ///
  /// The returned [WorkspaceTicket] will have its `id` field set.
  Future<WorkspaceTicket> insertRow(
    _is.DatabaseSession session,
    WorkspaceTicket row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<WorkspaceTicket>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [WorkspaceTicket]s in the list and returns the resulting rows.
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
  /// The returned [WorkspaceTicket]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WorkspaceTicket>> upsert(
    _is.DatabaseSession session,
    List<WorkspaceTicket> rows, {
    required _is.ColumnSelections<WorkspaceTicketTable> conflictColumns,
    _is.ColumnSelections<WorkspaceTicketTable>? updateColumns,
    _is.WhereExpressionBuilder<WorkspaceTicketTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<WorkspaceTicket>(
      rows,
      conflictColumns: conflictColumns(WorkspaceTicket.t),
      updateColumns: updateColumns?.call(WorkspaceTicket.t),
      updateWhere: updateWhere?.call(WorkspaceTicket.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [WorkspaceTicket] and returns the resulting row.
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
  /// The returned [WorkspaceTicket] will have its `id` field set.
  Future<WorkspaceTicket?> upsertRow(
    _is.DatabaseSession session,
    WorkspaceTicket row, {
    required _is.ColumnSelections<WorkspaceTicketTable> conflictColumns,
    _is.ColumnSelections<WorkspaceTicketTable>? updateColumns,
    _is.WhereExpressionBuilder<WorkspaceTicketTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<WorkspaceTicket>(
      row,
      conflictColumns: conflictColumns(WorkspaceTicket.t),
      updateColumns: updateColumns?.call(WorkspaceTicket.t),
      updateWhere: updateWhere?.call(WorkspaceTicket.t),
      transaction: transaction,
    );
  }

  /// Updates all [WorkspaceTicket]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WorkspaceTicket>> update(
    _is.DatabaseSession session,
    List<WorkspaceTicket> rows, {
    _is.ColumnSelections<WorkspaceTicketTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<WorkspaceTicket>(
      rows,
      columns: columns?.call(WorkspaceTicket.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [WorkspaceTicket]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<WorkspaceTicket> updateRow(
    _is.DatabaseSession session,
    WorkspaceTicket row, {
    _is.ColumnSelections<WorkspaceTicketTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<WorkspaceTicket>(
      row,
      columns: columns?.call(WorkspaceTicket.t),
      transaction: transaction,
    );
  }

  /// Updates a single [WorkspaceTicket] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<WorkspaceTicket?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<WorkspaceTicketUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<WorkspaceTicket>(
      id,
      columnValues: columnValues(WorkspaceTicket.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [WorkspaceTicket]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WorkspaceTicket>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<WorkspaceTicketUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<WorkspaceTicketTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WorkspaceTicketTable>? orderBy,
    _is.OrderByListBuilder<WorkspaceTicketTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<WorkspaceTicket>(
      columnValues: columnValues(WorkspaceTicket.t.updateTable),
      where: where(WorkspaceTicket.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WorkspaceTicket.t),
      orderByList: orderByList?.call(WorkspaceTicket.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [WorkspaceTicket]s in the list and returns the deleted rows.
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
  Future<List<WorkspaceTicket>> delete(
    _is.DatabaseSession session,
    List<WorkspaceTicket> rows, {
    _is.OrderByBuilder<WorkspaceTicketTable>? orderBy,
    _is.OrderByListBuilder<WorkspaceTicketTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<WorkspaceTicket>(
      rows,
      orderBy: orderBy?.call(WorkspaceTicket.t),
      orderByList: orderByList?.call(WorkspaceTicket.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [WorkspaceTicket].
  Future<WorkspaceTicket> deleteRow(
    _is.DatabaseSession session,
    WorkspaceTicket row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<WorkspaceTicket>(
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
  Future<List<WorkspaceTicket>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WorkspaceTicketTable> where,
    _is.OrderByBuilder<WorkspaceTicketTable>? orderBy,
    _is.OrderByListBuilder<WorkspaceTicketTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<WorkspaceTicket>(
      where: where(WorkspaceTicket.t),
      orderBy: orderBy?.call(WorkspaceTicket.t),
      orderByList: orderByList?.call(WorkspaceTicket.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WorkspaceTicketTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<WorkspaceTicket>(
      where: where?.call(WorkspaceTicket.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [WorkspaceTicket] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WorkspaceTicketTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<WorkspaceTicket>(
      where: where(WorkspaceTicket.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
