import 'package:get_it/get_it.dart';
import 'package:recipeapp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:recipeapp/features/auth/data/services/auth_service.dart';
import 'package:recipeapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:recipeapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:recipeapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:recipeapp/features/splash/bloc/splash_bloc.dart';

import '../../features/recipes/data/repositories/recipe_repository_impl.dart';
import '../../features/recipes/data/services/recipe_service.dart';
import '../../features/recipes/domain/repository/recipe_repository.dart';
import '../../features/recipes/domain/usecase/get_recipes_usecase.dart';
import '../../features/recipes/presentation/bloc/recipe_bloc.dart';
import '../../features/theme/bloc/theme_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {

  // Services
  sl.registerLazySingleton<AuthService>(() => AuthService());
  sl.registerLazySingleton<RecipeService>(() => RecipeService());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(sl<AuthService>()),
  );

  sl.registerLazySingleton<RecipeRepository>(
        () => RecipeRepositoryImpl(sl<RecipeService>()),
  );

  // Auth UseCases
  sl.registerLazySingleton<LoginUseCase>(
        () => LoginUseCase(sl<AuthRepository>()),
  );

  // Recipe UseCases
  sl.registerLazySingleton<GetRecipesUseCase>(
        () => GetRecipesUseCase(sl<RecipeRepository>()),
  );

  sl.registerLazySingleton<GetRecipeByIdUseCase>(
        () => GetRecipeByIdUseCase(sl<RecipeRepository>()),
  );

  sl.registerLazySingleton<SearchRecipesUseCase>(
        () => SearchRecipesUseCase(sl<RecipeRepository>()),
  );

  sl.registerLazySingleton<GetCachedRecipesUseCase>(
        () => GetCachedRecipesUseCase(sl<RecipeRepository>()),
  );

  sl.registerLazySingleton<GetFavoriteIdsUseCase>(
        () => GetFavoriteIdsUseCase(sl<RecipeRepository>()),
  );

  sl.registerLazySingleton<ToggleFavoriteUseCase>(
        () => ToggleFavoriteUseCase(sl<RecipeRepository>()),
  );

  // Blocs
  sl.registerFactory<AuthBloc>(
        () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
    ),
  );

  sl.registerFactory<RecipeBloc>(
        () => RecipeBloc(
      getRecipesUseCase: sl<GetRecipesUseCase>(),
      getRecipeByIdUseCase: sl<GetRecipeByIdUseCase>(),
      searchRecipesUseCase: sl<SearchRecipesUseCase>(),
      getCachedRecipesUseCase: sl<GetCachedRecipesUseCase>(),
      getFavoriteIdsUseCase: sl<GetFavoriteIdsUseCase>(),
      toggleFavoriteUseCase: sl<ToggleFavoriteUseCase>(),
    ),
  );

  sl.registerFactory<SplashBloc>(
        () => SplashBloc(),
  );
  sl.registerFactory<ThemeBloc>(() => ThemeBloc());
}