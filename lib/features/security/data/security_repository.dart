import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

@immutable
class SecuritySettingsSnapshot {
  const SecuritySettingsSnapshot({
    required this.hideBalances,
    required this.biometricEnabled,
    required this.screenshotProtectionEnabled,
    required this.notificationsEnabled,
    required this.autoLockMinutes,
  });

  final bool hideBalances;
  final bool biometricEnabled;
  final bool screenshotProtectionEnabled;
  final bool notificationsEnabled;
  final int autoLockMinutes;

  SecuritySettingsSnapshot copyWith({
    bool? hideBalances,
    bool? biometricEnabled,
    bool? screenshotProtectionEnabled,
    bool? notificationsEnabled,
    int? autoLockMinutes,
  }) {
    return SecuritySettingsSnapshot(
      hideBalances: hideBalances ?? this.hideBalances,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      screenshotProtectionEnabled:
          screenshotProtectionEnabled ?? this.screenshotProtectionEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
    );
  }

  Map<String, Object> toJson() {
    return {
      'hideBalances': hideBalances,
      'biometricEnabled': biometricEnabled,
      'screenshotProtectionEnabled': screenshotProtectionEnabled,
      'notificationsEnabled': notificationsEnabled,
      'autoLockMinutes': autoLockMinutes,
    };
  }

  factory SecuritySettingsSnapshot.fromJson(Map<String, dynamic> json) {
    return SecuritySettingsSnapshot(
      hideBalances: json['hideBalances'] as bool? ?? false,
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      screenshotProtectionEnabled:
          json['screenshotProtectionEnabled'] as bool? ?? true,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      autoLockMinutes: json['autoLockMinutes'] as int? ?? 5,
    );
  }
}

@immutable
class SecurityProfileSnapshot {
  const SecurityProfileSnapshot({
    required this.passwordConfigured,
    required this.settings,
  });

  final bool passwordConfigured;
  final SecuritySettingsSnapshot settings;
}

abstract class SecurityRepository {
  Future<SecurityProfileSnapshot> readProfile({
    required String bootstrapPassword,
    required SecuritySettingsSnapshot fallbackSettings,
  });

  Future<bool> verifyPassword(String password);
  Future<void> writePassword(String password);
  Future<void> writeSettings(SecuritySettingsSnapshot settings);
}

class SecureStorageSecurityRepository implements SecurityRepository {
  SecureStorageSecurityRepository({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _passwordHashKey = 'wallet.password.sha256';
  static const _settingsKey = 'wallet.security.settings';

  final FlutterSecureStorage _storage;

  @override
  Future<SecurityProfileSnapshot> readProfile({
    required String bootstrapPassword,
    required SecuritySettingsSnapshot fallbackSettings,
  }) async {
    var passwordHash = await _storage.read(key: _passwordHashKey);
    if (passwordHash == null) {
      passwordHash = _hashPassword(bootstrapPassword);
      await _storage.write(key: _passwordHashKey, value: passwordHash);
    }

    final settingsJson = await _storage.read(key: _settingsKey);
    final settings = settingsJson == null
        ? fallbackSettings
        : SecuritySettingsSnapshot.fromJson(
            jsonDecode(settingsJson) as Map<String, dynamic>,
          );
    return SecurityProfileSnapshot(
      passwordConfigured: passwordHash.isNotEmpty,
      settings: settings,
    );
  }

  @override
  Future<bool> verifyPassword(String password) async {
    final passwordHash = await _storage.read(key: _passwordHashKey);
    if (passwordHash == null) {
      return false;
    }
    return passwordHash == _hashPassword(password);
  }

  @override
  Future<void> writePassword(String password) {
    return _storage.write(
      key: _passwordHashKey,
      value: _hashPassword(password),
    );
  }

  @override
  Future<void> writeSettings(SecuritySettingsSnapshot settings) {
    return _storage.write(
      key: _settingsKey,
      value: jsonEncode(settings.toJson()),
    );
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password.trim())).toString();
  }
}

class MemorySecurityRepository implements SecurityRepository {
  MemorySecurityRepository({
    this.initialPassword = '',
    SecuritySettingsSnapshot? initialSettings,
  }) : _settings =
           initialSettings ??
           const SecuritySettingsSnapshot(
             hideBalances: false,
             biometricEnabled: false,
             screenshotProtectionEnabled: true,
             notificationsEnabled: true,
             autoLockMinutes: 5,
           );

  final String initialPassword;
  SecuritySettingsSnapshot _settings;
  String? _passwordHash;

  @override
  Future<SecurityProfileSnapshot> readProfile({
    required String bootstrapPassword,
    required SecuritySettingsSnapshot fallbackSettings,
  }) async {
    _passwordHash ??= _hashPassword(
      initialPassword.isEmpty ? bootstrapPassword : initialPassword,
    );
    _settings = _settings.copyWith(
      hideBalances: _settings.hideBalances,
      biometricEnabled: _settings.biometricEnabled,
      screenshotProtectionEnabled: _settings.screenshotProtectionEnabled,
      notificationsEnabled: _settings.notificationsEnabled,
      autoLockMinutes: _settings.autoLockMinutes,
    );
    return SecurityProfileSnapshot(
      passwordConfigured: _passwordHash!.isNotEmpty,
      settings: _settings,
    );
  }

  @override
  Future<bool> verifyPassword(String password) async {
    return _passwordHash == _hashPassword(password);
  }

  @override
  Future<void> writePassword(String password) async {
    _passwordHash = _hashPassword(password);
  }

  @override
  Future<void> writeSettings(SecuritySettingsSnapshot settings) async {
    _settings = settings;
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password.trim())).toString();
  }
}
