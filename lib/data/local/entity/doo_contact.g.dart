// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doo_contact.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DOOContactAdapter extends TypeAdapter<DOOContact> {
  @override
  final int typeId = 50;

  @override
  DOOContact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DOOContact(
      id: fields[0] as int?,
      contactIdentifier: fields[1] as String?,
      pubsubToken: fields[2] as String?,
      name: fields[3] as String?,
      email: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DOOContact obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.contactIdentifier)
      ..writeByte(2)
      ..write(obj.pubsubToken)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.email);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DOOContactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DOOContact _$DOOContactFromJson(Map<String, dynamic> json) => DOOContact(
      id: (json['id'] as num?)?.toInt(),
      contactIdentifier: json['source_id'] as String?,
      pubsubToken: json['pubsub_token'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$DOOContactToJson(DOOContact instance) =>
    <String, dynamic>{
      'id': instance.id,
      'source_id': instance.contactIdentifier,
      'pubsub_token': instance.pubsubToken,
      'name': instance.name,
      'email': instance.email,
    };
