import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/database_service.dart';
import '../../data/models/category_model.dart';

// States
abstract class CategoriesState {}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<CategoryModel> categories;
  
  CategoriesLoaded(this.categories);
}

class CategoriesError extends CategoriesState {
  final String message;
  
  CategoriesError(this.message);
}

class CategorySaved extends CategoriesState {}

class CategoryDeleted extends CategoriesState {}

// Cubit
class CategoriesCubit extends Cubit<CategoriesState> {
  final DatabaseService _databaseService;

  CategoriesCubit(this._databaseService) : super(CategoriesInitial());

  /// Load all categories
  Future<void> loadCategories() async {
    try {
      emit(CategoriesLoading());
      final categories = await _databaseService.getAllCategories();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }

  /// Save a category (create or update)
  Future<void> saveCategory(CategoryModel category) async {
    try {
      await _databaseService.saveCategory(category);
      emit(CategorySaved());
      await loadCategories(); // Reload categories
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }

  /// Delete a category
  Future<void> deleteCategory(int id) async {
    try {
      await _databaseService.deleteCategory(id);
      emit(CategoryDeleted());
      await loadCategories(); // Reload categories
    } catch (e) {
      // Extract just the error message without "Exception: " prefix
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring('Exception: '.length);
      }
      if (errorMessage.startsWith('Failed to delete category: Exception: ')) {
        errorMessage = errorMessage.substring('Failed to delete category: Exception: '.length);
      }
      emit(CategoriesError(errorMessage));
    }
  }

  /// Get category by id
  Future<CategoryModel?> getCategoryById(int id) async {
    try {
      return await _databaseService.getCategoryById(id);
    } catch (e) {
      emit(CategoriesError(e.toString()));
      return null;
    }
  }
}