import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/password_model.dart';
import '../../../../core/services/database_service.dart';

part 'passwords_state.dart';

class PasswordsCubit extends Cubit<PasswordsState> {
  final DatabaseService _databaseService;

  PasswordsCubit(this._databaseService) : super(PasswordsInitial());

  Future<void> loadPasswords() async {
    emit(PasswordsLoading());
    try {
      final passwords = await _databaseService.getAllPasswords();
      emit(PasswordsLoaded(passwords));
    } catch (e) {
      emit(PasswordsError(e.toString()));
    }
  }

  Future<void> searchPasswords(String query) async {
    emit(PasswordsLoading());
    try {
      final passwords = await _databaseService.searchPasswords(query);
      emit(PasswordsLoaded(passwords));
    } catch (e) {
      emit(PasswordsError(e.toString()));
    }
  }

  Future<void> savePassword(PasswordModel password) async {
    try {
      await _databaseService.savePassword(password);
      // Reload passwords after save
      await loadPasswords();
    } catch (e) {
      emit(PasswordsError(e.toString()));
    }
  }

  Future<void> deletePassword(int id) async {
    try {
      await _databaseService.deletePassword(id);
      // Reload passwords after delete
      await loadPasswords();
    } catch (e) {
      emit(PasswordsError(e.toString()));
    }
  }

  Future<PasswordModel?> getPasswordById(int id) async {
    try {
      return await _databaseService.getPasswordById(id);
    } catch (e) {
      emit(PasswordsError(e.toString()));
      return null;
    }
  }

  Future<void> toggleFavorite(int id) async {
    try {
      await _databaseService.toggleFavorite(id);
      // Reload passwords after toggle
      await loadPasswords();
    } catch (e) {
      emit(PasswordsError(e.toString()));
    }
  }

  Future<List<PasswordModel>> getFavoritePasswords() async {
    try {
      return await _databaseService.getFavoritePasswords();
    } catch (e) {
      emit(PasswordsError(e.toString()));
      return [];
    }
  }

  Future<Map<String, dynamic>> getPasswordStatistics() async {
    try {
      return await _databaseService.getPasswordStatistics();
    } catch (e) {
      emit(PasswordsError(e.toString()));
      return {
        'totalCount': 0,
        'favoriteCount': 0,
        'categoryCounts': [],
        'uncategorizedCount': 0,
      };
    }
  }
}