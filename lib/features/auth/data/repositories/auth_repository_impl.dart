import 'package:recipeapp/core/network/api_response.dart';
import 'package:recipeapp/features/auth/data/services/auth_service.dart';
import 'package:recipeapp/features/auth/domain/entities/user_entity.dart';
import 'package:recipeapp/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _service;

  AuthRepositoryImpl(this._service);

  @override
  Future<ApiResponse<UserEntity>> login({
    required String username,
    required String password,
  }) {
    return _service.login(username: username, password: password);
  }
}