import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class AdminApiService {
  AdminApiService({http.Client? client, String? baseUrl, String? adminApiKey})
      : _client = client ?? http.Client(),
        _baseUrl = (baseUrl ?? ApiConfig.baseUrl).replaceAll(RegExp(r'/+$'), ''),
        _adminApiKey = adminApiKey ?? ApiConfig.adminApiKey;

  final http.Client _client;
  final String _baseUrl;
  final String _adminApiKey;

  bool get hasAdminKey => _adminApiKey.trim().isNotEmpty;

  Map<String, String> get _headers => <String, String>{
        'Accept': 'application/json',
        'Authorization': 'Bearer $_adminApiKey',
      };

  Future<Map<String, dynamic>> fetchKpis() async {
    final res = await _client.get(Uri.parse('$_baseUrl/admin/kpis'), headers: _headers);
    return _decode(res);
  }

  Future<List<Map<String, dynamic>>> fetchAuditLogs() async {
    final res = await _client.get(Uri.parse('$_baseUrl/admin/audit-logs?limit=100'), headers: _headers);
    final json = _decode(res);
    final logs = json['data']?['logs'];
    if (logs is List) {
      return logs.whereType<Map<String, dynamic>>().toList(growable: false);
    }
    return const <Map<String, dynamic>>[];
  }

  Future<List<Map<String, dynamic>>> fetchAgentKeys() async {
    final res = await _client.get(Uri.parse('$_baseUrl/admin/agent-keys'), headers: _headers);
    final json = _decode(res);
    final keys = json['data']?['keys'];
    if (keys is List) {
      return keys.whereType<Map<String, dynamic>>().toList(growable: false);
    }
    return const <Map<String, dynamic>>[];
  }

  Future<void> disableAgentKey(String id) async {
    final res = await _client.post(Uri.parse('$_baseUrl/admin/agent-keys/$id/disable'), headers: _headers);
    _decode(res);
  }

  Future<void> enableAgentKey(String id) async {
    final res = await _client.post(Uri.parse('$_baseUrl/admin/agent-keys/$id/enable'), headers: _headers);
    _decode(res);
  }

  Future<Map<String, dynamic>> verifySignedDocument(String id) async {
    final res = await _client.get(Uri.parse('$_baseUrl/crypto/signed-documents/$id/verify'), headers: _headers);
    final json = _decode(res);
    final data = json['data'];
    if (data is Map<String, dynamic>) return data;
    return const <String, dynamic>{};
  }

  Map<String, dynamic> _decode(http.Response res) {
    Map<String, dynamic> json = const {};
    if (res.body.isNotEmpty) {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        json = decoded;
      }
    }
    if (res.statusCode >= 400 || json['success'] == false) {
      final message = json['error']?['message']?.toString() ?? 'Admin request failed (${res.statusCode})';
      throw StateError(message);
    }
    return json;
  }
}
