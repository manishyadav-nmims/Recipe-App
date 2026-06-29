import 'package:flutter/material.dart';
import 'package:recipeapp/core/router/app_router.dart';
import 'package:recipeapp/core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.createRouter(),
    );
  }
}