import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/passwords/data/models/password_model.dart';
import '../../features/categories/data/models/category_model.dart';
import '../../features/settings/data/models/settings_model.dart';
import '../utils/encryption_service.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();
  DatabaseService._();

  Database? _database;
  bool _bypassMode = false;
  String? _currentMasterPassword; // Store current session's master password

  /// Initialize the database
  Future<void> initialize() async {
    if (_database != null) return;

    try {
      // Initialize sqflite_ffi for desktop platforms (Windows, Linux, macOS)
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'passora.db');
      
      _database = await openDatabase(
        path,
        version: 7,
        onCreate: _createDb,
        onUpgrade: _upgradeDb,
      );
    } catch (e) {
      throw Exception('Failed to initialize database: $e');
    }
  }

  Future<void> _createDb(Database db, int version) async {
    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        isDefault INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // Create passwords table with categoryId
    await db.execute('''
      CREATE TABLE passwords (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        website TEXT,
        notes TEXT,
        categoryId INTEGER,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        cardHolderName TEXT,
        cardNumber TEXT,
        ibanNumbers TEXT,
        expiryDate TEXT,
        cvv TEXT,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
    
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        autoLockEnabled INTEGER NOT NULL DEFAULT 1,
        autoLockDuration INTEGER NOT NULL DEFAULT 5,
        themeMode TEXT NOT NULL DEFAULT 'system',
        masterPasswordEnabled INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Create master password table
    await db.execute('''
      CREATE TABLE master_password (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        passwordHash TEXT NOT NULL,
        salt TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add categories table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          icon TEXT NOT NULL,
          color TEXT NOT NULL,
          isDefault INTEGER NOT NULL DEFAULT 0,
          createdAt INTEGER NOT NULL,
          updatedAt INTEGER NOT NULL
        )
      ''');

      // Add categoryId column to passwords table
      await db.execute('''
        ALTER TABLE passwords ADD COLUMN categoryId INTEGER
      ''');

      // Insert default categories
      await _insertDefaultCategories(db);
    }
    
    if (oldVersion < 3) {
      // Create master password table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS master_password (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          passwordHash TEXT NOT NULL,
          salt TEXT NOT NULL,
          createdAt INTEGER NOT NULL,
          updatedAt INTEGER NOT NULL
        )
      ''');
    }
    
    if (oldVersion < 4) {
      // Fix master_password table column names if they were created incorrectly
      await db.execute('DROP TABLE IF EXISTS master_password');
      await db.execute('''
        CREATE TABLE master_password (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          passwordHash TEXT NOT NULL,
          salt TEXT NOT NULL,
          createdAt INTEGER NOT NULL,
          updatedAt INTEGER NOT NULL
        )
      ''');
    }
    
    if (oldVersion < 5) {
      // Add masterPasswordEnabled column to settings table if it doesn't exist
      try {
        await db.execute('ALTER TABLE settings ADD COLUMN masterPasswordEnabled INTEGER NOT NULL DEFAULT 1');
      } catch (e) {
        // Column might already exist, ignore error
        print('masterPasswordEnabled column might already exist: $e');
      }
    }
    
    if (oldVersion < 6) {
      // Update categories: Remove old default categories and add new simplified ones
      // Also make all categories deletable (isDefault = 0)
      try {
        // Delete all existing categories
        await db.delete('categories');
        
        // Insert new simplified default categories (all deletable)
        final now = DateTime.now();
        final newCategories = [
          {
            'name': 'Bankacılık',
            'icon': '🏦',
            'color': '#34A853',
            'isDefault': 0,
            'createdAt': now.millisecondsSinceEpoch,
            'updatedAt': now.millisecondsSinceEpoch,
          },
          {
            'name': 'E-posta',
            'icon': '📧',
            'color': '#EA4335',
            'isDefault': 0,
            'createdAt': now.millisecondsSinceEpoch,
            'updatedAt': now.millisecondsSinceEpoch,
          },
          {
            'name': 'Sosyal',
            'icon': '👥',
            'color': '#1DA1F2',
            'isDefault': 0,
            'createdAt': now.millisecondsSinceEpoch,
            'updatedAt': now.millisecondsSinceEpoch,
          },
          {
            'name': 'Alışveriş',
            'icon': '🛒',
            'color': '#FF9800',
            'isDefault': 0,
            'createdAt': now.millisecondsSinceEpoch,
            'updatedAt': now.millisecondsSinceEpoch,
          },
        ];
        
        for (final category in newCategories) {
          await db.insert('categories', category);
        }
        
        print('Categories updated to new simplified list (all deletable)');
      } catch (e) {
        print('Error updating categories: $e');
      }
    }
    
    if (oldVersion < 7) {
      // Add banking-specific fields to passwords table
      try {
        await db.execute('ALTER TABLE passwords ADD COLUMN cardHolderName TEXT');
        await db.execute('ALTER TABLE passwords ADD COLUMN cardNumber TEXT');
        await db.execute('ALTER TABLE passwords ADD COLUMN ibanNumbers TEXT');
        await db.execute('ALTER TABLE passwords ADD COLUMN expiryDate TEXT');
        await db.execute('ALTER TABLE passwords ADD COLUMN cvv TEXT');
        print('Banking fields added to passwords table');
      } catch (e) {
        print('Error adding banking fields: $e');
      }
    }
  }

  /// Set bypass mode (for when master password is disabled)
  Future<void> setBypassMode(bool enabled) async {
    _bypassMode = enabled;
    _currentMasterPassword = null; // Clear session password
    if (enabled) {
      // Initialize with default key for bypass mode
      EncryptionService.initializeWithDefaultKey();
    }
  }

  /// Check if in bypass mode
  bool get isInBypassMode => _bypassMode;
  
  /// Set current session master password (for re-encryption)
  void setSessionMasterPassword(String password) {
    _currentMasterPassword = password;
  }
  
  /// Get current session master password
  String? get sessionMasterPassword => _currentMasterPassword;

  /// Re-encrypt all passwords for bypass mode (using default key)
  Future<void> reencryptPasswordsForBypass(String masterPassword) async {
    await _ensureInitialized();
    
    try {
      print('[RE-ENCRYPT BYPASS] Starting re-encryption for bypass mode...');
      
      // Verify master password first
      final isValid = await verifyMasterPassword(masterPassword);
      if (!isValid) {
        throw Exception('Invalid master password');
      }
      print('[RE-ENCRYPT BYPASS] Master password verified');
      
      // Get all passwords with current encryption
      final List<Map<String, dynamic>> maps = await _database!.query('passwords');
      print('[RE-ENCRYPT BYPASS] Found ${maps.length} passwords to re-encrypt');
      
      if (maps.isEmpty) {
        print('[RE-ENCRYPT BYPASS] No passwords found, skipping re-encryption');
        _bypassMode = true;
        _currentMasterPassword = null;
        return;
      }
      
      // Initialize encryption with master password for decryption
      final salt = await getSalt();
      print('[RE-ENCRYPT BYPASS] Using salt: ${salt.substring(0, 10)}...');
      final masterEncryption = EncryptionService.fromMasterPassword(masterPassword, salt);
      
      // Initialize default encryption for re-encryption
      EncryptionService.initializeWithDefaultKey();
      final defaultEncryption = EncryptionService.instance;
      print('[RE-ENCRYPT BYPASS] Initialized default encryption');
      
      int successCount = 0;
      int failCount = 0;
      
      // Re-encrypt each password
      for (final map in maps) {
        try {
          final passwordId = map['id'];
          final encryptedPassword = map['password'] as String;
          
          // Decrypt with master password encryption
          String decryptedPassword;
          try {
            decryptedPassword = masterEncryption.decrypt(encryptedPassword);
            print('[RE-ENCRYPT BYPASS] Decrypted password ID $passwordId (length: ${decryptedPassword.length})');
          } catch (e) {
            print('[RE-ENCRYPT BYPASS] ERROR: Could not decrypt password ID $passwordId: $e');
            failCount++;
            continue;
          }
          
          // Re-encrypt with default key
          final newEncryptedPassword = defaultEncryption.encrypt(decryptedPassword);
          print('[RE-ENCRYPT BYPASS] Re-encrypted password ID $passwordId');
          
          // Update database
          await _database!.update(
            'passwords',
            {'password': newEncryptedPassword},
            where: 'id = ?',
            whereArgs: [passwordId],
          );
          print('[RE-ENCRYPT BYPASS] Updated password ID $passwordId in database');
          successCount++;
        } catch (e) {
          print('[RE-ENCRYPT BYPASS] ERROR: Failed to re-encrypt password: $e');
          failCount++;
        }
      }
      
      print('[RE-ENCRYPT BYPASS] Re-encryption complete: $successCount success, $failCount failed');
      
      // Keep default encryption active for bypass mode
      _bypassMode = true;
      _currentMasterPassword = null;
      print('[RE-ENCRYPT BYPASS] Bypass mode activated');
    } catch (e) {
      print('[RE-ENCRYPT BYPASS] FATAL ERROR: $e');
      throw Exception('Failed to re-encrypt passwords for bypass: $e');
    }
  }

  /// Re-encrypt all passwords with master password
  Future<void> reencryptPasswordsForMasterPassword(String masterPassword) async {
    await _ensureInitialized();
    
    try {
      print('[RE-ENCRYPT MASTER] Starting re-encryption with master password...');
      
      // Verify master password first
      final isValid = await verifyMasterPassword(masterPassword);
      if (!isValid) {
        throw Exception('Invalid master password');
      }
      print('[RE-ENCRYPT MASTER] Master password verified');
      
      // Get all passwords with current encryption
      final List<Map<String, dynamic>> maps = await _database!.query('passwords');
      print('[RE-ENCRYPT MASTER] Found ${maps.length} passwords to re-encrypt');
      
      if (maps.isEmpty) {
        print('[RE-ENCRYPT MASTER] No passwords found, skipping re-encryption');
        _bypassMode = false;
        _currentMasterPassword = masterPassword;
        return;
      }
      
      // Initialize default encryption for decryption (current state is bypass mode)
      EncryptionService.initializeWithDefaultKey();
      final defaultEncryption = EncryptionService.instance;
      print('[RE-ENCRYPT MASTER] Initialized default encryption for decryption');
      
      // Initialize master password encryption for re-encryption
      final salt = await getSalt();
      print('[RE-ENCRYPT MASTER] Using salt: ${salt.substring(0, 10)}...');
      EncryptionService.initialize(masterPassword, salt);
      final masterEncryption = EncryptionService.instance;
      print('[RE-ENCRYPT MASTER] Initialized master password encryption');
      
      int successCount = 0;
      int failCount = 0;
      
      // Re-encrypt each password
      for (final map in maps) {
        try {
          final passwordId = map['id'];
          final encryptedPassword = map['password'] as String;
          
          // Decrypt with default key
          String decryptedPassword;
          try {
            decryptedPassword = defaultEncryption.decrypt(encryptedPassword);
            print('[RE-ENCRYPT MASTER] Decrypted password ID $passwordId (length: ${decryptedPassword.length})');
          } catch (e) {
            print('[RE-ENCRYPT MASTER] ERROR: Could not decrypt password ID $passwordId: $e');
            failCount++;
            continue;
          }
          
          // Re-encrypt with master password
          final newEncryptedPassword = masterEncryption.encrypt(decryptedPassword);
          print('[RE-ENCRYPT MASTER] Re-encrypted password ID $passwordId');
          
          // Update database
          await _database!.update(
            'passwords',
            {'password': newEncryptedPassword},
            where: 'id = ?',
            whereArgs: [passwordId],
          );
          print('[RE-ENCRYPT MASTER] Updated password ID $passwordId in database');
          successCount++;
        } catch (e) {
          print('[RE-ENCRYPT MASTER] ERROR: Failed to re-encrypt password: $e');
          failCount++;
        }
      }
      
      print('[RE-ENCRYPT MASTER] Re-encryption complete: $successCount success, $failCount failed');
      
      // Keep master password encryption active
      _bypassMode = false;
      _currentMasterPassword = masterPassword;
      print('[RE-ENCRYPT MASTER] Master password mode activated');
    } catch (e) {
      print('[RE-ENCRYPT MASTER] FATAL ERROR: $e');
      throw Exception('Failed to re-encrypt passwords with master password: $e');
    }
  }

  /// Close the database
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<void> _ensureInitialized() async {
    if (_database == null) {
      await initialize();
    }
  }

  EncryptionService _getEncryptionService() {
    // Her zaman mevcut EncryptionService instance'ını kullan
    // Bu, bypass mode veya master password mode'a göre doğru key'i kullanacak
    return EncryptionService.instance;
  }

  // Password CRUD Operations
  
  /// Get all passwords
  Future<List<PasswordModel>> getAllPasswords() async {
    await _ensureInitialized();
    
    try {
      final List<Map<String, dynamic>> maps = await _database!.query('passwords');
      
      final passwords = <PasswordModel>[];
      for (final map in maps) {
        final password = PasswordModel.fromMap(map);
        try {
          // Decrypt password
          password.password = _getEncryptionService().decrypt(password.password);
          passwords.add(password);
        } catch (decryptionError) {
          print('Debug: Failed to decrypt password with ID ${password.id}: $decryptionError');
          // Skip corrupted entries or handle encryption mismatch
          continue;
        }
      }
      
      return passwords;
    } catch (e) {
      print('Debug: Database error in getAllPasswords: $e');
      // If it's an encryption-related error, check for corruption
      if (e.toString().contains('decrypt') || e.toString().contains('encryption')) {
        return await _handleEncryptionCorruption();
      }
      throw Exception('Failed to get passwords: $e');
    }
  }

  /// Handle encryption corruption by clearing corrupted data
  Future<List<PasswordModel>> _handleEncryptionCorruption() async {
    try {
      print('Debug: Detected encryption corruption, checking master password...');
      
      // Check if master password exists
      final hasMP = await masterPasswordExists();
      if (!hasMP) {
        print('Debug: No master password found, clearing corrupted password data...');
        // Clear corrupted password data
        await _database!.delete('passwords');
        return <PasswordModel>[];
      }
      
      // If master password exists but decryption fails, there might be individual corruption
      print('Debug: Master password exists but decryption failed, removing corrupted entries...');
      
      final List<Map<String, dynamic>> maps = await _database!.query('passwords');
      final List<int> corruptedIds = [];
      final List<PasswordModel> validPasswords = [];
      
      for (final map in maps) {
        final password = PasswordModel.fromMap(map);
        try {
          password.password = _getEncryptionService().decrypt(password.password);
          validPasswords.add(password);
        } catch (e) {
          print('Debug: Password ID ${password.id} is corrupted, will be removed');
          if (password.id != null) {
            corruptedIds.add(password.id!);
          }
        }
      }
      
      // Remove corrupted entries
      for (final id in corruptedIds) {
        await _database!.delete('passwords', where: 'id = ?', whereArgs: [id]);
        print('Debug: Removed corrupted password with ID $id');
      }
      
      return validPasswords;
    } catch (e) {
      print('Debug: Error in corruption handling: $e');
      return <PasswordModel>[];
    }
  }

  /// Get password by ID
  Future<PasswordModel?> getPasswordById(int id) async {
    await _ensureInitialized();
    
    try {
      final List<Map<String, dynamic>> maps = await _database!.query(
        'passwords',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isNotEmpty) {
        final password = PasswordModel.fromMap(maps.first);
        try {
          // Decrypt password
          password.password = _getEncryptionService().decrypt(password.password);
          return password;
        } catch (decryptionError) {
          print('Debug: Failed to decrypt password with ID $id: $decryptionError');
          // Remove corrupted entry and return null
          await _database!.delete('passwords', where: 'id = ?', whereArgs: [id]);
          print('Debug: Removed corrupted password with ID $id');
          return null;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get password: $e');
    }
  }

  /// Save password (create or update)
  Future<int> savePassword(PasswordModel password) async {
    await _ensureInitialized();
    
    try {
      // Encrypt password before saving
      final encryptedPassword = PasswordModel(
        id: password.id,
        title: password.title,
        username: password.username,
        password: _getEncryptionService().encrypt(password.password),
        website: password.website,
        notes: password.notes,
        categoryId: password.categoryId,
        createdAt: password.createdAt,
        updatedAt: DateTime.now(),
      );
      
      if (password.id == null) {
        // Insert new password
        final id = await _database!.insert('passwords', encryptedPassword.toMap());
        return id;
      } else {
        // Update existing password
        await _database!.update(
          'passwords',
          encryptedPassword.toMap(),
          where: 'id = ?',
          whereArgs: [password.id],
        );
        return password.id!;
      }
    } catch (e) {
      throw Exception('Failed to save password: $e');
    }
  }

  /// Delete password
  Future<void> deletePassword(int id) async {
    await _ensureInitialized();
    
    try {
      await _database!.delete(
        'passwords',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete password: $e');
    }
  }

  /// Search passwords
  Future<List<PasswordModel>> searchPasswords(String query) async {
    await _ensureInitialized();
    
    if (query.isEmpty) {
      return getAllPasswords();
    }
    
    try {
      final List<Map<String, dynamic>> maps = await _database!.query(
        'passwords',
        where: 'title LIKE ? OR username LIKE ? OR website LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
      );
      
      final passwords = <PasswordModel>[];
      for (final map in maps) {
        final password = PasswordModel.fromMap(map);
        try {
          // Decrypt password
          password.password = _getEncryptionService().decrypt(password.password);
          passwords.add(password);
        } catch (decryptionError) {
          print('Debug: Failed to decrypt password with ID ${password.id} during search: $decryptionError');
          // Skip corrupted entries
          continue;
        }
      }
      
      return passwords;
    } catch (e) {
      throw Exception('Failed to search passwords: $e');
    }
  }

  // Settings Operations

  /// Get settings
  Future<SettingsModel> getSettings() async {
    await _ensureInitialized();
    
    try {
      final List<Map<String, dynamic>> maps = await _database!.query('settings');
      
      if (maps.isEmpty) {
        // Create default settings
        final settings = SettingsModel(
          autoLockEnabled: true,
          autoLockDuration: 5,
          themeMode: 'system',
          masterPasswordEnabled: true, // Default olarak master password etkin
        );
        
        await _database!.insert('settings', settings.toMap());
        return settings;
      }
      
      return SettingsModel.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to get settings: $e');
    }
  }

  /// Save settings
  Future<void> saveSettings(SettingsModel settings) async {
    await _ensureInitialized();
    
    try {
      final existing = await _database!.query('settings');
      if (existing.isEmpty) {
        await _database!.insert('settings', settings.toMap());
      } else {
        await _database!.update(
          'settings',
          settings.toMap(),
          where: 'id = ?',
          whereArgs: [existing.first['id']],
        );
      }
    } catch (e) {
      throw Exception('Failed to save settings: $e');
    }
  }

  /// Update specific settings
  Future<void> updateSettings({
    bool? autoLockEnabled,
    int? autoLockDuration,
    String? themeMode,
    bool? masterPasswordEnabled,
  }) async {
    await _ensureInitialized();
    
    try {
      // Get current settings
      final currentSettings = await getSettings();
      
      // Create updated settings
      final updatedSettings = currentSettings.copyWith(
        autoLockEnabled: autoLockEnabled,
        autoLockDuration: autoLockDuration,
        themeMode: themeMode,
        masterPasswordEnabled: masterPasswordEnabled,
      );
      
      // Save updated settings
      await saveSettings(updatedSettings);
    } catch (e) {
      throw Exception('Failed to update settings: $e');
    }
  }

  // Import/Export Operations

  // Master Password Operations

  /// Check if master password exists
  Future<bool> masterPasswordExists() async {
    await _ensureInitialized();
    
    try {
      final List<Map<String, dynamic>> maps = await _database!.query('master_password');
      return maps.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Save master password with salt
  Future<void> saveMasterPassword(String password) async {
    await _ensureInitialized();
    
    try {
      final salt = EncryptionService.generateSalt();
      final passwordHash = EncryptionService.hashMasterPassword(password, salt);
      
      final data = {
        'passwordHash': passwordHash,
        'salt': salt,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };
      
      // Delete existing master password if any
      await _database!.delete('master_password');
      
      // Insert new master password
      await _database!.insert('master_password', data);
      print('Master password saved successfully'); // Debug logging
    } catch (e) {
      print('Database error saving master password: $e'); // Debug logging
      throw Exception('Failed to save master password: $e');
    }
  }

  /// Verify master password
  Future<bool> verifyMasterPassword(String password) async {
    await _ensureInitialized();
    
    try {
      final List<Map<String, dynamic>> maps = await _database!.query('master_password');
      
      if (maps.isEmpty) {
        return false;
      }
      
      final stored = maps.first;
      final salt = stored['salt'] as String;
      final storedHash = stored['passwordHash'] as String;
      
      return EncryptionService.verifyMasterPassword(password, salt, storedHash);
    } catch (e) {
      return false;
    }
  }

  /// Get salt for encryption
  Future<String> getSalt() async {
    await _ensureInitialized();
    
    try {
      final List<Map<String, dynamic>> maps = await _database!.query('master_password');
      
      if (maps.isEmpty) {
        throw Exception('No master password found');
      }
      
      return maps.first['salt'] as String;
    } catch (e) {
      throw Exception('Failed to get salt: $e');
    }
  }

  /// Change master password
  Future<void> changeMasterPassword(String currentPassword, String newPassword) async {
    await _ensureInitialized();
    
    try {
      // First verify the current password
      final isValid = await verifyMasterPassword(currentPassword);
      if (!isValid) {
        throw Exception('Current password is incorrect');
      }

      // Generate new salt and hash for new password
      final newSalt = EncryptionService.generateSalt();
      final newPasswordHash = EncryptionService.hashMasterPassword(newPassword, newSalt);

      // Get old salt for re-encryption
      final oldSalt = await getSalt();

      // Update master_password table
      await _database!.update(
        'master_password',
        {
          'passwordHash': newPasswordHash,
          'salt': newSalt,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = 1',
      );

      // Re-encrypt all passwords with new master password
      await _reencryptAllPasswords(currentPassword, newPassword, oldSalt, newSalt);

      // Initialize EncryptionService with new password
      EncryptionService.initialize(newPassword, newSalt);

      print('Debug: Master password changed successfully');
    } catch (e) {
      print('Debug: Failed to change master password: $e');
      throw Exception('Failed to change master password: $e');
    }
  }

  /// Re-encrypt all passwords with new master password
  Future<void> _reencryptAllPasswords(String oldPassword, String newPassword, String oldSalt, String newSalt) async {
    try {
      // Initialize old encryption service to decrypt existing passwords
      EncryptionService.initialize(oldPassword, oldSalt);
      final oldEncryptionService = EncryptionService.instance;

      // Get all encrypted passwords from database
      final List<Map<String, dynamic>> maps = await _database!.query('passwords');

      // Initialize new encryption service
      EncryptionService.initialize(newPassword, newSalt);
      final newEncryptionService = EncryptionService.instance;

      // Re-encrypt each password
      for (final map in maps) {
        final encryptedPassword = map['password'] as String;
        
        // Decrypt with old password
        final decryptedPassword = oldEncryptionService.decrypt(encryptedPassword);
        
        // Encrypt with new password
        final newEncryptedPassword = newEncryptionService.encrypt(decryptedPassword);

        // Update in database
        await _database!.update(
          'passwords',
          {'password': newEncryptedPassword},
          where: 'id = ?',
          whereArgs: [map['id']],
        );
      }

      print('Debug: Re-encrypted ${maps.length} passwords');
    } catch (e) {
      print('Debug: Failed to re-encrypt passwords: $e');
      throw Exception('Failed to re-encrypt passwords: $e');
    }
  }

  /// Export passwords to JSON
  Future<String> exportPasswords() async {
    await _ensureInitialized();
    
    try {
      final passwords = await getAllPasswords();
      
      final exportData = {
        'app': 'Passora',
        'version': '1.0.0',
        'exported_at': DateTime.now().toIso8601String(),
        'passwords': passwords.map((p) => {
          'title': p.title,
          'username': p.username,
          'password': p.password, // Already decrypted
          'website': p.website,
          'notes': p.notes,
          'created_at': p.createdAt.toIso8601String(),
          'updated_at': p.updatedAt.toIso8601String(),
        }).toList(),
      };
      
      return jsonEncode(exportData);
    } catch (e) {
      throw Exception('Failed to export passwords: $e');
    }
  }

  /// Share export file
  Future<void> shareExport() async {
    try {
      final exportData = await exportPasswords();
      
      // Create temporary file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/passora_export_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(exportData);
      
      // Share file
      await Share.shareXFiles([XFile(file.path)], text: 'Passora Password Export');
    } catch (e) {
      throw Exception('Failed to share export: $e');
    }
  }

  /// Import passwords from JSON
  Future<int> importPasswords(String jsonData) async {
    await _ensureInitialized();
    
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      final passwordsList = data['passwords'] as List<dynamic>;
      
      int importedCount = 0;
      
      for (final passwordData in passwordsList) {
        final password = PasswordModel(
          title: passwordData['title'] as String,
          username: passwordData['username'] as String,
          password: passwordData['password'] as String,
          website: passwordData['website'] as String?,
          notes: passwordData['notes'] as String?,
          createdAt: DateTime.parse(passwordData['created_at'] as String),
          updatedAt: DateTime.parse(passwordData['updated_at'] as String),
        );
        
        await savePassword(password);
        importedCount++;
      }
      
      return importedCount;
    } catch (e) {
      throw Exception('Failed to import passwords: $e');
    }
  }

  /// Clear all data
  Future<void> clearAllData() async {
    await _ensureInitialized();
    
    try {
      await _database!.delete('passwords');
      await _database!.delete('settings');
    } catch (e) {
      throw Exception('Failed to clear data: $e');
    }
  }

  /// Get database statistics
  Future<Map<String, dynamic>> getStatistics() async {
    await _ensureInitialized();
    
    try {
      final passwordCount = Sqflite.firstIntValue(
        await _database!.rawQuery('SELECT COUNT(*) FROM passwords')
      ) ?? 0;
      
      final oldestPassword = await _database!.query(
        'passwords',
        orderBy: 'createdAt ASC',
        limit: 1,
      );
      
      final newestPassword = await _database!.query(
        'passwords',
        orderBy: 'createdAt DESC',
        limit: 1,
      );
      
      return {
        'total_passwords': passwordCount,
        'oldest_password': oldestPassword.isNotEmpty 
          ? DateTime.fromMillisecondsSinceEpoch(oldestPassword.first['createdAt'] as int)
          : null,
        'newest_password': newestPassword.isNotEmpty 
          ? DateTime.fromMillisecondsSinceEpoch(newestPassword.first['createdAt'] as int)
          : null,
      };
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  /// Insert default categories when database is created
  Future<void> _insertDefaultCategories(Database db) async {
    final now = DateTime.now();
    final defaultCategories = [
      {
        'name': 'Bankacılık',
        'icon': '🏦',
        'color': '#34A853',
        'isDefault': 0, // Changed to 0 so they can be deleted
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
      },
      {
        'name': 'E-posta',
        'icon': '📧',
        'color': '#EA4335',
        'isDefault': 0, // Changed to 0 so they can be deleted
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
      },
      {
        'name': 'Sosyal',
        'icon': '�',
        'color': '#1DA1F2',
        'isDefault': 0, // Changed to 0 so they can be deleted
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
      },
      {
        'name': 'Alışveriş',
        'icon': '🛒',
        'color': '#FF9800',
        'isDefault': 0, // Changed to 0 so they can be deleted
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
      },
    ];

    for (final category in defaultCategories) {
      await db.insert('categories', category);
    }
  }

  // ============ CATEGORY OPERATIONS ============

  /// Get all categories
  Future<List<CategoryModel>> getAllCategories() async {
    await initialize();
    try {
      final maps = await _database!.query(
        'categories',
        orderBy: 'isDefault DESC, name ASC',
      );
      return maps.map((map) => CategoryModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  /// Save a category
  Future<int> saveCategory(CategoryModel category) async {
    await initialize();
    try {
      if (category.id != null) {
        // Update existing category
        final updatedCategory = category.copyWith(updatedAt: DateTime.now());
        await _database!.update(
          'categories',
          updatedCategory.toMap(),
          where: 'id = ?',
          whereArgs: [category.id],
        );
        return category.id!;
      } else {
        // Insert new category
        final id = await _database!.insert('categories', category.toMap());
        return id;
      }
    } catch (e) {
      throw Exception('Failed to save category: $e');
    }
  }

  /// Delete a category
  Future<void> deleteCategory(int id) async {
    await initialize();
    try {
      // Check if category is default
      final category = await _database!.query(
        'categories',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (category.isNotEmpty && category.first['isDefault'] == 1) {
        throw Exception('Cannot delete default category');
      }

      // Update passwords that use this category to null
      await _database!.update(
        'passwords',
        {'categoryId': null},
        where: 'categoryId = ?',
        whereArgs: [id],
      );

      // Delete the category
      await _database!.delete(
        'categories',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  /// Get category by id
  Future<CategoryModel?> getCategoryById(int id) async {
    await initialize();
    try {
      final maps = await _database!.query(
        'categories',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return CategoryModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get category: $e');
    }
  }

  /// Get passwords by category
  Future<List<PasswordModel>> getPasswordsByCategory(int categoryId) async {
    await initialize();
    try {
      final maps = await _database!.query(
        'passwords',
        where: 'categoryId = ?',
        whereArgs: [categoryId],
        orderBy: 'updatedAt DESC',
      );

      final List<PasswordModel> passwords = [];
      for (final map in maps) {
        try {
          final decryptedPassword = _getEncryptionService().decrypt(map['password'] as String);
          final passwordMap = Map<String, dynamic>.from(map);
          passwordMap['password'] = decryptedPassword;
          passwords.add(PasswordModel.fromMap(passwordMap));
        } catch (decryptionError) {
          print('Debug: Failed to decrypt password in category $categoryId: $decryptionError');
          // Skip corrupted entries
          continue;
        }
      }
      return passwords;
    } catch (e) {
      throw Exception('Failed to get passwords by category: $e');
    }
  }

  /// Get uncategorized passwords
  Future<List<PasswordModel>> getUncategorizedPasswords() async {
    await initialize();
    try {
      final maps = await _database!.query(
        'passwords',
        where: 'categoryId IS NULL',
        orderBy: 'updatedAt DESC',
      );

      final List<PasswordModel> passwords = [];
      for (final map in maps) {
        try {
          final decryptedPassword = _getEncryptionService().decrypt(map['password'] as String);
          final passwordMap = Map<String, dynamic>.from(map);
          passwordMap['password'] = decryptedPassword;
          passwords.add(PasswordModel.fromMap(passwordMap));
        } catch (decryptionError) {
          print('Debug: Failed to decrypt uncategorized password: $decryptionError');
          // Skip corrupted entries
          continue;
        }
      }
      return passwords;
    } catch (e) {
      throw Exception('Failed to get uncategorized passwords: $e');
    }
  }

  /// Update existing default categories to Turkish names
  Future<void> updateCategoriesToTurkish() async {
    final db = _database!;
    
    final categoryUpdates = {
      'Social': 'Sosyal',
      'Email': 'E-posta',
      'Banking': 'Bankacılık',
      'Shopping': 'Alışveriş',
      'Work': 'İş',
      'Entertainment': 'Eğlence',
      'Other': 'Diğer',
    };

    try {
      for (final entry in categoryUpdates.entries) {
        await db.update(
          'categories',
          {'name': entry.value, 'updatedAt': DateTime.now().millisecondsSinceEpoch},
          where: 'name = ? AND isDefault = 1',
          whereArgs: [entry.key],
        );
      }
    } catch (e) {
      print('Failed to update categories to Turkish: $e');
    }
  }
}