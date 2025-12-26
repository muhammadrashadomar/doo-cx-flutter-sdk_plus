import 'package:doo_cx_flutter_sdk_plus/data/local/local_storage.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../local/entity/doo_message.dart';

part 'doo_event.g.dart';

@JsonSerializable(explicitToJson: true)
class DOOEvent {
  @JsonKey(toJson: eventTypeToJson, fromJson: eventTypeFromJson)
  final DOOEventType? type;

  @JsonKey()
  final String? identifier;

  @JsonKey(fromJson: eventMessageFromJson)
  final DOOEventMessage? message;

  DOOEvent({this.type, this.message, this.identifier});

  factory DOOEvent.fromJson(Map<String, dynamic> json) =>
      _$DOOEventFromJson(json);

  Map<String, dynamic> toJson() => _$DOOEventToJson(this);
}

DOOEventMessage? eventMessageFromJson(value) {
  if (value == null) {
    return null;
  } else if (value is num) {
    return DOOEventMessage();
  } else if (value is String) {
    return DOOEventMessage();
  } else {
    return DOOEventMessage.fromJson(value as Map<String, dynamic>);
  }
}

@JsonSerializable(explicitToJson: true)
class DOOEventMessage {
  @JsonKey()
  final DOOEventMessageData? data;

  @JsonKey(toJson: eventMessageTypeToJson, fromJson: eventMessageTypeFromJson)
  final DOOEventMessageType? event;

  DOOEventMessage({this.data, this.event});

  factory DOOEventMessage.fromJson(Map<String, dynamic> json) =>
      _$DOOEventMessageFromJson(json);

  Map<String, dynamic> toJson() => _$DOOEventMessageToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DOOEventMessageData {
  @JsonKey(name: "account_id")
  final int? accountId;

  @JsonKey()
  final String? content;

  @JsonKey(name: "content_attributes")
  final dynamic contentAttributes;

  @JsonKey(name: "content_type")
  final String? contentType;

  @JsonKey(name: "conversation_id")
  final int? conversationId;

  @JsonKey(name: "created_at")
  final dynamic createdAt;

  @JsonKey(name: "echo_id")
  final String? echoId;

  @JsonKey(name: "external_source_ids")
  final dynamic externalSourceIds;

  @JsonKey()
  final int? id;

  @JsonKey(name: "inbox_id")
  final int? inboxId;

  @JsonKey(name: "message_type")
  final int? messageType;

  @JsonKey(name: "private")
  final bool? private;

  @JsonKey()
  final DOOEventMessageUser? sender;

  @JsonKey(name: "sender_id")
  final int? senderId;

  @JsonKey(name: "source_id")
  final String? sourceId;

  @JsonKey()
  final String? status;

  @JsonKey(name: "updated_at")
  final dynamic updatedAt;

  @JsonKey()
  final dynamic conversation;

  @JsonKey()
  final DOOEventMessageUser? user;

  @JsonKey()
  final dynamic users;

  DOOEventMessageData(
      {this.id,
      this.user,
      this.conversation,
      this.echoId,
      this.sender,
      this.conversationId,
      this.createdAt,
      this.contentAttributes,
      this.contentType,
      this.messageType,
      this.content,
      this.inboxId,
      this.sourceId,
      this.updatedAt,
      this.status,
      this.accountId,
      this.externalSourceIds,
      this.private,
      this.senderId,
      this.users});

  factory DOOEventMessageData.fromJson(Map<String, dynamic> json) =>
      _$DOOEventMessageDataFromJson(json);

  Map<String, dynamic> toJson() => _$DOOEventMessageDataToJson(this);

  getMessage() {
    return DOOMessage.fromJson(toJson());
  }
}

/// {@category FlutterClientSdk}
@HiveType(typeId: DOO_EVENT_USER_HIVE_TYPE_ID)
@JsonSerializable(explicitToJson: true)
class DOOEventMessageUser extends Equatable {
  @JsonKey(name: "avatar_url")
  @HiveField(0)
  final String? avatarUrl;

  @JsonKey()
  @HiveField(1)
  final int? id;

  @JsonKey()
  @HiveField(2)
  final String? name;

  @JsonKey()
  @HiveField(3)
  final String? thumbnail;

  DOOEventMessageUser({this.id, this.avatarUrl, this.name, this.thumbnail});

  factory DOOEventMessageUser.fromJson(Map<String, dynamic> json) =>
      _$DOOEventMessageUserFromJson(json);

  Map<String, dynamic> toJson() => _$DOOEventMessageUserToJson(this);

  @override
  List<Object?> get props => [id, avatarUrl, name, thumbnail];
}

enum DOOEventType { welcome, ping, confirm_subscription }

String? eventTypeToJson(DOOEventType? actionType) {
  return actionType.toString();
}

DOOEventType? eventTypeFromJson(String? value) {
  switch (value) {
    case "welcome":
      return DOOEventType.welcome;
    case "ping":
      return DOOEventType.ping;
    case "confirm_subscription":
      return DOOEventType.confirm_subscription;
    default:
      return null;
  }
}

enum DOOEventMessageType {
  presence_update,
  message_created,
  message_updated,
  conversation_typing_off,
  conversation_typing_on,
  conversation_status_changed
}

String? eventMessageTypeToJson(DOOEventMessageType? actionType) {
  switch (actionType) {
    case null:
      return null;
    case DOOEventMessageType.conversation_typing_on:
      return "conversation.typing_on";
    case DOOEventMessageType.conversation_typing_off:
      return "conversation.typing_off";
    case DOOEventMessageType.presence_update:
      return "presence.update";
    case DOOEventMessageType.message_created:
      return "message.created";
    case DOOEventMessageType.message_updated:
      return "message.updated";
    case DOOEventMessageType.conversation_status_changed:
      return "conversation.status_changed";
  }
}

DOOEventMessageType? eventMessageTypeFromJson(String? value) {
  switch (value) {
    case "presence.update":
      return DOOEventMessageType.presence_update;
    case "message.created":
      return DOOEventMessageType.message_created;
    case "message.updated":
      return DOOEventMessageType.message_updated;
    case "conversation.typing_on":
      return DOOEventMessageType.conversation_typing_on;
    case "conversation.typing_off":
      return DOOEventMessageType.conversation_typing_off;
    case "conversation.status_changed":
      return DOOEventMessageType.conversation_status_changed;
    default:
      return null;
  }
}
