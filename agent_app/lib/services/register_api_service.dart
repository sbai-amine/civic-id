import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

sealed class RegisterResult {
  const RegisterResult();
}

final class RegisterSuccess extends RegisterResult {
  const RegisterSuccess({required this.nationalId});
  final String nationalId;
}

final class RegisterFailure extends RegisterResult {
  const RegisterFailure(this.message);
  final String message;
}

/// POST `/register` — used only by the simulated issuance demo. Lives in the
/// verifier app behind a debug flag; never reachable from the citizen build.
class RegisterApiService {
  RegisterApiService({http.Client? httpClient, String? baseUrl})
      : _client = httpClient ?? http.Client(),
        _baseUrl = (baseUrl ?? ApiConfig.baseUrl).replaceAll(RegExp(r'/+$'), '');

  final http.Client _client;
  final String _baseUrl;

  Future<RegisterResult> register({
    required String nationalId,
    required String fullName,
    required String pin,
  }) async {
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
              'nationalID': nationalId.trim(),
              'fullName': fullName.trim(),
              'PIN': pin.trim(),
            }),
          )
          .timeout(const Duration(seconds: 30));

      Map<String, dynamic>? json;
      try {
        json = response.body.isEmpty
            ? null
            : jsonDecode(response.body) as Map<String, dynamic>?;
      } catch (e, st) {
        assert(() {
          debugPrint('RegisterApiService JSON decode: $e\n$st');
          return true;
        }());
        return const RegisterFailure('Invalid response from server.');
      }

      if (response.statusCode == 201 && json?['success'] == true) {
        return RegisterSuccess(nationalId: nationalId);
      }

      final err = json?['error'];
      if (err is Map<String, dynamic> && err['message'] is String) {
        return RegisterFailure((err['message'] as String).trim());
      }
      return RegisterFailure('Registration failed (${response.statusCode}).');
    } on TimeoutException {
      return const RegisterFailure('Request timed out.');
    } on http.ClientException catch (e, st) {
      assert(() {
        debugPrint('RegisterApiService ClientException: $e\n$st');
        return true;
      }());
      return const RegisterFailure('Could not reach the server.');
    } catch (e, st) {
      assert(() {
        debugPrint('RegisterApiService: $e\n$st');
        return true;
      }());
      return const RegisterFailure('Something went wrong.');
    }
  }
}
