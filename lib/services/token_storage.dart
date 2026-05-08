import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists access/refresh tokens and app metadata in platform secure store.
class SecureTokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _accessKey = 'civickey.access.jwt';
  static const _refreshKey = 'civickey.refresh.jwt';
  static const _userIdKey = 'civickey.user_id';
  static const _lastSyncKey = 'civickey.last_sync_iso';
  static const _qrHmacKey = 'civickey.qr_hmac_key';
  static const _fullNameKey = 'civickey.full_name';

  final FlutterSecureStorage _storage;

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessKey, value: token);
  }

  Future<String?> readAccessToken() => _storage.read(key: _accessKey);

  Future<void> saveRefreshToken(String? token) async {
    if (token == null || token.isEmpty) {
      await _storage.delete(key: _refreshKey);
    } else {
      await _storage.write(key: _refreshKey, value: token);
    }
  }

  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  @Deprecated('Use readAccessToken')
  Future<String?> readJwt() => readAccessToken();

  @Deprecated('Use saveAccessToken')
  Future<void> saveJwt(String token) => saveAccessToken(token);

  /// Clears session tokens and user id; leaves preferences to [SharedPreferences].
  Future<void> clearSession() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _qrHmacKey);
    await _storage.delete(key: _fullNameKey);
  }

  Future<void> saveFullName(String? name) async {
    if (name == null || name.trim().isEmpty) {
      await _storage.delete(key: _fullNameKey);
    } else {
      await _storage.write(key: _fullNameKey, value: name.trim());
    }
  }

  Future<String?> readFullName() => _storage.read(key: _fullNameKey);

  Future<void> clearJwt() => clearSession();

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<String?> readUserId() => _storage.read(key: _userIdKey);

  Future<void> saveLastSyncTimeUtc(DateTime t) async {
    await _storage.write(key: _lastSyncKey, value: t.toUtc().toIso8601String());
  }

  Future<DateTime?> readLastSyncTimeUtc() async {
    final s = await _storage.read(key: _lastSyncKey);
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  Future<void> saveQrHmacKey(String? key) async {
    if (key == null || key.isEmpty) {
      await _storage.delete(key: _qrHmacKey);
    } else {
      await _storage.write(key: _qrHmacKey, value: key);
    }
  }

  Future<String?> readQrHmacKey() => _storage.read(key: _qrHmacKey);
}
