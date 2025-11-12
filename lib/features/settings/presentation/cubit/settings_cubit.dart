import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/settings_model.dart';
import '../../../../core/services/database_service.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final DatabaseService _databaseService;

  SettingsCubit(this._databaseService) : super(SettingsInitial());

  Future<void> loadSettings() async {
    emit(SettingsLoading());
    try {
      final settings = await _databaseService.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> saveSettings(SettingsModel settings) async {
    try {
      await _databaseService.saveSettings(settings);
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> updateAutoLockEnabled(bool enabled) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final updatedSettings = currentSettings.copyWith(autoLockEnabled: enabled);
      await saveSettings(updatedSettings);
    }
  }

  Future<void> updateAutoLockDuration(int duration) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final updatedSettings = currentSettings.copyWith(autoLockDuration: duration);
      await saveSettings(updatedSettings);
    }
  }

  Future<void> updateThemeMode(String themeMode) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final updatedSettings = currentSettings.copyWith(themeMode: themeMode);
      await saveSettings(updatedSettings);
    }
  }
}