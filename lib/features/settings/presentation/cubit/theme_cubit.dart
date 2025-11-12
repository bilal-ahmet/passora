import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/database_service.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final DatabaseService _databaseService;

  ThemeCubit(this._databaseService) : super(ThemeInitial());

  Future<void> loadTheme() async {
    try {
      emit(ThemeLoading());
      final settings = await _databaseService.getSettings();
      
      ThemeMode themeMode;
      switch (settings.themeMode) {
        case 'light':
          themeMode = ThemeMode.light;
          break;
        case 'dark':
          themeMode = ThemeMode.dark;
          break;
        default:
          themeMode = ThemeMode.system;
      }
      
      emit(ThemeLoaded(themeMode));
    } catch (e) {
      emit(ThemeError('Failed to load theme: $e'));
    }
  }

  Future<void> changeTheme(ThemeMode themeMode) async {
    try {
      emit(ThemeLoading());
      
      // Load current settings
      final settings = await _databaseService.getSettings();
      
      String themeModeString;
      switch (themeMode) {
        case ThemeMode.light:
          themeModeString = 'light';
          break;
        case ThemeMode.dark:
          themeModeString = 'dark';
          break;
        default:
          themeModeString = 'system';
      }
      
      // Update theme mode
      final updatedSettings = settings.copyWith(themeMode: themeModeString);
      
      // Save to database
      await _databaseService.saveSettings(updatedSettings);
      
      emit(ThemeLoaded(themeMode));
    } catch (e) {
      emit(ThemeError('Failed to change theme: $e'));
    }
  }
}