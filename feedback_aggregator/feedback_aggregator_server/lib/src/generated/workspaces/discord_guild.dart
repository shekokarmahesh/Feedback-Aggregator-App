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

abstract class DiscordGuild
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  DiscordGuild._({
    this.id,
    required this.workspaceId,
    required this.guildId,
  });

  factory DiscordGuild({
    int? id,
    required int workspaceId,
    required String guildId,
  }) = _DiscordGuildImpl;

  factory DiscordGuild.fromJson(Map<String, dynamic> jsonSerialization) {
    return DiscordGuild(
      id: jsonSerialization['id'] as int?,
      workspaceId: jsonSerialization['workspaceId'] as int,
      guildId: jsonSerialization['guildId'] as String,
    );
  }

  static final t = DiscordGuildTable();

  static const db = DiscordGuildRepository._();

  @override
  int? id;

  int workspaceId;

  String guildId;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [DiscordGuild]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DiscordGuild copyWith({
    int? id,
    int? workspaceId,
    String? guildId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DiscordGuild',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'guildId': guildId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static DiscordGuildInclude include() {
    return DiscordGuildInclude._();
  }

  static DiscordGuildIncludeList includeList({
    _is.WhereExpressionBuilder<DiscordGuildTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DiscordGuildTable>? orderBy,
    _is.OrderByListBuilder<DiscordGuildTable>? orderByList,
    DiscordGuildInclude? include,
  }) {
    return DiscordGuildIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DiscordGuild.t),
      orderByList: orderByList?.call(DiscordGuild.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DiscordGuildImpl extends DiscordGuild {
  _DiscordGuildImpl({
    int? id,
    required int workspaceId,
    required String guildId,
  }) : super._(
         id: id,
         workspaceId: workspaceId,
         guildId: guildId,
       );

  /// Returns a shallow copy of this [DiscordGuild]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DiscordGuild copyWith({
    Object? id = _Undefined,
    int? workspaceId,
    String? guildId,
  }) {
    return DiscordGuild(
      id: id is int? ? id : this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      guildId: guildId ?? this.guildId,
    );
  }
}

class DiscordGuildUpdateTable extends _is.UpdateTable<DiscordGuildTable> {
  DiscordGuildUpdateTable(super.table);

  _is.ColumnValue<int, int> workspaceId(int value) => _is.ColumnValue(
    table.workspaceId,
    value,
  );

  _is.ColumnValue<String, String> guildId(String value) => _is.ColumnValue(
    table.guildId,
    value,
  );
}

class DiscordGuildTable extends _is.Table<int?> {
  DiscordGuildTable({super.tableRelation})
    : super(tableName: 'app_discord_guild') {
    updateTable = DiscordGuildUpdateTable(this);
    workspaceId = _is.ColumnInt(
      'workspaceId',
      this,
    );
    guildId = _is.ColumnString(
      'guildId',
      this,
    );
  }

  late final DiscordGuildUpdateTable updateTable;

  late final _is.ColumnInt workspaceId;

  late final _is.ColumnString guildId;

  @override
  List<_is.Column> get columns => [
    id,
    workspaceId,
    guildId,
  ];
}

class DiscordGuildInclude extends _is.IncludeObject {
  DiscordGuildInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => DiscordGuild.t;
}

