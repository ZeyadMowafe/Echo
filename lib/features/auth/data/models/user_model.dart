import 'package:echo_explorer/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({required super.token, required super.name, required super.email});

  factory UserModel.fromJson(Map<String, dynamic> json, {String? fallbackName}) {
    return UserModel(
      token: json['token'] ?? '',
      name: json['profile']?['name'] ?? json['name'] ?? fallbackName ?? 'User',
      email: json['profile']?['email'] ?? json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'name': name,
      'email': email,
    };
  }
}
