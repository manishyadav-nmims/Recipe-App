import 'package:recipeapp/core/network/api_response.dart';
import 'package:recipeapp/core/network/base_service.dart';
import 'package:recipeapp/features/auth/data/models/user_model.dart';

class AuthService extends BaseService {
  AuthService() : super('https://dummyjson.com');

  Future<ApiResponse<UserModel>> login({
    required String username,
    required String password,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
        'expiresInMins': 30,
      },
    );

    return switch (response) {
      ApiSuccess(:final data) => ApiSuccess(UserModel.fromJson(data)),
      ApiFailure(:final message) => ApiFailure(message),
    };
  }
}