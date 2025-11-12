import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

class AppUtils {
  // Password strength calculation
  static PasswordStrength calculatePasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.weak;
    
    int score = 0;
    
    // Length score
    if (password.length >= 8) score += 1;
    if (password.length >= 12) score += 1;
    if (password.length >= 16) score += 1;
    
    // Character variety score
    if (password.contains(RegExp(r'[a-z]'))) score += 1; // lowercase
    if (password.contains(RegExp(r'[A-Z]'))) score += 1; // uppercase
    if (password.contains(RegExp(r'[0-9]'))) score += 1; // numbers
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 1; // symbols
    
    // Penalty for common patterns
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) score -= 1; // repeated characters
    if (RegExp(r'(abc|123|qwe|asd|zxc)', caseSensitive: false).hasMatch(password)) score -= 1; // common sequences
    
    // Return strength based on score
    if (score >= 7) return PasswordStrength.veryStrong;
    if (score >= 5) return PasswordStrength.strong;
    if (score >= 3) return PasswordStrength.medium;
    return PasswordStrength.weak;
  }
  
  // Password generation
  static String generatePassword({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
    bool excludeSimilar = false,
  }) {
    String chars = '';
    
    if (includeLowercase) {
      chars += excludeSimilar ? 'abcdefghjkmnpqrstuvwxyz' : 'abcdefghijklmnopqrstuvwxyz';
    }
    if (includeUppercase) {
      chars += excludeSimilar ? 'ABCDEFGHJKMNPQRSTUVWXYZ' : 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    }
    if (includeNumbers) {
      chars += excludeSimilar ? '23456789' : '0123456789';
    }
    if (includeSymbols) {
      chars += '!@#\$%^&*()_+-=[]{}|;:,.<>?';
    }
    
    if (chars.isEmpty) return '';
    
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
  
  // Hash generation for master password
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Salt generation
  static String generateSalt([int length = 32]) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Encode(values);
  }
  
  // Format date
  static String formatDate(DateTime date, {String pattern = 'dd/MM/yyyy HH:mm'}) {
    return DateFormat(pattern).format(date);
  }
  
  // Format relative time
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years} year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months} month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
  
  // Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }
  
  // Validate URL
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return url.startsWith('http://') || url.startsWith('https://');
    } catch (e) {
      return false;
    }
  }
  
  // Extract domain from URL
  static String? extractDomain(String url) {
    try {
      final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
      return uri.host;
    } catch (e) {
      return null;
    }
  }
  
  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  // Truncate text
  static String truncateText(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }
  
  // Generate UUID-like string
  static String generateId() {
    final random = Random();
    return '${random.nextInt(999999999).toString().padLeft(9, '0')}-${DateTime.now().millisecondsSinceEpoch}';
  }
  
  // Debounce function helper
  static Timer? _debounceTimer;
  
  static void debounce(Function() function, Duration delay) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, function);
  }
}

enum PasswordStrength { weak, medium, strong, veryStrong }

extension PasswordStrengthExtension on PasswordStrength {
  String get label {
    switch (this) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
      case PasswordStrength.veryStrong:
        return 'Very Strong';
    }
  }
  
  double get score {
    switch (this) {
      case PasswordStrength.weak:
        return 0.25;
      case PasswordStrength.medium:
        return 0.5;
      case PasswordStrength.strong:
        return 0.75;
      case PasswordStrength.veryStrong:
        return 1.0;
    }
  }
}