import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/pending_service_qr_row.dart';
import 'session_service.dart';

/// Uploads citizen QR rows to POST `/sync/service-qr` (session + limited retries).
class CitizenSyncApiService {
  CitizenSyncApiService({
    http.Client? httpClient,
    String? baseUrl,
    SessionService? session,
  })  : _client = httpClient ?? http.Client(),
        _baseUrl = (baseUrl ?? ApiConfig.baseUrl).replaceAll(RegExp(r'/+$'), ''),
        _session = session ?? SessionService(client: httpClient, baseUrl: baseUrl);

  final http.Client _client;
  final String _baseUrl;
  final SessionService _session;

  Future<({List<int> localIds, String? error})> pushServiceQrBatch({
    required List<PendingServiceQrRow> rows,
  }) async {
    if (rows.isEmpty) {
      return (localIds: const <int>[], error: null);
    }
    ({List<int> localIds, String? error})? last;
    for (var attempt = 0; attempt < 3; attempt++) {
      last = await _postOnce(rows);
      if (last.error == null) return last;
      if (last.error!.toLowerCase().contains('sign in') ||
          last.error!.toLowerCase().contains('session')) {
        return last;
      }
      if (last.error!.contains('400') || last.error!.contains('hash')) {
        return last;
      }
      if (attempt < 2) {
        await Future<void>.delayed(Duration(milliseconds: 400 * (1 << attempt)));
      }
    }
    return last ?? (localIds: const <int>[], error: 'Sync failed');
  }

  Future<({List<int> localIds, String? error})> _postOnce(
    List<PendingServiceQrRow> rows,
  ) async {
    final jwt = await _session.getValidAccessToken();
    if (jwt == null || jwt.isEmpty) {
      return (localIds: const <int>[], error: 'Session expired. Sign in again.');
    }
    final uri = Uri.parse('$_baseUrl/sync/service-qr');
    try {
      final response = await _client
          .post(
            uri,
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $jwt',
            },
            body: jsonEncode(<String, dynamic>{
              'items': rows.map((e) => e.toSyncJson()).toList(),
            }),
          )
          .timeout(const Duration(seconds: 45));

      final decoded = jsonDecode(response.body);
      final map = decoded is Map<String, dynamic> ? decoded : null;

      if (response.statusCode == 200 && map?['success'] == true) {
        final data = map!['data'];
        if (data is! Map<String, dynamic>) {
          return (localIds: const <int>[], error: 'Invalid sync response');
        }
        final rawIds = data['localIds'];
        if (rawIds is! List) {
          return (localIds: const <int>[], error: 'Invalid sync response');
        }
        final ids = <int>[];
        for (final x in rawIds) {
          if (x is int) {
            ids.add(x);
          } else if (x is num) {
            ids.add(x.toInt());
          }
        }
        return (localIds: ids, error: null);
      }

      if (response.statusCode == 401) {
        return (localIds: const <int>[], error: 'Session expired. Sign in again.');
      }

      final err = map?['error'];
      if (err is Map && err['message'] is String) {
        return (localIds: const <int>[], error: err['message'] as String);
      }
      return (
        localIds: const <int>[],
        error: 'Sync failed (${response.statusCode})',
      );
    } on TimeoutException {
      return (localIds: const <int>[], error: 'Request timed out. Will retry if attempts remain.');
    } catch (e, st) {
      assert(() {
        debugPrint('CitizenSyncApiService: $e\n$st');
        return true;
      }());
      return (
        localIds: const <int>[],
        error: 'No connection or server unreachable. Try again when online.',
      );
    }
  }
}
