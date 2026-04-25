import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/pending_scan_row.dart';

/// POST `/sync/scans` with per-device API key or legacy shared header.
class AgentSyncApiService {
  AgentSyncApiService({http.Client? httpClient, String? baseUrl})
      : _client = httpClient ?? http.Client(),
        _baseUrl = (baseUrl ?? ApiConfig.baseUrl).replaceAll(RegExp(r'/+$'), '');

  final http.Client _client;
  final String _baseUrl;

  Future<({List<int> localIds, String? error})> pushScanBatch({
    required List<PendingScanRow> rows,
  }) async {
    if (rows.isEmpty) {
      return (localIds: const <int>[], error: null);
    }
    if (ApiConfig.agentApiKey.isEmpty && ApiConfig.agentSyncSecret.isEmpty) {
      return (
        localIds: const <int>[],
        error: 'Set AGENT_API_KEY (or legacy AGENT_SYNC_SECRET) in dart-define.',
      );
    }
    ({List<int> localIds, String? error})? last;
    for (var attempt = 0; attempt < 3; attempt++) {
      last = await _postOnce(rows);
      if (last.error == null) return last;
      if (last.error!.contains('400') || last.error!.contains('401')) return last;
      if (attempt < 2) {
        await Future<void>.delayed(Duration(milliseconds: 400 * (1 << attempt)));
      }
    }
    return last ?? (localIds: const <int>[], error: 'Sync failed');
  }

  Future<({List<int> localIds, String? error})> _postOnce(
    List<PendingScanRow> rows,
  ) async {
    final uri = Uri.parse('$_baseUrl/sync/scans');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (ApiConfig.agentApiKey.isNotEmpty) {
      headers['X-API-Key'] = ApiConfig.agentApiKey;
    } else {
      headers['X-CivicKey-Agent-Sync'] = ApiConfig.agentSyncSecret;
    }
    try {
      final response = await _client
          .post(
            uri,
            headers: headers,
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
      final err = map?['error'];
      if (err is Map && err['message'] is String) {
        return (localIds: const <int>[], error: err['message'] as String);
      }
      return (
        localIds: const <int>[],
        error: 'Sync failed (${response.statusCode})',
      );
    } on TimeoutException {
      return (
        localIds: const <int>[],
        error: 'Request timed out. Will retry if attempts remain.',
      );
    } catch (e, st) {
      assert(() {
        debugPrint('AgentSyncApiService: $e\n$st');
        return true;
      }());
      return (
        localIds: const <int>[],
        error: 'No connection or server unreachable.',
      );
    }
  }
}
