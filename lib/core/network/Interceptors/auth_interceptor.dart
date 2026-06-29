import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recipeapp/core/network/secure_token_storage.dart';
import 'package:recipeapp/core/router/app_router.dart';

class AuthInterceptor extends Interceptor {
  static bool _isDialogShowing = false;

  @override
  Future<void> onRequest(RequestOptions options,
      RequestInterceptorHandler handler,) async {
    final refresh = await SecureTokenStorage.getRefreshToken();
    final access = await SecureTokenStorage.getAccessToken();

    if (refresh != null) options.headers['refresh-token'] = refresh;
    if (access != null) options.headers['access-token'] = access;

    handler.next(options);
  }

  @override
  Future<void> onResponse(Response response,
      ResponseInterceptorHandler handler,) async {
    final accessHeader = response.headers.value('access-token');
    final refreshHeader = response.headers.value('refresh-token');

    if (accessHeader != null) {
      final oldRefreshToken = await SecureTokenStorage.getRefreshToken();
      await SecureTokenStorage.saveTokens(
        accessToken: accessHeader,
        refreshToken: refreshHeader ?? oldRefreshToken ?? '',
      );
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401 && !_isDialogShowing) {
      _isDialogShowing = true;
      Future.microtask(() => _handleUnauthorized());
    }
    handler.next(err);
  }

  Future<void> _handleUnauthorized() async {
    await SecureTokenStorage.clear();
    final context = AppRouter.navigatorKey.currentContext;

    if (context == null) {
      _isDialogShowing = false;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: AppRouter.navigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Session Expired'),
          content: const Text('Your session has expired. Please log in again.'),
          actions: [
            TextButton(
              onPressed: () {
                _isDialogShowing = false;
                AppRouter.navigatorKey.currentState?.pop();
                AppRouter.navigatorKey.currentContext?.go('/login');
              },
              child: const Text('Re-login'),
            ),
          ],
        ),
      );
    });
  }
}