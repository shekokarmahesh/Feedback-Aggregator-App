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
import 'package:feedback_aggregator_client/src/protocol/workspaces/invitation_info.dart'
    as _ib0gvgdq;
import 'package:feedback_aggregator_client/src/protocol/workspaces/member_info.dart'
    as _irkpghaa;
import 'package:feedback_aggregator_client/src/protocol/workspaces/workspace_summary.dart'
    as _in30w5p5;
import 'package:feedback_aggregator_client/src/protocol/workspaces/workspace_ticket.dart'
    as _ikphcpie;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'auth/auth_flow_exception.dart' as _iffl96zw;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'workspaces/invitation_delivery.dart' as _i5p49uup;
import 'workspaces/invitation_info.dart' as _iquvyw6s;
import 'workspaces/member_info.dart' as _itiylzhc;
import 'workspaces/workspace_exception.dart' as _ih5av2eo;
import 'workspaces/workspace_role.dart' as _i6w1n5dc;
import 'workspaces/workspace_summary.dart' as _i0zqiur8;
import 'workspaces/workspace_ticket.dart' as _ir8cxu8v;
export 'auth/auth_flow_exception.dart';
export 'greetings/greeting.dart';
export 'workspaces/invitation_delivery.dart';
export 'workspaces/invitation_info.dart';
export 'workspaces/member_info.dart';
export 'workspaces/workspace_exception.dart';
export 'workspaces/workspace_role.dart';
export 'workspaces/workspace_summary.dart';
export 'workspaces/workspace_ticket.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

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
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _iffl96zw.AuthFlowException) {
      return _iffl96zw.AuthFlowException.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _i5p49uup.InvitationDelivery) {
      return _i5p49uup.InvitationDelivery.fromJson(data) as T;
    }
    if (t == _iquvyw6s.InvitationInfo) {
      return _iquvyw6s.InvitationInfo.fromJson(data) as T;
    }
    if (t == _itiylzhc.MemberInfo) {
      return _itiylzhc.MemberInfo.fromJson(data) as T;
    }
    if (t == _ih5av2eo.WorkspaceException) {
      return _ih5av2eo.WorkspaceException.fromJson(data) as T;
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
    if (t == _isc.getType<_iffl96zw.AuthFlowException?>()) {
      return (data != null ? _iffl96zw.AuthFlowException.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i5p49uup.InvitationDelivery?>()) {
      return (data != null ? _i5p49uup.InvitationDelivery.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iquvyw6s.InvitationInfo?>()) {
      return (data != null ? _iquvyw6s.InvitationInfo.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_itiylzhc.MemberInfo?>()) {
      return (data != null ? _itiylzhc.MemberInfo.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ih5av2eo.WorkspaceException?>()) {
      return (data != null ? _ih5av2eo.WorkspaceException.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i6w1n5dc.WorkspaceRole?>()) {
      return (data != null ? _i6w1n5dc.WorkspaceRole.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i0zqiur8.WorkspaceSummary?>()) {
      return (data != null ? _i0zqiur8.WorkspaceSummary.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ir8cxu8v.WorkspaceTicket?>()) {
      return (data != null ? _ir8cxu8v.WorkspaceTicket.fromJson(data) : null)
          as T;
    }
    if (t == List<_in30w5p5.WorkspaceSummary>) {
      return (data as List)
              .map((e) => deserialize<_in30w5p5.WorkspaceSummary>(e))
              .toList()
          as T;
    }
    if (t == List<_irkpghaa.MemberInfo>) {
      return (data as List)
              .map((e) => deserialize<_irkpghaa.MemberInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_ib0gvgdq.InvitationInfo>) {
      return (data as List)
              .map((e) => deserialize<_ib0gvgdq.InvitationInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_ikphcpie.WorkspaceTicket>) {
      return (data as List)
              .map((e) => deserialize<_ikphcpie.WorkspaceTicket>(e))
              .toList()
          as T;
    }
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _iffl96zw.AuthFlowException => 'AuthFlowException',
      _izw8z7ou.Greeting => 'Greeting',
      _i5p49uup.InvitationDelivery => 'InvitationDelivery',
      _iquvyw6s.InvitationInfo => 'InvitationInfo',
      _itiylzhc.MemberInfo => 'MemberInfo',
      _ih5av2eo.WorkspaceException => 'WorkspaceException',
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
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _i5p49uup.InvitationDelivery():
        return 'InvitationDelivery';
      case _iquvyw6s.InvitationInfo():
        return 'InvitationInfo';
      case _itiylzhc.MemberInfo():
        return 'MemberInfo';
      case _ih5av2eo.WorkspaceException():
        return 'WorkspaceException';
      case _i6w1n5dc.WorkspaceRole():
        return 'WorkspaceRole';
      case _i0zqiur8.WorkspaceSummary():
        return 'WorkspaceSummary';
      case _ir8cxu8v.WorkspaceTicket():
        return 'WorkspaceTicket';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
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
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'InvitationDelivery') {
      return deserialize<_i5p49uup.InvitationDelivery>(data['data']);
    }
    if (dataClassName == 'InvitationInfo') {
      return deserialize<_iquvyw6s.InvitationInfo>(data['data']);
    }
    if (dataClassName == 'MemberInfo') {
      return deserialize<_itiylzhc.MemberInfo>(data['data']);
    }
    if (dataClassName == 'WorkspaceException') {
      return deserialize<_ih5av2eo.WorkspaceException>(data['data']);
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
      return _iaic.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iaic.Protocol().registerHostProtocol('feedback_aggregator', this);
    _iacc.Protocol().registerHostProtocol('feedback_aggregator', this);
  }

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
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
