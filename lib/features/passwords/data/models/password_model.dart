class PasswordModel {
  int? id;
  String title;
  String username;
  String password;
  String? website;
  String? notes;
  int? categoryId;
  DateTime createdAt;
  DateTime updatedAt;
  
  // Banking-specific fields (optional)
  String? cardHolderName;
  String? cardNumber;
  List<String>? ibanNumbers;
  String? expiryDate; // Format: MM/YY
  String? cvv;

  PasswordModel({
    this.id,
    required this.title,
    required this.username,
    required this.password,
    this.website,
    this.notes,
    this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.cardHolderName,
    this.cardNumber,
    this.ibanNumbers,
    this.expiryDate,
    this.cvv,
  });

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
      'website': website,
      'notes': notes,
      'categoryId': categoryId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'cardHolderName': cardHolderName,
      'cardNumber': cardNumber,
      'ibanNumbers': ibanNumbers != null ? ibanNumbers!.join('|||') : null, // Store as delimited string
      'expiryDate': expiryDate,
      'cvv': cvv,
    };
  }

  // Create from Map for SQLite
  static PasswordModel fromMap(Map<String, dynamic> map) {
    final ibanString = map['ibanNumbers'] as String?;
    return PasswordModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      website: map['website'] as String?,
      notes: map['notes'] as String?,
      categoryId: map['categoryId'] as int?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      cardHolderName: map['cardHolderName'] as String?,
      cardNumber: map['cardNumber'] as String?,
      ibanNumbers: ibanString != null && ibanString.isNotEmpty 
          ? ibanString.split('|||') 
          : null,
      expiryDate: map['expiryDate'] as String?,
      cvv: map['cvv'] as String?,
    );
  }

  // Copy with method
  PasswordModel copyWith({
    int? id,
    String? title,
    String? username,
    String? password,
    String? website,
    String? notes,
    int? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? cardHolderName,
    String? cardNumber,
    List<String>? ibanNumbers,
    String? expiryDate,
    String? cvv,
  }) {
    return PasswordModel(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      website: website ?? this.website,
      notes: notes ?? this.notes,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardNumber: cardNumber ?? this.cardNumber,
      ibanNumbers: ibanNumbers ?? this.ibanNumbers,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
    );
  }
}

enum PasswordCategoryEnum {
  social,
  banking,
  email,
  shopping,
  work,
  entertainment,
  other,
}

extension PasswordCategoryEnumExtension on PasswordCategoryEnum {
  String get displayName {
    switch (this) {
      case PasswordCategoryEnum.social:
        return 'Social';
      case PasswordCategoryEnum.banking:
        return 'Banking';
      case PasswordCategoryEnum.email:
        return 'Email';
      case PasswordCategoryEnum.shopping:
        return 'Shopping';
      case PasswordCategoryEnum.work:
        return 'Work';
      case PasswordCategoryEnum.entertainment:
        return 'Entertainment';
      case PasswordCategoryEnum.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case PasswordCategoryEnum.social:
        return '👥';
      case PasswordCategoryEnum.banking:
        return '🏦';
      case PasswordCategoryEnum.email:
        return '📧';
      case PasswordCategoryEnum.shopping:
        return '🛒';
      case PasswordCategoryEnum.work:
        return '💼';
      case PasswordCategoryEnum.entertainment:
        return '🎬';
      case PasswordCategoryEnum.other:
        return '📁';
    }
  }
}