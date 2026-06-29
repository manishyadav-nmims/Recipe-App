import 'package:recipeapp/core/network/api_response.dart';
import 'package:recipeapp/features/auth/domain/entities/user_entity.dart';
import 'package:recipeapp/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<ApiResponse<UserEntity>> call({
    required String username,
    required String password,
  }) {
    return _repository.login(username: username, password: password);
  }
}