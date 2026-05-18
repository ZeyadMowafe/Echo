import 'package:echo_explorer/features/profile/domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  ProfileModel({required super.id, required super.name, required super.email, required super.preferredLanguage});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'User',
      email: json['email'] ?? '',
      preferredLanguage: json['preferredLanguage'] ?? 'en',
    );
  }
}