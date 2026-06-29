import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipeapp/app.dart';
import 'package:recipeapp/features/auth/data/models/user_hive_model.dart';
import 'package:recipeapp/features/splash/bloc/splash_bloc.dart';
import 'core/di/injection_container.dart' as di;
import 'package:recipeapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'core/storage/user_local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Hive.initFlutter();
  Hive.registerAdapter(UserHiveModelAdapter()); // generated adapter
  await UserLocalStorage.init();

  await di.init();
  final authBloc = di.sl<AuthBloc>();
  final splashBloc = di.sl<SplashBloc>();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => authBloc),
        BlocProvider<SplashBloc>(create: (_) => splashBloc),
      ],
      child: App(),
    ),
  );
}