import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'doo_new_message_request.g.dart';

@JsonSerializable(explicitToJson: true)
class DOONewMessageRequest extends Equatable {
  @JsonKey()
  final String content;
  @JsonKey(name: "echo_id")
  final String echoId;
  @JsonKey(
      name: "attachment_paths", includeFromJson: false, includeToJson: false)
  final List<String>? attachmentPaths;

  DOONewMessageRequest(
      {required this.content, required this.echoId, this.attachmentPaths});

  @override
  List<Object?> get props => [content, echoId, attachmentPaths];

  factory DOONewMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$DOONewMessageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DOONewMessageRequestToJson(this);
}
