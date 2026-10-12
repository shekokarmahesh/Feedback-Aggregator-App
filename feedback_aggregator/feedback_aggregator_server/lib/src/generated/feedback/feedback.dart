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

/// Feedback received from a user through a source channel.
abstract class Feedback
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = FeedbackTable();

  static const db = FeedbackRepository._();

  @override
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

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Feedback]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static FeedbackInclude include() {
    return FeedbackInclude._();
  }

  static FeedbackIncludeList includeList({
    _is.WhereExpressionBuilder<FeedbackTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FeedbackTable>? orderBy,
    _is.OrderByListBuilder<FeedbackTable>? orderByList,
    FeedbackInclude? include,
  }) {
    return FeedbackIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Feedback.t),
      orderByList: orderByList?.call(Feedback.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class FeedbackUpdateTable extends _is.UpdateTable<FeedbackTable> {
  FeedbackUpdateTable(super.table);

  _is.ColumnValue<int, int> teamId(int value) => _is.ColumnValue(
    table.teamId,
    value,
  );

  _is.ColumnValue<String, String> title(String value) => _is.ColumnValue(
    table.title,
    value,
  );

  _is.ColumnValue<String, String> body(String value) => _is.ColumnValue(
    table.body,
    value,
  );

  _is.ColumnValue<String, String> source(String value) => _is.ColumnValue(
    table.source,
    value,
  );

  _is.ColumnValue<String, String> userEmail(String value) => _is.ColumnValue(
    table.userEmail,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class FeedbackTable extends _is.Table<int?> {
  FeedbackTable({super.tableRelation}) : super(tableName: 'feedback') {
    updateTable = FeedbackUpdateTable(this);
    teamId = _is.ColumnInt(
      'team_id',
      this,
      fieldName: 'teamId',
    );
    title = _is.ColumnString(
      'title',
      this,
    );
    body = _is.ColumnString(
      'body',
      this,
    );
    source = _is.ColumnString(
      'source',
      this,
    );
    userEmail = _is.ColumnString(
      'userEmail',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final FeedbackUpdateTable updateTable;

  /// Workspace determined by the authenticated ingestion key, never by payload.
  late final _is.ColumnInt teamId;

  /// Short summary of the feedback.
  late final _is.ColumnString title;

  /// Full feedback text.
  late final _is.ColumnString body;

  /// Originating channel, such as email, Slack, forms, or support.
  late final _is.ColumnString source;

  /// Submitter's email address; does not prove ownership or grant access.
  late final _is.ColumnString userEmail;

  /// Time the feedback was recorded, in UTC.
  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    teamId,
    title,
    body,
    source,
    userEmail,
    createdAt,
  ];
}

class FeedbackInclude extends _is.IncludeObject {
  FeedbackInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Feedback.t;
}

class FeedbackIncludeList extends _is.IncludeList {
  FeedbackIncludeList._({
    _is.WhereExpressionBuilder<FeedbackTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Feedback.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Feedback.t;
}

class FeedbackRepository {
  const FeedbackRepository._();

  /// Returns a list of [Feedback]s matching the given query parameters.
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
  Future<List<Feedback>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FeedbackTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FeedbackTable>? orderBy,
    _is.OrderByListBuilder<FeedbackTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Feedback>(
      where: where?.call(Feedback.t),
      orderBy: orderBy?.call(Feedback.t),
      orderByList: orderByList?.call(Feedback.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Feedback] matching the given query parameters.
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
  Future<Feedback?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FeedbackTable>? where,
    int? offset,
    _is.OrderByBuilder<FeedbackTable>? orderBy,
    _is.OrderByListBuilder<FeedbackTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Feedback>(
      where: where?.call(Feedback.t),
      orderBy: orderBy?.call(Feedback.t),
      orderByList: orderByList?.call(Feedback.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Feedback] by its [id] or null if no such row exists.
  Future<Feedback?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Feedback>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Feedback]s in the list and returns the inserted rows.
  ///
  /// The returned [Feedback]s will have their `id` fields set.
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
  Future<List<Feedback>> insert(
    _is.DatabaseSession session,
    List<Feedback> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Feedback>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Feedback] and returns the inserted row.
  ///
  /// The returned [Feedback] will have its `id` field set.
  Future<Feedback> insertRow(
    _is.DatabaseSession session,
    Feedback row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Feedback>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Feedback]s in the list and returns the resulting rows.
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
  /// The returned [Feedback]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Feedback>> upsert(
    _is.DatabaseSession session,
    List<Feedback> rows, {
    required _is.ColumnSelections<FeedbackTable> conflictColumns,
    _is.ColumnSelections<FeedbackTable>? updateColumns,
    _is.WhereExpressionBuilder<FeedbackTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Feedback>(
      rows,
      conflictColumns: conflictColumns(Feedback.t),
      updateColumns: updateColumns?.call(Feedback.t),
      updateWhere: updateWhere?.call(Feedback.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Feedback] and returns the resulting row.
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
  /// The returned [Feedback] will have its `id` field set.
  Future<Feedback?> upsertRow(
    _is.DatabaseSession session,
    Feedback row, {
    required _is.ColumnSelections<FeedbackTable> conflictColumns,
    _is.ColumnSelections<FeedbackTable>? updateColumns,
    _is.WhereExpressionBuilder<FeedbackTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Feedback>(
      row,
      conflictColumns: conflictColumns(Feedback.t),
      updateColumns: updateColumns?.call(Feedback.t),
      updateWhere: updateWhere?.call(Feedback.t),
      transaction: transaction,
    );
  }

  /// Updates all [Feedback]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Feedback>> update(
    _is.DatabaseSession session,
    List<Feedback> rows, {
    _is.ColumnSelections<FeedbackTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Feedback>(
      rows,
      columns: columns?.call(Feedback.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Feedback]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Feedback> updateRow(
    _is.DatabaseSession session,
    Feedback row, {
    _is.ColumnSelections<FeedbackTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Feedback>(
      row,
      columns: columns?.call(Feedback.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Feedback] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Feedback?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<FeedbackUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Feedback>(
      id,
      columnValues: columnValues(Feedback.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Feedback]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Feedback>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<FeedbackUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<FeedbackTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FeedbackTable>? orderBy,
    _is.OrderByListBuilder<FeedbackTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Feedback>(
      columnValues: columnValues(Feedback.t.updateTable),
      where: where(Feedback.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Feedback.t),
      orderByList: orderByList?.call(Feedback.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Feedback]s in the list and returns the deleted rows.
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
  Future<List<Feedback>> delete(
    _is.DatabaseSession session,
    List<Feedback> rows, {
    _is.OrderByBuilder<FeedbackTable>? orderBy,
    _is.OrderByListBuilder<FeedbackTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Feedback>(
      rows,
      orderBy: orderBy?.call(Feedback.t),
      orderByList: orderByList?.call(Feedback.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Feedback].
  Future<Feedback> deleteRow(
    _is.DatabaseSession session,
    Feedback row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Feedback>(
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
  Future<List<Feedback>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FeedbackTable> where,
    _is.OrderByBuilder<FeedbackTable>? orderBy,
    _is.OrderByListBuilder<FeedbackTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Feedback>(
      where: where(Feedback.t),
      orderBy: orderBy?.call(Feedback.t),
      orderByList: orderByList?.call(Feedback.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FeedbackTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Feedback>(
      where: where?.call(Feedback.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Feedback] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FeedbackTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Feedback>(
      where: where(Feedback.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
