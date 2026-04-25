import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'session_service.dart';

class CryptoApiService {
  CryptoApiService({http.Client? client, String? baseUrl, SessionService? session})
      : _client = client ?? http.Client(),
        _baseUrl = (baseUrl ?? ApiConfig.baseUrl).replaceAll(RegExp(r'/+$'), ''),
        _session = session ?? SessionService(client: client, baseUrl: baseUrl ?? ApiConfig.baseUrl);

  final http.Client _client;
  final String _baseUrl;
  final SessionService _session;

  Future<Map<String, dynamic>> signServiceRequest({
    required String serviceId,
    required String serviceName,
    required String note,
  }) async {
    final token = await _session.getValidAccessToken();
    if (token == null || token.isEmpty) {
      throw StateError('Session expired. Sign in again.');
    }
    final payload = <String, dynamic>{
      'serviceId': serviceId,
      'serviceName': serviceName,
      'note': note,
      'requestedAt': DateTime.now().toUtc().toIso8601String(),
    };
    final res = await _client.post(
      Uri.parse('$_baseUrl/crypto/sign-document'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'docType': 'service_request',
        'payload': payload,
      }),
    );
    final map = _decode(res);
    return (map['data']?['signed'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
  }

  Map<String, dynamic> _decode(http.Response res) {
    Map<String, dynamic> json = const {};
    if (res.body.isNotEmpty) {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) json = decoded;
    }
    if (res.statusCode >= 400 || json['success'] == false) {
      final msg = json['error']?['message']?.toString() ?? 'Crypto request failed (${res.statusCode})';
      throw StateError(msg);
    }
    return json;
  }
}
