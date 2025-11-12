class AppExceptions implements Exception {
  final String message;
  final int? code;
  
  const AppExceptions({
    required this.message,
    this.code,
  });
  
  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

class AuthenticationException extends AppExceptions {
  const AuthenticationException({
    super.message = 'Authentication failed',
    super.code,
  });
}

class BiometricException extends AppExceptions {
  const BiometricException({
    super.message = 'Biometric authentication failed',
    super.code,
  });
}

class StorageException extends AppExceptions {
  const StorageException({
    super.message = 'Storage operation failed',
    super.code,
  });
}

class EncryptionException extends AppExceptions {
  const EncryptionException({
    super.message = 'Encryption/Decryption failed',
    super.code,
  });
}

class NetworkException extends AppExceptions {
  const NetworkException({
    super.message = 'Network operation failed',
    super.code,
  });
}

class ValidationException extends AppExceptions {
  const ValidationException({
    super.message = 'Validation failed',
    super.code,
  });
}

class FileException extends AppExceptions {
  const FileException({
    super.message = 'File operation failed',
    super.code,
  });
}