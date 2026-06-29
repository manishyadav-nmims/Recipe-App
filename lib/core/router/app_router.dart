import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recipeapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:recipeapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:recipeapp/features/auth/presentation/pages/login_page.dart';
import 'package:recipeapp/features/splash/splash_page.dart';
import '../../features/home/home.dart';
import 'go_router_refresh_stream.dart';

class AppRouter {
  AppRouter._();

  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const recipes = '/recipes';
  static const favorites = '/favorites';

  static final navigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter() {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: splash,
      routes: [
        GoRoute(
          path: splash,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: home,
          builder: (context, state) => const Home(),
        ),
      ],
    );
  }
}