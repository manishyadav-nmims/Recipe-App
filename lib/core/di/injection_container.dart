import 'package:get_it/get_it.dart';
import 'package:recipeapp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:recipeapp/features/auth/data/services/auth_service.dart';
import 'package:recipeapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:recipeapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:recipeapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:recipeapp/features/splash/bloc/splash_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {

  // ── Services ──────────────────────────────────────────
  sl.registerLazySingleton<AuthService>(() => AuthService());

  // ── Repositories ──────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(sl<AuthService>()),
  );

  // ── Use Cases ─────────────────────────────────────────
  sl.registerLazySingleton<LoginUseCase>(
        () => LoginUseCase(sl<AuthRepository>()),
  );

  // ── Blocs ─────────────────────────────────────────────
  sl.registerLazySingleton<AuthBloc>(
        () => AuthBloc(loginUseCase: sl<LoginUseCase>()),
  );

  sl.registerLazySingleton<SplashBloc>(
        () => SplashBloc(),
  );
}