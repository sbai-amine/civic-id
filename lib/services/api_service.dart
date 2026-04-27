import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/civic_service.dart';
import '../models/login_credentials.dart';
import '../models/register_request.dart';
import '../models/register_result.dart';
import '../models/sign_in_result.dart';
import 'session_service.dart';

/// Result of [ApiService.fetchServices].
typedef ServicesFetchResult = ({List<CivicService> services, String? error});

/// HTTP client for BridgeID backend REST endpoints.
class ApiService {
  ApiService({
    http.Client? httpClient,
    String? baseUrl,
    SessionService? session,
  })  : _client = httpClient ?? http.Client(),
        _baseUrl = (baseUrl ?? ApiConfig.baseUrl).replaceAll(RegExp(r'/+$'), ''),
        _session = session ??
            SessionService(
              client: httpClient,
              baseUrl: baseUrl ?? ApiConfig.baseUrl,
            );

  final http.Client _client;
  final String _baseUrl;
  final SessionService _session;

  /// POST `/login`
  Future<SignInResult> login(LoginCredentials credentials) async {
    final uri = Uri.parse('$_baseUrl/login');

    try {
      final response = await _client
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(<String, String>{
              'nationalID': credentials.nationalId.trim(),
              'PIN': credentials.pin.trim(),
            }),
          )
          .timeout(const Duration(seconds: 30));

      Map<String, dynamic>? json;
      try {
        if (response.body.isEmpty) {
          json = null;
        } else {
          final decoded = jsonDecode(response.body);
          json = decoded is Map<String, dynamic> ? decoded : null;
        }
      } catch (e, st) {
        assert(() {
          debugPrint('ApiService.login JSON decode: $e\n$st');
          return true;
        }());
        return const SignInFailure(
          'Invalid response from server. Please try again later.',
        );
      }

      if (response.statusCode == 200 && json?['success'] == true) {
        final data = json!['data'];
        if (data is! Map<String, dynamic>) {
          return const SignInFailure(
            'Login succeeded but response was incomplete.',
          );
        }
        final access = data['accessToken'] ?? data['token'] as String?;
        if (access == null || access.isEmpty) {
          return const SignInFailure(
            'Login succeeded but no access token was returned.',
          );
        }
        final refresh = data['refreshToken'] as String?;
        final qrKey = data['qrHmacKey'] as String?;
        return SignInSuccess(
          accessToken: access,
          refreshToken: refresh,
          qrHmacKey: (qrKey != null && qrKey.isNotEmpty) ? qrKey : null,
        );
      }

      final message = _messageFromErrorJson(json) ??
          'Login failed (${response.statusCode}). Please try again.';
      return SignInFailure(message);
    } on TimeoutException {
      return const SignInFailure(
        'Request timed out. Check your connection and try again.',
      );
    } on http.ClientException catch (e, st) {
      assert(() {
        debugPrint('ApiService.login ClientException: $e\n$st');
        return true;
      }());
      return const SignInFailure(
        'Could not reach the server. Check the API address and your network.',
      );
    } catch (e, st) {
      assert(() {
        debugPrint('ApiService.login: $e\n$st');
        return true;
      }());
      return const SignInFailure(
        'Something went wrong. Please try again.',
      );
    }
  }

  /// POST `/register` — demo self-registration with CIN + name + PIN.
  Future<RegisterResult> register(RegisterRequest request) async {
    final uri = Uri.parse('$_baseUrl/register');
    try {
      final response = await _client
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(<String, String>{
              'nationalID': request.nationalId.trim(),
              'fullName': request.fullName.trim(),
              'PIN': request.pin.trim(),
            }),
          )
          .timeout(const Duration(seconds: 30));

      Map<String, dynamic>? json;
      try {
        json = response.body.isEmpty ? null : jsonDecode(response.body) as Map<String, dynamic>?;
      } catch (e, st) {
        assert(() {
          debugPrint('ApiService.register JSON decode: $e\n$st');
          return true;
        }());
        return const RegisterFailure('Invalid response from server. Please try again later.');
      }

      if (response.statusCode == 201 && json?['success'] == true) {
        return RegisterSuccess(nationalId: request.nationalId);
      }

      final message = _messageFromErrorJson(json) ??
          'Registration failed (${response.statusCode}). Please try again.';
      return RegisterFailure(message);
    } on TimeoutException {
      return const RegisterFailure('Request timed out. Check your connection and try again.');
    } on http.ClientException catch (e, st) {
      assert(() {
        debugPrint('ApiService.register ClientException: $e\n$st');
        return true;
      }());
      return const RegisterFailure(
          'Could not reach the server. Check the API address and your network.');
    } catch (e, st) {
      assert(() {
        debugPrint('ApiService.register: $e\n$st');
        return true;
      }());
      return const RegisterFailure('Something went wrong. Please try again.');
    }
  }

  /// GET `/services` — uses session (refresh on 401 once).
  Future<ServicesFetchResult> fetchServices() async {
    final uri = Uri.parse('$_baseUrl/services');

    Future<http.Response> doGet(String token) {
      return _client
          .get(
            uri,
            headers: <String, String>{
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 30));
    }

    try {
      var token = await _session.getValidAccessToken();
      if (token == null || token.isEmpty) {
        return (
          services: const <CivicService>[],
          error: 'No session. Sign in again.',
        );
      }

      var response = await doGet(token);
      if (response.statusCode == 401) {
        token = await _session.getValidAccessToken();
        if (token == null || token.isEmpty) {
          return (services: const <CivicService>[], error: 'Session expired. Sign in again.');
        }
        response = await doGet(token);
      }

      final json = _tryDecodeJsonObject(response.body);
      if (json == null && response.body.isNotEmpty) {
        return (
          services: const <CivicService>[],
          error: 'Invalid response from server. Please try again later.',
        );
      }

      if (response.statusCode == 200 && json?['success'] == true) {
        final data = json!['data'];
        if (data is! Map<String, dynamic>) {
          return (
            services: const <CivicService>[],
            error: 'Unexpected response shape from server.',
          );
        }
        final raw = data['services'];
        if (raw is! List) {
          return (
            services: const <CivicService>[],
            error: 'Unexpected response shape from server.',
          );
        }
        final list = <CivicService>[];
        for (final item in raw) {
          if (item is Map<String, dynamic>) {
            try {
              list.add(CivicService.fromJson(item));
            } catch (e, st) {
              assert(() {
                debugPrint('fetchServices skip row: $e\n$st');
                return true;
              }());
            }
          }
        }
        return (services: list, error: null);
      }

      final message = _messageFromErrorJson(json) ??
          'Could not load services (${response.statusCode}).';
      return (services: const <CivicService>[], error: message);
    } on TimeoutException {
      return (
        services: const <CivicService>[],
        error: 'Request timed out. Check your connection and try again.',
      );
    } on http.ClientException catch (e, st) {
      assert(() {
        debugPrint('ApiService.fetchServices ClientException: $e\n$st');
        return true;
      }());
      return (
        services: const <CivicService>[],
        error: 'Could not reach the server. Check the API address and your network.',
      );
    } catch (e, st) {
      assert(() {
        debugPrint('ApiService.fetchServices: $e\n$st');
        return true;
      }());
      return (
        services: const <CivicService>[],
        error: 'Something went wrong. Please try again.',
      );
    }
  }

  static Map<String, dynamic>? _tryDecodeJsonObject(String body) {
    if (body.isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  static String? _messageFromErrorJson(Map<String, dynamic>? json) {
    final err = json?['error'];
    if (err is Map<String, dynamic>) {
      final m = err['message'];
      if (m is String && m.trim().isNotEmpty) return m.trim();
    }
    return null;
  }
}
