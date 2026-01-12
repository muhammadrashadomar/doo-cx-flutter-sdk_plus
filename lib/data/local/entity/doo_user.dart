import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

import '../local_storage.dart';

part 'doo_user.g.dart';

/// DOO user represents a customer or user in the DOO system
///
/// This class is used to identify and personalize the customer's experience
@JsonSerializable(explicitToJson: true)
@HiveType(typeId: DOO_USER_HIVE_TYPE_ID)
class DOOUser extends Equatable {
  ///custom DOO user identifier (required)
  @JsonKey()
  @HiveField(0)
  final String? identifier;

  ///custom user identifier hash
  @JsonKey(name: "identifier_hash")
  @HiveField(1)
  final String? identifierHash;

  ///name of DOO user
  @JsonKey()
  @HiveField(2)
  final String? name;

  ///email of DOO user
  @JsonKey()
  @HiveField(3)
  final String? email;

  ///profile picture url of user
  @JsonKey(name: "avatar_url")
  @HiveField(4)
  final String? avatarUrl;

  ///any other custom attributes to be linked to the user
  @JsonKey(name: "custom_attributes")
  @HiveField(5)
  final Map<String, String>? customAttributes;

  @JsonKey(name: "contact_attributes")
  @HiveField(6)
  final Map<String, String>? contactAttributes;

  /// Creates a DOOUser instance with user information
  ///
  /// [identifier] is required for user tracking across sessions
  /// [name] and [email] are recommended for better user experience
  DOOUser(
      {this.identifier,
      this.identifierHash,
      this.name,
      this.email,
      this.avatarUrl,
      this.customAttributes,
      this.contactAttributes});

  /// Factory constructor to create a DOOUser from JSON
  factory DOOUser.fromJson(Map<String, dynamic> json) =>
      _$DOOUserFromJson(json);

  /// Convert DOOUser to JSON
  Map<String, dynamic> toJson() => _$DOOUserToJson(this);

  @override
  List<Object?> get props => [
        identifier,
        identifierHash,
        name,
        email,
        avatarUrl,
        customAttributes,
        contactAttributes,
      ];
}
