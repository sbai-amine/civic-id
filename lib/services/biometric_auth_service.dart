import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

/// Fingerprint / face (skipped on web).
class BiometricAuthService {
  BiometricAuthService({LocalAuthentication? localAuth})
      : _local = localAuth ?? LocalAuthentication();

  final LocalAuthentication _local;

  Future<bool> get canUse async {
    if (kIsWeb) return false;
    try {
      if (!await _local.isDeviceSupported()) return false;
      final list = await _local.getAvailableBiometrics();
      return list.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Returns `true` if unlocked or if biometrics unavailable / disabled.
  Future<bool> authenticate({required String reason}) async {
    if (kIsWeb) return true;
    try {
      return _local.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e, st) {
      assert(() {
        debugPrint('BiometricAuthService: $e\n$st');
        return true;
      }());
      return false;
    }
  }
}
