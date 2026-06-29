import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recipeapp/features/auth/presentation/pages/login_page.dart';
import 'package:recipeapp/features/splash/splash_page.dart';
import '../../features/recipes/presentation/page/recipe_detail_page.dart';
import '../../features/recipes/presentation/page/recipe_list_page.dart';
import '../../features/recipes/presentation/page/favorites_page.dart';

class AppRouter {
  AppRouter._();

  static const splash = '/';
  static const login = '/login';
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
          path: recipes,
          builder: (context, state) => const RecipeListPage(),
          routes: [
            // Nested so /recipes/:id shares the parent path prefix
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return RecipeDetailPage(recipeId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: favorites,
          builder: (context, state) => const FavoritesPage(),
        ),
      ],
    );
  }
}