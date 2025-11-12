import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;
  
  const Failure({
    required this.message,
    this.code,
  });
  
  @override
  List<Object?> get props => [message, code];
}

// Authentication Failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    super.message = 'Authentication failed',
    super.code,
  });
}

class BiometricFailure extends Failure {
  const BiometricFailure({
    super.message = 'Biometric authentication failed',
    super.code,
  });
}

class MasterPasswordFailure extends Failure {
  const MasterPasswordFailure({
    super.message = 'Master password is incorrect',
    super.code,
  });
}

// Storage Failures
class StorageFailure extends Failure {
  const StorageFailure({
    super.message = 'Storage operation failed',
    super.code,
  });
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({
    super.message = 'Database operation failed',
    super.code,
  });
}

// Encryption Failures
class EncryptionFailure extends Failure {
  const EncryptionFailure({
    super.message = 'Encryption/Decryption failed',
    super.code,
  });
}

// Network Failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Network connection failed',
    super.code,
  });
}

class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error occurred',
    super.code,
  });
}

// Validation Failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message = 'Validation failed',
    super.code,
  });
}

// File Operation Failures
class FileFailure extends Failure {
  const FileFailure({
    super.message = 'File operation failed',
    super.code,
  });
}

// Import/Export Failures
class ImportFailure extends Failure {
  const ImportFailure({
    super.message = 'Import operation failed',
    super.code,
  });
}

class ExportFailure extends Failure {
  const ExportFailure({
    super.message = 'Export operation failed',
    super.code,
  });
}

// Generic Failure
class GenericFailure extends Failure {
  const GenericFailure({
    super.message = 'An unexpected error occurred',
    super.code,
  });
}