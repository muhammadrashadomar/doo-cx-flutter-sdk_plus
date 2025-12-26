import 'package:doo_cx_flutter_sdk_plus/data/local/entity/doo_contact.dart';
import 'package:doo_cx_flutter_sdk_plus/data/local/local_storage.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import 'doo_message.dart';
part 'doo_conversation.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: DOO_CONVERSATION_HIVE_TYPE_ID)
class DOOConversation extends Equatable {
  ///The numeric ID of the conversation
  @JsonKey()
  @HiveField(0)
  final int id;

  ///The numeric ID of the inbox
  @JsonKey(name: "inbox_id")
  @HiveField(1)
  final int inboxId;

  ///List of all messages from the conversation
  @JsonKey()
  @HiveField(2)
  final List<DOOMessage> messages;

  ///Contact of the conversation
  @JsonKey()
  @HiveField(3)
  final DOOContact contact;

  DOOConversation(
      {required this.id,
      required this.inboxId,
      required this.messages,
      required this.contact});

  factory DOOConversation.fromJson(Map<String, dynamic> json) =>
      _$DOOConversationFromJson(json);

  Map<String, dynamic> toJson() => _$DOOConversationToJson(this);

  @override
  List<Object?> get props => [id, inboxId, messages, contact];
}
