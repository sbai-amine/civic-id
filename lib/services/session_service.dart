import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../utils/jwt_exp.dart';
import 'token_storage.dart';

/// Ensures a non-expired access token, using refresh when possible.
class SessionService {
  SessionService({
    SecureTokenStorage? storage,
    http.Client? client,
    String? baseUrl,
  })  : _storage = storage ?? SecureTokenStorage(),
        _client = client ?? http.Client(),
        _baseUrl = (baseUrl ?? ApiConfig.baseUrl).replaceAll(RegExp(r'/+$'), '');

  final SecureTokenStorage _storage;
  final http.Client _client;
  final String _baseUrl;

  /// Returns a valid access token or `null` if the user must sign in again.
  Future<String?> getValidAccessToken() async {
    var access = await _storage.readAccessToken();
    final refresh = await _storage.readRefreshToken();
    if (access == null || access.isEmpty) return null;
    if (!isJwtExpiredOrNearExpiry(access)) return access;
    if (refresh == null || refresh.isEmpty) return null;
    return _doRefresh(refresh);
  }

  Future<String?> _doRefresh(String refresh) async {
    final uri = Uri.parse('$_baseUrl/auth/refresh');
    try {
      final res = await _client
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(<String, String>{'refreshToken': refresh}),
          )
          .timeout(const Duration(seconds: 25));
      final body = res.body;
      if (body.isEmpty) {
        await _storage.clearSession();
        return null;
      }
      final map = jsonDecode(body);
      if (res.statusCode == 200 && map is Map && map['success'] == true) {
        final data = map['data'];
        if (data is Map) {
          final t = data['accessToken'] ?? data['token'];
          if (t is String && t.isNotEmpty) {
            await _storage.saveAccessToken(t);
            return t;
          }
        }
      }
    } catch (e, st) {
      assert(() {
        debugPrint('SessionService refresh: $e\n$st');
        return true;
      }());
    }
    await _storage.clearSession();
    return null;
  }
}
