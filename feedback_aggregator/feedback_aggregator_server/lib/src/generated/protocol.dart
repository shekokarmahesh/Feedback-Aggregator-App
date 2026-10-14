/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:feedback_aggregator_server/src/generated/workspaces/grouped_ticket.dart'
    as _ifvqah9b;
import 'package:feedback_aggregator_server/src/generated/workspaces/invitation_info.dart'
    as _in9kijmm;
import 'package:feedback_aggregator_server/src/generated/workspaces/member_info.dart'
    as _innlq9pp;
import 'package:feedback_aggregator_server/src/generated/workspaces/mock_source_connection.dart'
    as _iig9z06a;
import 'package:feedback_aggregator_server/src/generated/workspaces/workspace_summary.dart'
    as _i9st2zmz;
import 'package:feedback_aggregator_server/src/generated/workspaces/workspace_ticket.dart'
    as _i7phqsbk;
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'auth/auth_flow_exception.dart' as _iffl96zw;
import 'feedback/feedback.dart' as _i810ioat;
import 'feedback/feedback_webhook_key.dart' as _iyk5pcfx;
import 'feedback/team.dart' as _ixmckfyn;
import 'future_calls_generated_models/grouping_future_call_process_model.dart'
    as _imd26z8h;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'workspaces/discord_guild.dart' as _i0swa0s1;
