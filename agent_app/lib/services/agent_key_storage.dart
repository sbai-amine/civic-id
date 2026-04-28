import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the verifier device's agent API key in the platform secure store
/// (iOS Keychain / Android Keystore). The key is the raw secret issued by the
/// admin web's "New Agent Key" flow — sent verbatim as a Bearer token.
class AgentKeyStorage {
  AgentKeyStorage._();
  static final AgentKeyStorage instance = AgentKeyStorage._();

  static const _key = 'civickey.agent_api_key';
  static const _label = 'civickey.agent_label';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// In-memory cache so we don't hit the platform store on every API call.
  String? _cachedKey;

  Future<String?> readKey() async {
    if (_cachedKey != null && _cachedKey!.isNotEmpty) return _cachedKey;
    try {
      final v = await _storage.read(key: _key);
      _cachedKey = v;
      return v;
    } catch (e, st) {
      assert(() {
        debugPrint('AgentKeyStorage.readKey: $e\n$st');
        return true;
      }());
      return null;
    }
  }

  Future<void> saveKey(String value, {String? label}) async {
    await _storage.write(key: _key, value: value);
    if (label != null) {
      await _storage.write(key: _label, value: label);
    }
    _cachedKey = value;
  }

  Future<String?> readLabel() => _storage.read(key: _label);

  Future<void> clear() async {
    await _storage.delete(key: _key);
    await _storage.delete(key: _label);
    _cachedKey = null;
  }
}
