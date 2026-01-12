// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doo_attachment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DOOAttachmentAdapter extends TypeAdapter<DOOAttachment> {
  @override
  final int typeId = 55;

  @override
  DOOAttachment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DOOAttachment(
      id: fields[0] as num?,
      messageId: fields[1] as num?,
      type: fields[2] as String?,
      extension: fields[3] as String?,
      url: fields[4] as String?,
      thumbnailUrl: fields[5] as String?,
      filename: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DOOAttachment obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.messageId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.extension)
      ..writeByte(4)
      ..write(obj.url)
      ..writeByte(5)
      ..write(obj.thumbnailUrl)
      ..writeByte(6)
      ..write(obj.filename);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DOOAttachmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DOOAttachment _$DOOAttachmentFromJson(Map<String, dynamic> json) =>
    DOOAttachment(
      id: _idFromJson(json['id']),
      messageId: json['message_id'] as num?,
      type: json['file_type'] as String?,
      extension: json['extension'] as String?,
      url: json['data_url'] as String?,
      thumbnailUrl: json['thumb_url'] as String?,
      filename: json['filename'] as String?,
    );

Map<String, dynamic> _$DOOAttachmentToJson(DOOAttachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message_id': instance.messageId,
      'file_type': instance.type,
      'extension': instance.extension,
      'data_url': instance.url,
      'thumb_url': instance.thumbnailUrl,
      'filename': instance.filename,
    };
