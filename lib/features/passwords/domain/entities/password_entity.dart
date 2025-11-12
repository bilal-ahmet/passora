import 'package:equatable/equatable.dart';

class PasswordEntity extends Equatable {
  final String id;
  final String title;
  final String username;
  final String email;
  final String password;
  final String website;
  final String notes;
  final PasswordCategory category;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastAccessed;

  const PasswordEntity({
    required this.id,
    required this.title,
    required this.username,
    required this.email,
    required this.password,
    required this.website,
    required this.notes,
    required this.category,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
    this.lastAccessed,
  });

  PasswordEntity copyWith({
    String? id,
    String? title,
    String? username,
    String? email,
    String? password,
    String? website,
    String? notes,
    PasswordCategory? category,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastAccessed,
  }) {
    return PasswordEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      website: website ?? this.website,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastAccessed: lastAccessed ?? this.lastAccessed,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        username,
        email,
        password,
        website,
        notes,
        category,
        isFavorite,
        createdAt,
        updatedAt,
        lastAccessed,
      ];
}

enum PasswordCategory {
  social,
  banking,
  email,
  shopping,
  work,
  entertainment,
  other,
}

extension PasswordCategoryExtension on PasswordCategory {
  String get displayName {
    switch (this) {
      case PasswordCategory.social:
        return 'Social';
      case PasswordCategory.banking:
        return 'Banking';
      case PasswordCategory.email:
        return 'Email';
      case PasswordCategory.shopping:
        return 'Shopping';
      case PasswordCategory.work:
        return 'Work';
      case PasswordCategory.entertainment:
        return 'Entertainment';
      case PasswordCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case PasswordCategory.social:
        return '👥';
      case PasswordCategory.banking:
        return '🏦';
      case PasswordCategory.email:
        return '📧';
      case PasswordCategory.shopping:
        return '🛒';
      case PasswordCategory.work:
        return '💼';
      case PasswordCategory.entertainment:
        return '🎬';
      case PasswordCategory.other:
        return '📁';
    }
  }
}