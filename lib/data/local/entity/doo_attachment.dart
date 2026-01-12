import 'package:doo_cx_flutter_sdk_plus/data/local/local_storage.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'doo_attachment.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: DOO_ATTACHMENT_HIVE_TYPE_ID)
class DOOAttachment extends Equatable {
  @JsonKey(fromJson: _idFromJson)
  @HiveField(0)
  final num? id;

  @JsonKey(name: "message_id")
  @HiveField(1)
  final num? messageId;

  @JsonKey(name: "file_type")
  @HiveField(2)
  final String? type;

  @JsonKey()
  @HiveField(3)
  final String? extension;

  @JsonKey(name: "data_url")
  @HiveField(4)
  final String? url;

  @JsonKey(name: "thumb_url")
  @HiveField(5)
  final String? thumbnailUrl;

  @JsonKey()
  @HiveField(6)
  final String? filename;

  const DOOAttachment({
    this.id,
    this.messageId,
    this.type,
    this.extension,
    this.url,
    this.thumbnailUrl,
    this.filename,
  });

  factory DOOAttachment.fromJson(Map<String, dynamic> json) =>
      _$DOOAttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$DOOAttachmentToJson(this);

  @override
  List<Object?> get props =>
      [id, messageId, type, extension, url, thumbnailUrl, filename];
}

num _idFromJson(value) {
  if (value is String) {
    return num.tryParse(value) ?? 0;
  }
  return value;
}
