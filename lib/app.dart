import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipeapp/core/router/app_router.dart';
import 'package:recipeapp/features/theme/app_theme.dart';

import 'features/theme/bloc/theme_bloc.dart';
import 'features/theme/bloc/theme_state.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeState.isDark ? ThemeMode.dark : ThemeMode.light,
          routerConfig: AppRouter.createRouter(),
        );
      },
    );
  }
}