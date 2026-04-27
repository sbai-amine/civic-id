abstract final class Validators {
  static String? nationalId(String? value) {
    if ((value?.trim() ?? '').isEmpty) return 'National ID cannot be empty';
    return null;
  }

  static String? pin(String? value) {
    if ((value?.trim() ?? '').isEmpty) return 'PIN cannot be empty';
    return null;
  }

  static String? fullName(String? value) {
    if ((value?.trim() ?? '').isEmpty) return 'Full name cannot be empty';
    return null;
  }

  /// Stricter PIN validator for registration: 4–6 numeric digits.
  static String? newPin(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'PIN cannot be empty';
    if (v.length < 4 || v.length > 6) return 'PIN must be 4–6 digits';
    if (!RegExp(r'^\d+$').hasMatch(v)) return 'PIN must contain only digits';
    return null;
  }

  static String? confirmPin(String? value, String pin) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please confirm your PIN';
    if (v != pin.trim()) return 'PINs do not match';
    return null;
  }
}
