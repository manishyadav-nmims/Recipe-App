import 'package:recipeapp/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.image,
    required super.gender,
    required super.accessToken,
    required super.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    username: json['username'],
    email: json['email'],
    firstName: json['firstName'],
    lastName: json['lastName'],
    image: json['image'] ?? '',
    gender: json['gender'] ?? '',
    accessToken: json['accessToken'],
    refreshToken: json['refreshToken'],
  );
}