import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Interface for persistent and secure token storage.
abstract class TokenStorage {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<void> clear();
}

/// In-memory implementation of TokenStorage for unit testing.
class InMemoryTokenStorage implements TokenStorage {
  String? _accessToken;
  String? _refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async => _accessToken;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
  }
}

/// Production token storage backed by Android Keystore / iOS Keychain via [FlutterSecureStorage].
/// Automatically detects and migrates legacy unencrypted session files, deleting them upon migration.
class AppTokenStorage implements TokenStorage {
  static final AppTokenStorage _singleton = AppTokenStorage._internal();
  factory AppTokenStorage({FlutterSecureStorage? secureStorage}) {
    if (secureStorage != null) {
      _singleton._secureStorage = secureStorage;
    }
    return _singleton;
  }

  AppTokenStorage._internal()
      : _secureStorage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            resetOnError: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );

  FlutterSecureStorage _secureStorage;

  static const String _keyAccessToken = 'careid_auth_access_token';
  static const String _keyRefreshToken = 'careid_auth_refresh_token';

  String? _cachedAccessToken;
  String? _cachedRefreshToken;
  bool _initialized = false;

  /// Deletes legacy plaintext JSON files across all historical directories.
  void _purgeLegacyPlaintextFiles() {
    try {
      if (Platform.isAndroid) {
        final candidateDirs = [
          '/data/user/0/com.careid.careid_patient_app/files',
          '/data/user/0/com.careid.careid_patient_app/app_flutter',
          '/data/data/com.careid.careid_patient_app/files',
          '/data/data/com.careid.careid_patient_app/app_flutter',
          '/data/user/0/com.careid.careid_patient_app',
          '/data/data/com.careid.careid_patient_app',
        ];

        for (final dirPath in candidateDirs) {
          final f = File('$dirPath/careid_patient_session.json');
          if (f.existsSync()) {
            try {
              f.deleteSync();
            } catch (_) {}
          }
        }
      }

      final tempFile =
          File('${Directory.systemTemp.path}/careid_patient_session.json');
      if (tempFile.existsSync()) {
        try {
          tempFile.deleteSync();
        } catch (_) {}
      }
    } catch (_) {}
  }

  /// Migrates existing legacy unencrypted session files into secure storage if found.
  Future<void> _migrateLegacySessionFileIfPresent() async {
    try {
      if (Platform.isAndroid) {
        final candidateDirs = [
          '/data/user/0/com.careid.careid_patient_app/files',
          '/data/user/0/com.careid.careid_patient_app/app_flutter',
          '/data/data/com.careid.careid_patient_app/files',
          '/data/data/com.careid.careid_patient_app/app_flutter',
          '/data/user/0/com.careid.careid_patient_app',
          '/data/data/com.careid.careid_patient_app',
        ];

        for (final dirPath in candidateDirs) {
          final f = File('$dirPath/careid_patient_session.json');
          if (f.existsSync()) {
            final content = await f.readAsString();
            if (content.isNotEmpty) {
              final data = jsonDecode(content) as Map<String, dynamic>;
              final legacyAccess = data['accessToken'] as String?;
              final legacyRefresh = data['refreshToken'] as String?;
              if (legacyAccess != null && legacyAccess.isNotEmpty) {
                await _secureStorage.write(
                    key: _keyAccessToken, value: legacyAccess);
                if (legacyRefresh != null && legacyRefresh.isNotEmpty) {
                  await _secureStorage.write(
                      key: _keyRefreshToken, value: legacyRefresh);
                }
                _cachedAccessToken = legacyAccess;
                _cachedRefreshToken = legacyRefresh;
              }
            }
            try {
              f.deleteSync();
            } catch (_) {}
            return;
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // 1. Read from Android Keystore / iOS Keychain
      _cachedAccessToken = await _secureStorage.read(key: _keyAccessToken);
      _cachedRefreshToken = await _secureStorage.read(key: _keyRefreshToken);

      // 2. If empty in secure storage, check and migrate legacy unencrypted file
      if (_cachedAccessToken == null || _cachedAccessToken!.isEmpty) {
        await _migrateLegacySessionFileIfPresent();
      } else {
        // Clean up any remaining plaintext files safely
        _purgeLegacyPlaintextFiles();
      }
    } catch (_) {
      // In non-native test environments, fall back to memory
    }
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken;
    _initialized = true;

    try {
      await _secureStorage.write(key: _keyAccessToken, value: accessToken);
      await _secureStorage.write(key: _keyRefreshToken, value: refreshToken);
      // Ensure no legacy plaintext file remains after a secure write
      _purgeLegacyPlaintextFiles();
    } catch (_) {
      // Memory state preserved
    }
  }

  @override
  Future<String?> getAccessToken() async {
    await _ensureInitialized();
    return _cachedAccessToken;
  }

  @override
  Future<String?> getRefreshToken() async {
    await _ensureInitialized();
    return _cachedRefreshToken;
  }

  @override
  Future<void> clear() async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _initialized = true;

    try {
      await _secureStorage.delete(key: _keyAccessToken);
      await _secureStorage.delete(key: _keyRefreshToken);
    } catch (_) {}

    _purgeLegacyPlaintextFiles();
  }
}
