class SettingsModel {
  int? id;
  bool autoLockEnabled;
  int autoLockDuration;
  String themeMode;
  bool masterPasswordEnabled;

  SettingsModel({
    this.id,
    required this.autoLockEnabled,
    required this.autoLockDuration,
    required this.themeMode,
    required this.masterPasswordEnabled,
  });

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'autoLockEnabled': autoLockEnabled ? 1 : 0,
      'autoLockDuration': autoLockDuration,
      'themeMode': themeMode,
      'masterPasswordEnabled': masterPasswordEnabled ? 1 : 0,
    };
  }

  // Create from Map for SQLite
  static SettingsModel fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      id: map['id'] as int?,
      autoLockEnabled: (map['autoLockEnabled'] as int) == 1,
      autoLockDuration: map['autoLockDuration'] as int,
      themeMode: map['themeMode'] as String,
      masterPasswordEnabled: (map['masterPasswordEnabled'] as int?) == 1,
    );
  }

  // CopyWith method for immutability
  SettingsModel copyWith({
    int? id,
    bool? autoLockEnabled,
    int? autoLockDuration,
    String? themeMode,
    bool? masterPasswordEnabled,
  }) {
    return SettingsModel(
      id: id ?? this.id,
      autoLockEnabled: autoLockEnabled ?? this.autoLockEnabled,
      autoLockDuration: autoLockDuration ?? this.autoLockDuration,
      themeMode: themeMode ?? this.themeMode,
      masterPasswordEnabled: masterPasswordEnabled ?? this.masterPasswordEnabled,
    );
  }

  @override
  String toString() {
    return 'SettingsModel{id: $id, autoLockEnabled: $autoLockEnabled, autoLockDuration: $autoLockDuration, themeMode: $themeMode, masterPasswordEnabled: $masterPasswordEnabled}';
  }
}