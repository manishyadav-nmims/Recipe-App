import 'package:recipeapp/core/network/api_response.dart';
import 'package:recipeapp/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<ApiResponse<UserEntity>> login({
    required String username,
    required String password,
  });
}