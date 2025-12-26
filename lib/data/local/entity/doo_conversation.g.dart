// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doo_conversation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DOOConversationAdapter extends TypeAdapter<DOOConversation> {
  @override
  final int typeId = 51;

  @override
  DOOConversation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DOOConversation(
      id: fields[0] as int,
      inboxId: fields[1] as int,
      messages: (fields[2] as List).cast<DOOMessage>(),
      contact: fields[3] as DOOContact,
    );
  }

  @override
  void write(BinaryWriter writer, DOOConversation obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.inboxId)
      ..writeByte(2)
      ..write(obj.messages)
      ..writeByte(3)
      ..write(obj.contact);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DOOConversationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DOOConversation _$DOOConversationFromJson(Map<String, dynamic> json) =>
    DOOConversation(
      id: (json['id'] as num).toInt(),
      inboxId: (json['inbox_id'] as num).toInt(),
      messages: (json['messages'] as List<dynamic>)
          .map((e) => DOOMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      contact: DOOContact.fromJson(json['contact'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DOOConversationToJson(DOOConversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'inbox_id': instance.inboxId,
      'messages': instance.messages.map((e) => e.toJson()).toList(),
      'contact': instance.contact.toJson(),
    };
