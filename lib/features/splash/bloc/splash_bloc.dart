import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipeapp/core/network/secure_token_storage.dart';
import 'package:recipeapp/features/splash/bloc/splash_event.dart';
import 'package:recipeapp/features/splash/bloc/splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<CheckAuthStatusEvent>(_checkAuth);
  }

  Future<void> _checkAuth(CheckAuthStatusEvent event, Emitter<SplashState> emit) async {
    final isLoggedIn = await SecureTokenStorage.isLoggedIn();
    emit(isLoggedIn ? SplashAuthenticated() : SplashUnauthenticated());
  }
}