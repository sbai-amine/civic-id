import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/pending_scan_row.dart';
import 'agent_key_storage.dart';

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
    final stored = await AgentKeyStorage.instance.readKey();
    final runtimeKey = (stored != null && stored.isNotEmpty)
        ? stored
        : ApiConfig.agentApiKey;
    // ignore: deprecated_member_use_from_same_package
    final legacy = ApiConfig.agentSyncSecret;
    if (runtimeKey.isEmpty && legacy.isEmpty) {
      return (
        localIds: const <int>[],
        error: 'No agent key set. Open Settings and paste the key from the admin web.',
      );
    }
    ({List<int> localIds, String? error})? last;
    for (var attempt = 0; attempt < 3; attempt++) {
      last = await _postOnce(rows, runtimeKey, legacy);
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
    String runtimeKey,
    String legacy,
  ) async {
    final uri = Uri.parse('$_baseUrl/sync/scans');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (runtimeKey.isNotEmpty) {
      // Match the format the admin web tells the operator to use.
      headers['Authorization'] = 'Bearer $runtimeKey';
    } else {
      headers['X-CivicKey-Agent-Sync'] = legacy;
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
