/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:feedback_aggregator_server/src/generated/protocol.dart'
    as _iwl9u20j;
import 'package:serverpod/serverpod.dart' as _is;
import '../workspaces/workspace.dart' as _iokdbqiz;
import '../workspaces/workspace_role.dart' as _ibbf7qu4;

abstract class WorkspaceInvitation
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  WorkspaceInvitation._({
    this.id,
    required this.workspaceId,
    this.workspace,
    required this.email,
    required this.role,
    required this.tokenHash,
    required this.createdBy,
    DateTime? createdAt,
    required this.expiresAt,
    this.acceptedAt,
    this.revokedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory WorkspaceInvitation({
    int? id,
    required int workspaceId,
    _iokdbqiz.Workspace? workspace,
    required String email,
    required _ibbf7qu4.WorkspaceRole role,
    required String tokenHash,
    required _is.UuidValue createdBy,
    DateTime? createdAt,
    required DateTime expiresAt,
    DateTime? acceptedAt,
    DateTime? revokedAt,
  }) = _WorkspaceInvitationImpl;

  factory WorkspaceInvitation.fromJson(Map<String, dynamic> jsonSerialization) {
    return WorkspaceInvitation(
      id: jsonSerialization['id'] as int?,
      workspaceId: jsonSerialization['workspaceId'] as int,
      workspace: jsonSerialization['workspace'] == null
          ? null
          : _iwl9u20j.Protocol().deserialize<_iokdbqiz.Workspace>(
              jsonSerialization['workspace'],
            ),
      email: jsonSerialization['email'] as String,
      role: _ibbf7qu4.WorkspaceRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      tokenHash: jsonSerialization['tokenHash'] as String,
      createdBy: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['createdBy'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      acceptedAt: jsonSerialization['acceptedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['acceptedAt']),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
    );
  }

  static final t = WorkspaceInvitationTable();

  static const db = WorkspaceInvitationRepository._();

  @override
  int? id;

  int workspaceId;

  _iokdbqiz.Workspace? workspace;

  String email;

  _ibbf7qu4.WorkspaceRole role;

  String tokenHash;

  _is.UuidValue createdBy;

  DateTime createdAt;

  DateTime expiresAt;

  DateTime? acceptedAt;

  DateTime? revokedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [WorkspaceInvitation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  WorkspaceInvitation copyWith({
    int? id,
    int? workspaceId,
    _iokdbqiz.Workspace? workspace,
    String? email,
    _ibbf7qu4.WorkspaceRole? role,
    String? tokenHash,
    _is.UuidValue? createdBy,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? acceptedAt,
    DateTime? revokedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WorkspaceInvitation',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      if (workspace != null) 'workspace': workspace?.toJson(),
      'email': email,
      'role': role.toJson(),
      'tokenHash': tokenHash,
      'createdBy': createdBy.toJson(),
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (acceptedAt != null) 'acceptedAt': acceptedAt?.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static WorkspaceInvitationInclude include({
    _iokdbqiz.WorkspaceInclude? workspace,
  }) {
    return WorkspaceInvitationInclude._(workspace: workspace);
  }

  static WorkspaceInvitationIncludeList includeList({
    _is.WhereExpressionBuilder<WorkspaceInvitationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WorkspaceInvitationTable>? orderBy,
    _is.OrderByListBuilder<WorkspaceInvitationTable>? orderByList,
    WorkspaceInvitationInclude? include,
  }) {
    return WorkspaceInvitationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WorkspaceInvitation.t),
      orderByList: orderByList?.call(WorkspaceInvitation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WorkspaceInvitationImpl extends WorkspaceInvitation {
  _WorkspaceInvitationImpl({
    int? id,
    required int workspaceId,
    _iokdbqiz.Workspace? workspace,
    required String email,
    required _ibbf7qu4.WorkspaceRole role,
    required String tokenHash,
    required _is.UuidValue createdBy,
    DateTime? createdAt,
    required DateTime expiresAt,
    DateTime? acceptedAt,
    DateTime? revokedAt,
  }) : super._(
         id: id,
         workspaceId: workspaceId,
         workspace: workspace,
         email: email,
         role: role,
         tokenHash: tokenHash,
         createdBy: createdBy,
         createdAt: createdAt,
         expiresAt: expiresAt,
         acceptedAt: acceptedAt,
         revokedAt: revokedAt,
       );

  /// Returns a shallow copy of this [WorkspaceInvitation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  WorkspaceInvitation copyWith({
    Object? id = _Undefined,
    int? workspaceId,
    Object? workspace = _Undefined,
    String? email,
    _ibbf7qu4.WorkspaceRole? role,
    String? tokenHash,
    _is.UuidValue? createdBy,
    DateTime? createdAt,
    DateTime? expiresAt,
    Object? acceptedAt = _Undefined,
    Object? revokedAt = _Undefined,
  }) {
    return WorkspaceInvitation(
      id: id is int? ? id : this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      workspace: workspace is _iokdbqiz.Workspace?
          ? workspace
          : this.workspace?.copyWith(),
      email: email ?? this.email,
      role: role ?? this.role,
      tokenHash: tokenHash ?? this.tokenHash,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      acceptedAt: acceptedAt is DateTime? ? acceptedAt : this.acceptedAt,
      revokedAt: revokedAt is DateTime? ? revokedAt : this.revokedAt,
    );
  }
}

class WorkspaceInvitationUpdateTable
    extends _is.UpdateTable<WorkspaceInvitationTable> {
  WorkspaceInvitationUpdateTable(super.table);

  _is.ColumnValue<int, int> workspaceId(int value) => _is.ColumnValue(
    table.workspaceId,
    value,
  );

  _is.ColumnValue<String, String> email(String value) => _is.ColumnValue(
    table.email,
    value,
  );

  _is.ColumnValue<_ibbf7qu4.WorkspaceRole, _ibbf7qu4.WorkspaceRole> role(
    _ibbf7qu4.WorkspaceRole value,
  ) => _is.ColumnValue(
    table.role,
    value,
  );

  _is.ColumnValue<String, String> tokenHash(String value) => _is.ColumnValue(
    table.tokenHash,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> createdBy(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.createdBy,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> acceptedAt(DateTime? value) =>
      _is.ColumnValue(
        table.acceptedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> revokedAt(DateTime? value) =>
      _is.ColumnValue(
        table.revokedAt,
        value,
      );
}

class WorkspaceInvitationTable extends _is.Table<int?> {
  WorkspaceInvitationTable({super.tableRelation})
    : super(tableName: 'app_workspace_invitation') {
    updateTable = WorkspaceInvitationUpdateTable(this);
    workspaceId = _is.ColumnInt(
      'workspaceId',
      this,
    );
    email = _is.ColumnString(
      'email',
      this,
    );
    role = _is.ColumnEnum(
      'role',
      this,
      _is.EnumSerialization.byName,
    );
    tokenHash = _is.ColumnString(
      'tokenHash',
      this,
    );
    createdBy = _is.ColumnUuid(
      'createdBy',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
    acceptedAt = _is.ColumnDateTime(
      'acceptedAt',
      this,
    );
    revokedAt = _is.ColumnDateTime(
      'revokedAt',
      this,
    );
  }

  late final WorkspaceInvitationUpdateTable updateTable;

  late final _is.ColumnInt workspaceId;

  _iokdbqiz.WorkspaceTable? _workspace;

  late final _is.ColumnString email;

  late final _is.ColumnEnum<_ibbf7qu4.WorkspaceRole> role;

  late final _is.ColumnString tokenHash;

  late final _is.ColumnUuid createdBy;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnDateTime acceptedAt;

  late final _is.ColumnDateTime revokedAt;

  _iokdbqiz.WorkspaceTable get workspace {
    if (_workspace != null) return _workspace!;
    _workspace = _is.createRelationTable(
      relationFieldName: 'workspace',
      field: WorkspaceInvitation.t.workspaceId,
      foreignField: _iokdbqiz.Workspace.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iokdbqiz.WorkspaceTable(tableRelation: foreignTableRelation),
    );
    return _workspace!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    workspaceId,
    email,
    role,
    tokenHash,
    createdBy,
    createdAt,
    expiresAt,
    acceptedAt,
    revokedAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'workspace') {
      return workspace;
    }
    return null;
  }
}

class WorkspaceInvitationInclude extends _is.IncludeObject {
  WorkspaceInvitationInclude._({_iokdbqiz.WorkspaceInclude? workspace}) {
    _workspace = workspace;
  }

  _iokdbqiz.WorkspaceInclude? _workspace;

  @override
  Map<String, _is.Include?> get includes => {'workspace': _workspace};

  @override
  _is.Table<int?> get table => WorkspaceInvitation.t;
}

class WorkspaceInvitationIncludeList extends _is.IncludeList {
  WorkspaceInvitationIncludeList._({
    _is.WhereExpressionBuilder<WorkspaceInvitationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(WorkspaceInvitation.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => WorkspaceInvitation.t;
}

class WorkspaceInvitationRepository {
  const WorkspaceInvitationRepository._();

  final attachRow = const WorkspaceInvitationAttachRowRepository._();

  /// Returns a list of [WorkspaceInvitation]s matching the given query parameters.
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
  Future<List<WorkspaceInvitation>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WorkspaceInvitationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WorkspaceInvitationTable>? orderBy,
    _is.OrderByListBuilder<WorkspaceInvitationTable>? orderByList,
    _is.Transaction? transaction,
    WorkspaceInvitationInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<WorkspaceInvitation>(
      where: where?.call(WorkspaceInvitation.t),
      orderBy: orderBy?.call(WorkspaceInvitation.t),
      orderByList: orderByList?.call(WorkspaceInvitation.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [WorkspaceInvitation] matching the given query parameters.
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
  Future<WorkspaceInvitation?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WorkspaceInvitationTable>? where,
    int? offset,
    _is.OrderByBuilder<WorkspaceInvitationTable>? orderBy,
    _is.OrderByListBuilder<WorkspaceInvitationTable>? orderByList,
    _is.Transaction? transaction,
    WorkspaceInvitationInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<WorkspaceInvitation>(
      where: where?.call(WorkspaceInvitation.t),
      orderBy: orderBy?.call(WorkspaceInvitation.t),
      orderByList: orderByList?.call(WorkspaceInvitation.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [WorkspaceInvitation] by its [id] or null if no such row exists.
  Future<WorkspaceInvitation?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    WorkspaceInvitationInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<WorkspaceInvitation>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [WorkspaceInvitation]s in the list and returns the inserted rows.
  ///
  /// The returned [WorkspaceInvitation]s will have their `id` fields set.
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
  Future<List<WorkspaceInvitation>> insert(
    _is.DatabaseSession session,
    List<WorkspaceInvitation> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<WorkspaceInvitation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [WorkspaceInvitation] and returns the inserted row.
  ///
  /// The returned [WorkspaceInvitation] will have its `id` field set.
  Future<WorkspaceInvitation> insertRow(
    _is.DatabaseSession session,
    WorkspaceInvitation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<WorkspaceInvitation>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [WorkspaceInvitation]s in the list and returns the resulting rows.
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
  /// The returned [WorkspaceInvitation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WorkspaceInvitation>> upsert(
    _is.DatabaseSession session,
    List<WorkspaceInvitation> rows, {
    required _is.ColumnSelections<WorkspaceInvitationTable> conflictColumns,
    _is.ColumnSelections<WorkspaceInvitationTable>? updateColumns,
    _is.WhereExpressionBuilder<WorkspaceInvitationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<WorkspaceInvitation>(
      rows,
      conflictColumns: conflictColumns(WorkspaceInvitation.t),
      updateColumns: updateColumns?.call(WorkspaceInvitation.t),
      updateWhere: updateWhere?.call(WorkspaceInvitation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [WorkspaceInvitation] and returns the resulting row.
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
  /// The returned [WorkspaceInvitation] will have its `id` field set.
  Future<WorkspaceInvitation?> upsertRow(
    _is.DatabaseSession session,
    WorkspaceInvitation row, {
    required _is.ColumnSelections<WorkspaceInvitationTable> conflictColumns,
    _is.ColumnSelections<WorkspaceInvitationTable>? updateColumns,
    _is.WhereExpressionBuilder<WorkspaceInvitationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<WorkspaceInvitation>(
      row,
      conflictColumns: conflictColumns(WorkspaceInvitation.t),
      updateColumns: updateColumns?.call(WorkspaceInvitation.t),
      updateWhere: updateWhere?.call(WorkspaceInvitation.t),
      transaction: transaction,
    );
  }

  /// Updates all [WorkspaceInvitation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WorkspaceInvitation>> update(
    _is.DatabaseSession session,
    List<WorkspaceInvitation> rows, {
    _is.ColumnSelections<WorkspaceInvitationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<WorkspaceInvitation>(
      rows,
      columns: columns?.call(WorkspaceInvitation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [WorkspaceInvitation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<WorkspaceInvitation> updateRow(
    _is.DatabaseSession session,
    WorkspaceInvitation row, {
    _is.ColumnSelections<WorkspaceInvitationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<WorkspaceInvitation>(
      row,
      columns: columns?.call(WorkspaceInvitation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [WorkspaceInvitation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<WorkspaceInvitation?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<WorkspaceInvitationUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<WorkspaceInvitation>(
      id,
      columnValues: columnValues(WorkspaceInvitation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [WorkspaceInvitation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WorkspaceInvitation>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<WorkspaceInvitationUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<WorkspaceInvitationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WorkspaceInvitationTable>? orderBy,
    _is.OrderByListBuilder<WorkspaceInvitationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<WorkspaceInvitation>(
      columnValues: columnValues(WorkspaceInvitation.t.updateTable),
      where: where(WorkspaceInvitation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WorkspaceInvitation.t),
      orderByList: orderByList?.call(WorkspaceInvitation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [WorkspaceInvitation]s in the list and returns the deleted rows.
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
  Future<List<WorkspaceInvitation>> delete(
    _is.DatabaseSession session,
    List<WorkspaceInvitation> rows, {
    _is.OrderByBuilder<WorkspaceInvitationTable>? orderBy,
    _is.OrderByListBuilder<WorkspaceInvitationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<WorkspaceInvitation>(
      rows,
      orderBy: orderBy?.call(WorkspaceInvitation.t),
      orderByList: orderByList?.call(WorkspaceInvitation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [WorkspaceInvitation].
  Future<WorkspaceInvitation> deleteRow(
    _is.DatabaseSession session,
    WorkspaceInvitation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<WorkspaceInvitation>(
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
  Future<List<WorkspaceInvitation>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WorkspaceInvitationTable> where,
    _is.OrderByBuilder<WorkspaceInvitationTable>? orderBy,
    _is.OrderByListBuilder<WorkspaceInvitationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<WorkspaceInvitation>(
      where: where(WorkspaceInvitation.t),
      orderBy: orderBy?.call(WorkspaceInvitation.t),
      orderByList: orderByList?.call(WorkspaceInvitation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WorkspaceInvitationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<WorkspaceInvitation>(
      where: where?.call(WorkspaceInvitation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [WorkspaceInvitation] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WorkspaceInvitationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<WorkspaceInvitation>(
      where: where(WorkspaceInvitation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class WorkspaceInvitationAttachRowRepository {
  const WorkspaceInvitationAttachRowRepository._();

  /// Creates a relation between the given [WorkspaceInvitation] and [Workspace]
  /// by setting the [WorkspaceInvitation]'s foreign key `workspaceId` to refer to the [Workspace].
  Future<void> workspace(
    _is.DatabaseSession session,
    WorkspaceInvitation workspaceInvitation,
    _iokdbqiz.Workspace workspace, {
    _is.Transaction? transaction,
  }) async {
    if (workspaceInvitation.id == null) {
      throw ArgumentError.notNull('workspaceInvitation.id');
    }
    if (workspace.id == null) {
      throw ArgumentError.notNull('workspace.id');
    }

    var $workspaceInvitation = workspaceInvitation.copyWith(
      workspaceId: workspace.id,
    );
    await session.db.updateRow<WorkspaceInvitation>(
      $workspaceInvitation,
      columns: [WorkspaceInvitation.t.workspaceId],
      transaction: transaction,
    );
  }
}
