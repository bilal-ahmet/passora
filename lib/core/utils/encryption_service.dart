import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  static const int _keyLength = 32; // 256-bit key
  static const int _ivLength = 16; // 128-bit IV

  static EncryptionService? _instance;
  static EncryptionService get instance {
    if (_instance == null) {
      throw Exception('EncryptionService not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  final Encrypter _encrypter;

  EncryptionService._(this._encrypter);

  /// Initialize with master password and salt
  static void initialize(String masterPassword, String salt) {
    final key = _deriveKey(masterPassword, salt);
    final encrypter = Encrypter(AES(key));
    _instance = EncryptionService._(encrypter);
  }

  /// Initialize with default key for bypass mode
  static void initializeWithDefaultKey() {
    const defaultPassword = 'default_passora_key_2024';
    const defaultSalt = 'passora_salt_default_2024';
    final key = _deriveKey(defaultPassword, defaultSalt);
    final encrypter = Encrypter(AES(key));
    _instance = EncryptionService._(encrypter);
  }

  /// Create an encryption service from master password and salt
  static EncryptionService fromMasterPassword(String masterPassword, String salt) {
    final key = _deriveKey(masterPassword, salt);
    final encrypter = Encrypter(AES(key));
    return EncryptionService._(encrypter);
  }

  /// Derive encryption key from master password and salt using PBKDF2
  static Key _deriveKey(String password, String salt) {
    const iterations = 10000;
    final saltBytes = utf8.encode(salt);
    var derivedKey = Uint8List.fromList(utf8.encode(password));
    
    for (int i = 0; i < iterations; i++) {
      final hmac = Hmac(sha256, derivedKey);
      derivedKey = Uint8List.fromList(hmac.convert(saltBytes).bytes);
    }
    
    // Take first 32 bytes for AES-256
    final keyBytes = Uint8List.fromList(derivedKey.take(_keyLength).toList());
    return Key(keyBytes);
  }

  /// Generate a cryptographically secure salt
  static String generateSalt() {
    final secureRandom = SecureRandom(32);
    return base64Encode(secureRandom.bytes);
  }

  /// Generate a cryptographically secure IV
  IV _generateIV() {
    final secureRandom = SecureRandom(_ivLength);
    return IV(secureRandom.bytes);
  }

  /// Encrypt a plaintext string
  String encrypt(String plaintext) {
    if (plaintext.isEmpty) return '';
    
    final iv = _generateIV();
    final encrypted = _encrypter.encrypt(plaintext, iv: iv);
    
    // Combine IV and encrypted data
    final combined = iv.bytes + encrypted.bytes;
    return base64Encode(combined);
  }

  /// Decrypt an encrypted string
  String decrypt(String encryptedData) {
    if (encryptedData.isEmpty) return '';
    
    try {
      final combined = base64Decode(encryptedData);
      
      // Extract IV and encrypted data
      final iv = IV(Uint8List.fromList(combined.take(_ivLength).toList()));
      final encryptedBytes = Uint8List.fromList(combined.skip(_ivLength).toList());
      final encrypted = Encrypted(encryptedBytes);
      
      return _encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw EncryptionException('Failed to decrypt data: $e');
    }
  }

  /// Hash master password for verification
  static String hashMasterPassword(String password, String salt) {
    final combined = password + salt;
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify master password
  static bool verifyMasterPassword(String password, String salt, String storedHash) {
    final hash = hashMasterPassword(password, salt);
    return hash == storedHash;
  }
}

class EncryptionException implements Exception {
  final String message;
  const EncryptionException(this.message);
  
  @override
  String toString() => 'EncryptionException: $message';
}