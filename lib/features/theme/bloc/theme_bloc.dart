import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipeapp/features/theme/bloc/theme_event.dart';
import 'package:recipeapp/features/theme/bloc/theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState()) {
    on<ToggleThemeEvent>((event, emit) {
      emit(state.copyWith(isDark: event.isDark));
    });
  }
}
