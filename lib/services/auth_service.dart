import '../models/login_credentials.dart';
import '../models/sign_in_result.dart';
import 'api_service.dart';

/// Authentication boundary — implemented by [RemoteAuthService] (HTTP).
abstract class AuthService {
  Future<SignInResult> signIn(LoginCredentials credentials);
}

/// Calls the real backend via [ApiService].
class RemoteAuthService implements AuthService {
  RemoteAuthService({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;

  @override
  Future<SignInResult> signIn(LoginCredentials credentials) {
    return _api.login(credentials);
  }
}
