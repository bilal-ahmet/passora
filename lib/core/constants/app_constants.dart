class AppConstants {
  // App Info
  static const String appName = 'Passora';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Secure password manager for everyone';
  
  // Database
  static const String hiveBoxAuth = 'auth_box';
  static const String hiveBoxPasswords = 'passwords_box';
  static const String hiveBoxSettings = 'settings_box';
  
  // Security
  static const int keyDerivationIterations = 10000;
  static const int saltLength = 32;
  static const int keyLength = 32;
  
  // UI
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double defaultElevation = 2.0;
  
  // Animation
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Biometric
  static const String biometricReason = 'Authenticate to access your passwords';
  
  // Password Generation
  static const int defaultPasswordLength = 16;
  static const int minPasswordLength = 4;
  static const int maxPasswordLength = 128;
  
  // Backup & Sync
  static const String backupFileExtension = '.passora';
  static const String exportDateFormat = 'yyyy-MM-dd_HH-mm-ss';
}