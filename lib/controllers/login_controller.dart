import 'package:flutter/foundation.dart';

import '../models/login_credentials.dart';
import '../models/sign_in_result.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';

/// Holds login UI state: loading flag and last error from the API.
///
/// On successful sign-in, persists the JWT via [SecureTokenStorage].
class LoginController extends ChangeNotifier {
  LoginController({
    AuthService? authService,
    SecureTokenStorage? tokenStorage,
  })  : _authService = authService ?? RemoteAuthService(),
        _tokenStorage = tokenStorage ?? SecureTokenStorage();

  final AuthService _authService;
  final SecureTokenStorage _tokenStorage;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Clears the inline error (e.g. when the user edits a field).
  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Validates with server, stores JWT on success, updates loading/errors.
  Future<SignInResult> signIn(LoginCredentials credentials) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.signIn(credentials);

      if (result is SignInFailure) {
        _errorMessage = result.message;
        return result;
      }

      if (result is SignInSuccess) {
        try {
          await _tokenStorage.saveAccessToken(result.accessToken);
          await _tokenStorage.saveRefreshToken(result.refreshToken);
          await _tokenStorage.saveUserId(credentials.nationalId.trim());
          await _tokenStorage.saveQrHmacKey(result.qrHmacKey);
        } catch (e, st) {
          assert(() {
            debugPrint('LoginController token save: $e\n$st');
            return true;
          }());
          try {
            await _tokenStorage.clearSession();
          } catch (_) {}
          const message =
              'Could not save your session securely. Please try again.';
          _errorMessage = message;
          return const SignInFailure(message);
        }
      }

      return result;
    } catch (e, st) {
      assert(() {
        debugPrint('LoginController.signIn: $e\n$st');
        return true;
      }());
      const message = 'Something went wrong. Please try again.';
      _errorMessage = message;
      return const SignInFailure(message);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
