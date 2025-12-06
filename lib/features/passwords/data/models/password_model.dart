class IbanEntry {
  final String iban;
  final String? name;

  IbanEntry({
    required this.iban,
    this.name,
  });

  Map<String, String> toMap() {
    return {
      'iban': iban,
      'name': name ?? '',
    };
  }

  static IbanEntry fromMap(Map<String, String> map) {
    return IbanEntry(
      iban: map['iban']!,
      name: map['name']!.isEmpty ? null : map['name'],
    );
  }

  String toStorageString() {
    return '${iban}::${name ?? ''}';
  }

  static IbanEntry fromStorageString(String str) {
    final parts = str.split('::');
    return IbanEntry(
      iban: parts[0],
      name: parts.length > 1 && parts[1].isNotEmpty ? parts[1] : null,
    );
  }
}

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
  bool isFavorite;
  
  // Banking-specific fields (optional)
  String? cardHolderName;
  String? cardNumber;
  List<IbanEntry>? ibanNumbers;
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
    this.isFavorite = false,
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
      'isFavorite': isFavorite ? 1 : 0,
      'cardHolderName': cardHolderName,
      'cardNumber': cardNumber,
      'ibanNumbers': ibanNumbers != null 
          ? ibanNumbers!.map((e) => e.toStorageString()).join('|||') 
          : null,
      'expiryDate': expiryDate,
      'cvv': cvv,
    };
  }

  // Create from Map for SQLite
  static PasswordModel fromMap(Map<String, dynamic> map) {
    final ibanString = map['ibanNumbers'] as String?;
    
    // Debug log to check banking fields
    if (map['cardHolderName'] != null || map['cardNumber'] != null || 
        map['ibanNumbers'] != null || map['expiryDate'] != null || map['cvv'] != null) {
      print('📋 Loading password "${map['title']}" with banking data:');
      print('  - Card Holder: ${map['cardHolderName']}');
      print('  - Card Number: ${map['cardNumber']}');
      print('  - IBAN String: ${map['ibanNumbers']}');
      print('  - Expiry: ${map['expiryDate']}');
      print('  - CVV: ${map['cvv']}');
    }
    
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
      isFavorite: (map['isFavorite'] as int? ?? 0) == 1,
      cardHolderName: map['cardHolderName'] as String?,
      cardNumber: map['cardNumber'] as String?,
      ibanNumbers: ibanString != null && ibanString.isNotEmpty 
          ? ibanString.split('|||').map((str) {
              // Backward compatibility: if no '::' separator, treat as old format
              if (!str.contains('::')) {
                return IbanEntry(iban: str, name: null);
              }
              return IbanEntry.fromStorageString(str);
            }).toList()
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
    bool? isFavorite,
    String? cardHolderName,
    String? cardNumber,
    List<IbanEntry>? ibanNumbers,
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
      isFavorite: isFavorite ?? this.isFavorite,
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