import 'workspaces/grouped_ticket.dart' as _ichzz8bw;
import 'workspaces/grouping_job.dart' as _ir0iqr2v;
import 'workspaces/invitation_delivery.dart' as _i5p49uup;
import 'workspaces/invitation_info.dart' as _iquvyw6s;
import 'workspaces/issue_group.dart' as _irth3bb9;
import 'workspaces/member_info.dart' as _itiylzhc;
import 'workspaces/mock_source_connection.dart' as _i8sxq4gq;
import 'workspaces/source_sync_result.dart' as _ixag6zju;
import 'workspaces/workspace.dart' as _ipnno8uy;
import 'workspaces/workspace_exception.dart' as _ih5av2eo;
import 'workspaces/workspace_invitation.dart' as _i66b2tam;
import 'workspaces/workspace_member.dart' as _ihlvzd2h;
import 'workspaces/workspace_role.dart' as _i6w1n5dc;
import 'workspaces/workspace_summary.dart' as _i0zqiur8;
import 'workspaces/workspace_ticket.dart' as _ir8cxu8v;
export 'auth/auth_flow_exception.dart';
export 'feedback/feedback.dart';
export 'feedback/feedback_webhook_key.dart';
export 'feedback/team.dart';
export 'greetings/greeting.dart';
export 'workspaces/discord_guild.dart';
export 'workspaces/grouped_ticket.dart';
export 'workspaces/grouping_job.dart';
export 'workspaces/invitation_delivery.dart';
export 'workspaces/invitation_info.dart';
export 'workspaces/issue_group.dart';
export 'workspaces/member_info.dart';
export 'workspaces/mock_source_connection.dart';
export 'workspaces/source_sync_result.dart';
export 'workspaces/workspace.dart';
export 'workspaces/workspace_exception.dart';
export 'workspaces/workspace_invitation.dart';
export 'workspaces/workspace_member.dart';
export 'workspaces/workspace_role.dart';
export 'workspaces/workspace_summary.dart';
export 'workspaces/workspace_ticket.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'app_discord_guild',
      dartName: 'DiscordGuild',
      schema: 'public',
      module: 'feedback_aggregator',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'workspaceId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'guildId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'app_discord_guild_fk_0',
          columns: ['workspaceId'],
          referenceTable: 'app_workspace',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'discord_guild_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'guildId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'discord_workspace_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'workspaceId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'app_grouping_job',
      dartName: 'GroupingJob',
      schema: 'public',
      module: 'feedback_aggregator',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'workspaceId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'requestedBy',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'idle\'',
        ),
        _isp.ColumnDefinition(
          name: 'scheduledAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'leaseToken',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'leaseUntil',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'retryAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'failures',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'lastError',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'app_grouping_job_fk_0',
          columns: ['workspaceId'],
          referenceTable: 'app_workspace',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'grouping_job_workspace',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'workspaceId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'app_issue_group',
      dartName: 'IssueGroup',
      schema: 'public',
      module: 'feedback_aggregator',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'workspaceId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'app_issue_group_fk_0',
          columns: ['workspaceId'],
          referenceTable: 'app_workspace',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'issue_group_workspace',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'workspaceId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'app_mock_source_connection',
      dartName: 'MockSourceConnection',
      schema: 'public',
      module: 'feedback_aggregator',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'workspaceId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'source',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'connected',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'connectedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'lastSyncedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'syncedCount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'availableCount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'app_mock_source_connection_fk_0',
          columns: ['workspaceId'],
          referenceTable: 'app_workspace',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'mock_source_workspace_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'workspaceId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'source',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'app_workspace',
      dartName: 'Workspace',
      schema: 'public',
      module: 'feedback_aggregator',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'app_workspace_invitation',
      dartName: 'WorkspaceInvitation',
      schema: 'public',
      module: 'feedback_aggregator',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'workspaceId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'email',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'role',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:WorkspaceRole',
        ),
        _isp.ColumnDefinition(
          name: 'tokenHash',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdBy',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'acceptedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'revokedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'app_workspace_invitation_fk_0',
          columns: ['workspaceId'],
          referenceTable: 'app_workspace',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'workspace_invite_token_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'tokenHash',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'workspace_invites_lookup',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'workspaceId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'app_workspace_member',
      dartName: 'WorkspaceMember',
      schema: 'public',
      module: 'feedback_aggregator',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'workspaceId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'email',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'role',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:WorkspaceRole',
        ),
        _isp.ColumnDefinition(
          name: 'joinedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'app_workspace_member_fk_0',
          columns: ['workspaceId'],
          referenceTable: 'app_workspace',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'workspace_user_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'workspaceId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'workspace_user_lookup',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'app_workspace_ticket',
      dartName: 'WorkspaceTicket',
      schema: 'public',
      module: 'feedback_aggregator',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'workspaceId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'title',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'description',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'source',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'priority',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'supporters',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'requester',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'isMock',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'externalId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'issueGroupId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'groupingState',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'pending\'',
        ),
        _isp.ColumnDefinition(
          name: 'groupingConfidence',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'severity',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'app_workspace_ticket_fk_0',
          columns: ['workspaceId'],
          referenceTable: 'app_workspace',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'app_workspace_ticket_fk_1',
          columns: ['issueGroupId'],
          referenceTable: 'app_issue_group',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'workspace_ticket_lookup',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'workspaceId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'workspace_ticket_grouping',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'workspaceId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'issueGroupId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'workspace_ticket_external_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'workspaceId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'source',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'externalId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'feedback',
      dartName: 'Feedback',
      schema: 'public',
      module: 'feedback_aggregator',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'team_id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'title',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'body',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'source',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'userEmail',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'feedback_fk_0',
          columns: ['team_id'],
          referenceTable: 'feedback_team',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'feedback_team_created_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'team_id',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'feedback_team',
      dartName: 'Team',
      schema: 'public',
      module: 'feedback_aggregator',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'ownerUserId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'feedback_team_owner_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'ownerUserId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'feedback_webhook_key',
      dartName: 'FeedbackWebhookKey',
      schema: 'public',
      module: 'feedback_aggregator',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'team_id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'keyHash',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdByUserId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'revokedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'feedback_webhook_key_fk_0',
          columns: ['team_id'],
          referenceTable: 'feedback_team',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'feedback_webhook_key_hash_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'keyHash',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'feedback_webhook_key_team_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'team_id',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iais.Protocol.targetTableDefinitions,
    ..._iacs.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _iffl96zw.AuthFlowException) {
      return _iffl96zw.AuthFlowException.fromJson(data) as T;
    }
    if (t == _i810ioat.Feedback) {
      return _i810ioat.Feedback.fromJson(data) as T;
    }
    if (t == _iyk5pcfx.FeedbackWebhookKey) {
      return _iyk5pcfx.FeedbackWebhookKey.fromJson(data) as T;
    }
    if (t == _ixmckfyn.Team) {
      return _ixmckfyn.Team.fromJson(data) as T;
    }
    if (t == _imd26z8h.GroupingFutureCallProcessModel) {
      return _imd26z8h.GroupingFutureCallProcessModel.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _i0swa0s1.DiscordGuild) {
      return _i0swa0s1.DiscordGuild.fromJson(data) as T;
    }
    if (t == _ichzz8bw.GroupedTicket) {
      return _ichzz8bw.GroupedTicket.fromJson(data) as T;
    }
    if (t == _ir0iqr2v.GroupingJob) {
      return _ir0iqr2v.GroupingJob.fromJson(data) as T;
    }
    if (t == _i5p49uup.InvitationDelivery) {
      return _i5p49uup.InvitationDelivery.fromJson(data) as T;
    }
    if (t == _iquvyw6s.InvitationInfo) {
      return _iquvyw6s.InvitationInfo.fromJson(data) as T;
    }
    if (t == _irth3bb9.IssueGroup) {
      return _irth3bb9.IssueGroup.fromJson(data) as T;
    }
    if (t == _itiylzhc.MemberInfo) {
      return _itiylzhc.MemberInfo.fromJson(data) as T;
    }
    if (t == _i8sxq4gq.MockSourceConnection) {
      return _i8sxq4gq.MockSourceConnection.fromJson(data) as T;
    }
    if (t == _ixag6zju.SourceSyncResult) {
      return _ixag6zju.SourceSyncResult.fromJson(data) as T;
    }
    if (t == _ipnno8uy.Workspace) {
      return _ipnno8uy.Workspace.fromJson(data) as T;
    }
    if (t == _ih5av2eo.WorkspaceException) {
      return _ih5av2eo.WorkspaceException.fromJson(data) as T;
    }
    if (t == _i66b2tam.WorkspaceInvitation) {
      return _i66b2tam.WorkspaceInvitation.fromJson(data) as T;
    }
    if (t == _ihlvzd2h.WorkspaceMember) {
      return _ihlvzd2h.WorkspaceMember.fromJson(data) as T;
    }
    if (t == _i6w1n5dc.WorkspaceRole) {
      return _i6w1n5dc.WorkspaceRole.fromJson(data) as T;
    }
    if (t == _i0zqiur8.WorkspaceSummary) {
      return _i0zqiur8.WorkspaceSummary.fromJson(data) as T;
    }
    if (t == _ir8cxu8v.WorkspaceTicket) {
      return _ir8cxu8v.WorkspaceTicket.fromJson(data) as T;
    }
    if (t == _is.getType<_iffl96zw.AuthFlowException?>()) {
      return (data != null ? _iffl96zw.AuthFlowException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i810ioat.Feedback?>()) {
      return (data != null ? _i810ioat.Feedback.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iyk5pcfx.FeedbackWebhookKey?>()) {
      return (data != null ? _iyk5pcfx.FeedbackWebhookKey.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ixmckfyn.Team?>()) {
      return (data != null ? _ixmckfyn.Team.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_imd26z8h.GroupingFutureCallProcessModel?>()) {
      return (data != null
              ? _imd26z8h.GroupingFutureCallProcessModel.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i0swa0s1.DiscordGuild?>()) {
      return (data != null ? _i0swa0s1.DiscordGuild.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ichzz8bw.GroupedTicket?>()) {
      return (data != null ? _ichzz8bw.GroupedTicket.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ir0iqr2v.GroupingJob?>()) {
      return (data != null ? _ir0iqr2v.GroupingJob.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i5p49uup.InvitationDelivery?>()) {
      return (data != null ? _i5p49uup.InvitationDelivery.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iquvyw6s.InvitationInfo?>()) {
      return (data != null ? _iquvyw6s.InvitationInfo.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_irth3bb9.IssueGroup?>()) {
      return (data != null ? _irth3bb9.IssueGroup.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_itiylzhc.MemberInfo?>()) {
      return (data != null ? _itiylzhc.MemberInfo.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i8sxq4gq.MockSourceConnection?>()) {
      return (data != null
              ? _i8sxq4gq.MockSourceConnection.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ixag6zju.SourceSyncResult?>()) {
      return (data != null ? _ixag6zju.SourceSyncResult.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ipnno8uy.Workspace?>()) {
      return (data != null ? _ipnno8uy.Workspace.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ih5av2eo.WorkspaceException?>()) {
      return (data != null ? _ih5av2eo.WorkspaceException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i66b2tam.WorkspaceInvitation?>()) {
      return (data != null
              ? _i66b2tam.WorkspaceInvitation.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ihlvzd2h.WorkspaceMember?>()) {
      return (data != null ? _ihlvzd2h.WorkspaceMember.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i6w1n5dc.WorkspaceRole?>()) {
      return (data != null ? _i6w1n5dc.WorkspaceRole.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i0zqiur8.WorkspaceSummary?>()) {
      return (data != null ? _i0zqiur8.WorkspaceSummary.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ir8cxu8v.WorkspaceTicket?>()) {
      return (data != null ? _ir8cxu8v.WorkspaceTicket.fromJson(data) : null)
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_ir8cxu8v.WorkspaceTicket>) {
      return (data as List)
              .map((e) => deserialize<_ir8cxu8v.WorkspaceTicket>(e))
              .toList()
          as T;
    }
    if (t == List<_iig9z06a.MockSourceConnection>) {
      return (data as List)
              .map((e) => deserialize<_iig9z06a.MockSourceConnection>(e))
              .toList()
          as T;
    }
    if (t == List<_i9st2zmz.WorkspaceSummary>) {
      return (data as List)
              .map((e) => deserialize<_i9st2zmz.WorkspaceSummary>(e))
              .toList()
          as T;
    }
    if (t == List<_innlq9pp.MemberInfo>) {
      return (data as List)
              .map((e) => deserialize<_innlq9pp.MemberInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_in9kijmm.InvitationInfo>) {
      return (data as List)
              .map((e) => deserialize<_in9kijmm.InvitationInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i7phqsbk.WorkspaceTicket>) {
      return (data as List)
              .map((e) => deserialize<_i7phqsbk.WorkspaceTicket>(e))
              .toList()
          as T;
    }
    if (t == List<_ifvqah9b.GroupedTicket>) {
      return (data as List)
              .map((e) => deserialize<_ifvqah9b.GroupedTicket>(e))
              .toList()
          as T;
    }
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _iffl96zw.AuthFlowException => 'AuthFlowException',
      _i810ioat.Feedback => 'Feedback',
      _iyk5pcfx.FeedbackWebhookKey => 'FeedbackWebhookKey',
      _ixmckfyn.Team => 'Team',
      _imd26z8h.GroupingFutureCallProcessModel =>
        'GroupingFutureCallProcessModel',
      _izw8z7ou.Greeting => 'Greeting',
      _i0swa0s1.DiscordGuild => 'DiscordGuild',
      _ichzz8bw.GroupedTicket => 'GroupedTicket',
      _ir0iqr2v.GroupingJob => 'GroupingJob',
      _i5p49uup.InvitationDelivery => 'InvitationDelivery',
      _iquvyw6s.InvitationInfo => 'InvitationInfo',
      _irth3bb9.IssueGroup => 'IssueGroup',
      _itiylzhc.MemberInfo => 'MemberInfo',
      _i8sxq4gq.MockSourceConnection => 'MockSourceConnection',
      _ixag6zju.SourceSyncResult => 'SourceSyncResult',
      _ipnno8uy.Workspace => 'Workspace',
      _ih5av2eo.WorkspaceException => 'WorkspaceException',
      _i66b2tam.WorkspaceInvitation => 'WorkspaceInvitation',
      _ihlvzd2h.WorkspaceMember => 'WorkspaceMember',
      _i6w1n5dc.WorkspaceRole => 'WorkspaceRole',
      _i0zqiur8.WorkspaceSummary => 'WorkspaceSummary',
      _ir8cxu8v.WorkspaceTicket => 'WorkspaceTicket',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'feedback_aggregator.',
        '',
      );
    }

    switch (data) {
      case _iffl96zw.AuthFlowException():
        return 'AuthFlowException';
      case _i810ioat.Feedback():
        return 'Feedback';
      case _iyk5pcfx.FeedbackWebhookKey():
        return 'FeedbackWebhookKey';
      case _ixmckfyn.Team():
        return 'Team';
      case _imd26z8h.GroupingFutureCallProcessModel():
        return 'GroupingFutureCallProcessModel';
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _i0swa0s1.DiscordGuild():
        return 'DiscordGuild';
      case _ichzz8bw.GroupedTicket():
        return 'GroupedTicket';
      case _ir0iqr2v.GroupingJob():
        return 'GroupingJob';
      case _i5p49uup.InvitationDelivery():
        return 'InvitationDelivery';
      case _iquvyw6s.InvitationInfo():
        return 'InvitationInfo';
      case _irth3bb9.IssueGroup():
        return 'IssueGroup';
      case _itiylzhc.MemberInfo():
        return 'MemberInfo';
      case _i8sxq4gq.MockSourceConnection():
        return 'MockSourceConnection';
      case _ixag6zju.SourceSyncResult():
        return 'SourceSyncResult';
      case _ipnno8uy.Workspace():
        return 'Workspace';
      case _ih5av2eo.WorkspaceException():
        return 'WorkspaceException';
      case _i66b2tam.WorkspaceInvitation():
        return 'WorkspaceInvitation';
      case _ihlvzd2h.WorkspaceMember():
        return 'WorkspaceMember';
      case _i6w1n5dc.WorkspaceRole():
        return 'WorkspaceRole';
      case _i0zqiur8.WorkspaceSummary():
        return 'WorkspaceSummary';
      case _ir8cxu8v.WorkspaceTicket():
        return 'WorkspaceTicket';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AuthFlowException') {
      return deserialize<_iffl96zw.AuthFlowException>(data['data']);
    }
    if (dataClassName == 'Feedback') {
      return deserialize<_i810ioat.Feedback>(data['data']);
    }
    if (dataClassName == 'FeedbackWebhookKey') {
      return deserialize<_iyk5pcfx.FeedbackWebhookKey>(data['data']);
    }
    if (dataClassName == 'Team') {
      return deserialize<_ixmckfyn.Team>(data['data']);
    }
    if (dataClassName == 'GroupingFutureCallProcessModel') {
      return deserialize<_imd26z8h.GroupingFutureCallProcessModel>(
        data['data'],
      );
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'DiscordGuild') {
      return deserialize<_i0swa0s1.DiscordGuild>(data['data']);
    }
    if (dataClassName == 'GroupedTicket') {
      return deserialize<_ichzz8bw.GroupedTicket>(data['data']);
    }
    if (dataClassName == 'GroupingJob') {
      return deserialize<_ir0iqr2v.GroupingJob>(data['data']);
    }
    if (dataClassName == 'InvitationDelivery') {
      return deserialize<_i5p49uup.InvitationDelivery>(data['data']);
    }
    if (dataClassName == 'InvitationInfo') {
      return deserialize<_iquvyw6s.InvitationInfo>(data['data']);
    }
    if (dataClassName == 'IssueGroup') {
      return deserialize<_irth3bb9.IssueGroup>(data['data']);
    }
    if (dataClassName == 'MemberInfo') {
      return deserialize<_itiylzhc.MemberInfo>(data['data']);
    }
    if (dataClassName == 'MockSourceConnection') {
      return deserialize<_i8sxq4gq.MockSourceConnection>(data['data']);
    }
    if (dataClassName == 'SourceSyncResult') {
      return deserialize<_ixag6zju.SourceSyncResult>(data['data']);
    }
    if (dataClassName == 'Workspace') {
      return deserialize<_ipnno8uy.Workspace>(data['data']);
    }
    if (dataClassName == 'WorkspaceException') {
      return deserialize<_ih5av2eo.WorkspaceException>(data['data']);
    }
    if (dataClassName == 'WorkspaceInvitation') {
      return deserialize<_i66b2tam.WorkspaceInvitation>(data['data']);
    }
    if (dataClassName == 'WorkspaceMember') {
      return deserialize<_ihlvzd2h.WorkspaceMember>(data['data']);
    }
    if (dataClassName == 'WorkspaceRole') {
      return deserialize<_i6w1n5dc.WorkspaceRole>(data['data']);
    }
    if (dataClassName == 'WorkspaceSummary') {
      return deserialize<_i0zqiur8.WorkspaceSummary>(data['data']);
    }
    if (dataClassName == 'WorkspaceTicket') {
      return deserialize<_ir8cxu8v.WorkspaceTicket>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iais.Protocol().registerHostProtocol('feedback_aggregator', this);
    _iacs.Protocol().registerHostProtocol('feedback_aggregator', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i810ioat.Feedback:
        return _i810ioat.Feedback.t;
      case _iyk5pcfx.FeedbackWebhookKey:
        return _iyk5pcfx.FeedbackWebhookKey.t;
      case _ixmckfyn.Team:
        return _ixmckfyn.Team.t;
      case _i0swa0s1.DiscordGuild:
        return _i0swa0s1.DiscordGuild.t;
      case _ir0iqr2v.GroupingJob:
        return _ir0iqr2v.GroupingJob.t;
      case _irth3bb9.IssueGroup:
        return _irth3bb9.IssueGroup.t;
      case _i8sxq4gq.MockSourceConnection:
        return _i8sxq4gq.MockSourceConnection.t;
      case _ipnno8uy.Workspace:
        return _ipnno8uy.Workspace.t;
      case _i66b2tam.WorkspaceInvitation:
        return _i66b2tam.WorkspaceInvitation.t;
      case _ihlvzd2h.WorkspaceMember:
        return _ihlvzd2h.WorkspaceMember.t;
      case _ir8cxu8v.WorkspaceTicket:
        return _ir8cxu8v.WorkspaceTicket.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'feedback_aggregator';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
