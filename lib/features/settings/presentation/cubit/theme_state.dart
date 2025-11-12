part of 'theme_cubit.dart';

abstract class ThemeState {}

class ThemeInitial extends ThemeState {}

class ThemeLoading extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final ThemeMode themeMode;
  
  ThemeLoaded(this.themeMode);
}

class ThemeError extends ThemeState {
  final String message;
  
  ThemeError(this.message);
}