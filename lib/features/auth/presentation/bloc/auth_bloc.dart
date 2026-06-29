import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipeapp/core/network/api_response.dart';
import 'package:recipeapp/core/network/secure_token_storage.dart';
import 'package:recipeapp/core/storage/user_local_storage.dart';
import 'package:recipeapp/features/auth/data/models/user_hive_model.dart';
import 'package:recipeapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:recipeapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:recipeapp/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;

  AuthBloc({required LoginUseCase loginUseCase})
      : _loginUseCase = loginUseCase,
        super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_logout);
  }

  Future<void> _onLogin(
      LoginEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoadingState());

    final result = await _loginUseCase(
      username: event.email,
      password: event.password,
    );

    switch (result) {
      case ApiSuccess(:final data):
        await SecureTokenStorage.saveTokens(
          accessToken: data.accessToken,
          refreshToken: data.refreshToken,
        );
        // Save full user to Hive
        await UserLocalStorage.saveUser(
          UserHiveModel(
            id: data.id,
            username: data.username,
            email: data.email,
            firstName: data.firstName,
            lastName: data.lastName,
            image: data.image,
            gender: data.gender,
            accessToken: data.accessToken,
            refreshToken: data.refreshToken,
          ),
        );

        emit(AuthAuthenticatedState(data));

      case ApiFailure(:final message):
        emit(AuthErrorState(message));
    }
  }

  Future<void> _logout(
      LogoutEvent event,
      Emitter<AuthState> emit,
      ) async {
    await SecureTokenStorage.clear();
    emit(AuthUnauthenticatedState());
  }
}