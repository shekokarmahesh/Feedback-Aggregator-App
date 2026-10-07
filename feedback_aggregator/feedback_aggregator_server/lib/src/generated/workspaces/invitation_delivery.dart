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
import 'package:feedback_aggregator_server/src/generated/protocol.dart'
    as _iwl9u20j;
import 'package:serverpod/serverpod.dart' as _is;
import '../workspaces/invitation_info.dart' as _ilk2cxpf;

abstract class InvitationDelivery
    implements _is.SerializableModel, _is.ProtocolSerialization {
  InvitationDelivery._({
    required this.invitation,
    required this.url,
    required this.emailSent,
  });

  factory InvitationDelivery({
    required _ilk2cxpf.InvitationInfo invitation,
    required String url,
    required bool emailSent,
  }) = _InvitationDeliveryImpl;

  factory InvitationDelivery.fromJson(Map<String, dynamic> jsonSerialization) {
    return InvitationDelivery(
      invitation: _iwl9u20j.Protocol().deserialize<_ilk2cxpf.InvitationInfo>(
        jsonSerialization['invitation'],
      ),
      url: jsonSerialization['url'] as String,
      emailSent: _is.BoolJsonExtension.fromJson(jsonSerialization['emailSent']),
    );
  }

  _ilk2cxpf.InvitationInfo invitation;

  String url;

  bool emailSent;

  /// Returns a shallow copy of this [InvitationDelivery]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  InvitationDelivery copyWith({
    _ilk2cxpf.InvitationInfo? invitation,
    String? url,
    bool? emailSent,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'InvitationDelivery',
      'invitation': invitation.toJson(),
      'url': url,
      'emailSent': emailSent,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'InvitationDelivery',
      'invitation': invitation.toJsonForProtocol(),
      'url': url,
      'emailSent': emailSent,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _InvitationDeliveryImpl extends InvitationDelivery {
  _InvitationDeliveryImpl({
    required _ilk2cxpf.InvitationInfo invitation,
    required String url,
    required bool emailSent,
  }) : super._(
         invitation: invitation,
         url: url,
         emailSent: emailSent,
       );

  /// Returns a shallow copy of this [InvitationDelivery]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  InvitationDelivery copyWith({
    _ilk2cxpf.InvitationInfo? invitation,
    String? url,
    bool? emailSent,
  }) {
    return InvitationDelivery(
      invitation: invitation ?? this.invitation.copyWith(),
      url: url ?? this.url,
      emailSent: emailSent ?? this.emailSent,
    );
  }
}