class DiscordGuildIncludeList extends _is.IncludeList {
  DiscordGuildIncludeList._({
    _is.WhereExpressionBuilder<DiscordGuildTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DiscordGuild.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => DiscordGuild.t;
}

class DiscordGuildRepository {
  const DiscordGuildRepository._();

  /// Returns a list of [DiscordGuild]s matching the given query parameters.
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
  Future<List<DiscordGuild>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DiscordGuildTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DiscordGuildTable>? orderBy,
    _is.OrderByListBuilder<DiscordGuildTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DiscordGuild>(
      where: where?.call(DiscordGuild.t),
      orderBy: orderBy?.call(DiscordGuild.t),
      orderByList: orderByList?.call(DiscordGuild.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [DiscordGuild] matching the given query parameters.
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
  Future<DiscordGuild?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DiscordGuildTable>? where,
    int? offset,
    _is.OrderByBuilder<DiscordGuildTable>? orderBy,
    _is.OrderByListBuilder<DiscordGuildTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DiscordGuild>(
      where: where?.call(DiscordGuild.t),
      orderBy: orderBy?.call(DiscordGuild.t),
      orderByList: orderByList?.call(DiscordGuild.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DiscordGuild] by its [id] or null if no such row exists.
  Future<DiscordGuild?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DiscordGuild>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DiscordGuild]s in the list and returns the inserted rows.
  ///
  /// The returned [DiscordGuild]s will have their `id` fields set.
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
  Future<List<DiscordGuild>> insert(
    _is.DatabaseSession session,
    List<DiscordGuild> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DiscordGuild>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DiscordGuild] and returns the inserted row.
  ///
  /// The returned [DiscordGuild] will have its `id` field set.
  Future<DiscordGuild> insertRow(
    _is.DatabaseSession session,
    DiscordGuild row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DiscordGuild>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DiscordGuild]s in the list and returns the resulting rows.
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
  /// The returned [DiscordGuild]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DiscordGuild>> upsert(
    _is.DatabaseSession session,
    List<DiscordGuild> rows, {
    required _is.ColumnSelections<DiscordGuildTable> conflictColumns,
    _is.ColumnSelections<DiscordGuildTable>? updateColumns,
    _is.WhereExpressionBuilder<DiscordGuildTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DiscordGuild>(
      rows,
      conflictColumns: conflictColumns(DiscordGuild.t),
      updateColumns: updateColumns?.call(DiscordGuild.t),
      updateWhere: updateWhere?.call(DiscordGuild.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DiscordGuild] and returns the resulting row.
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
  /// The returned [DiscordGuild] will have its `id` field set.
  Future<DiscordGuild?> upsertRow(
    _is.DatabaseSession session,
    DiscordGuild row, {
    required _is.ColumnSelections<DiscordGuildTable> conflictColumns,
    _is.ColumnSelections<DiscordGuildTable>? updateColumns,
    _is.WhereExpressionBuilder<DiscordGuildTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DiscordGuild>(
      row,
      conflictColumns: conflictColumns(DiscordGuild.t),
      updateColumns: updateColumns?.call(DiscordGuild.t),
      updateWhere: updateWhere?.call(DiscordGuild.t),
      transaction: transaction,
    );
  }

  /// Updates all [DiscordGuild]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DiscordGuild>> update(
    _is.DatabaseSession session,
    List<DiscordGuild> rows, {
    _is.ColumnSelections<DiscordGuildTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DiscordGuild>(
      rows,
      columns: columns?.call(DiscordGuild.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DiscordGuild]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DiscordGuild> updateRow(
    _is.DatabaseSession session,
    DiscordGuild row, {
    _is.ColumnSelections<DiscordGuildTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DiscordGuild>(
      row,
      columns: columns?.call(DiscordGuild.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DiscordGuild] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DiscordGuild?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<DiscordGuildUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DiscordGuild>(
      id,
      columnValues: columnValues(DiscordGuild.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DiscordGuild]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DiscordGuild>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DiscordGuildUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<DiscordGuildTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DiscordGuildTable>? orderBy,
    _is.OrderByListBuilder<DiscordGuildTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DiscordGuild>(
      columnValues: columnValues(DiscordGuild.t.updateTable),
      where: where(DiscordGuild.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DiscordGuild.t),
      orderByList: orderByList?.call(DiscordGuild.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DiscordGuild]s in the list and returns the deleted rows.
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
  Future<List<DiscordGuild>> delete(
    _is.DatabaseSession session,
    List<DiscordGuild> rows, {
    _is.OrderByBuilder<DiscordGuildTable>? orderBy,
    _is.OrderByListBuilder<DiscordGuildTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DiscordGuild>(
      rows,
      orderBy: orderBy?.call(DiscordGuild.t),
      orderByList: orderByList?.call(DiscordGuild.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DiscordGuild].
  Future<DiscordGuild> deleteRow(
    _is.DatabaseSession session,
    DiscordGuild row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DiscordGuild>(
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
  Future<List<DiscordGuild>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DiscordGuildTable> where,
    _is.OrderByBuilder<DiscordGuildTable>? orderBy,
    _is.OrderByListBuilder<DiscordGuildTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DiscordGuild>(
      where: where(DiscordGuild.t),
      orderBy: orderBy?.call(DiscordGuild.t),
      orderByList: orderByList?.call(DiscordGuild.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DiscordGuildTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DiscordGuild>(
      where: where?.call(DiscordGuild.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DiscordGuild] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DiscordGuildTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DiscordGuild>(
      where: where(DiscordGuild.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
