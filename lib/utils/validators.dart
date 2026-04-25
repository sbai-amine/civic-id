/// Client-side checks before calling the (mock) API.
///
/// Requirement: fields must not be empty when the user taps Log in.
abstract final class Validators {
  /// Returns an error message if empty, otherwise `null`.
  static String? nationalId(String? value) {
    if ((value?.trim() ?? '').isEmpty) {
      return 'National ID cannot be empty';
    }
    return null;
  }

  /// Returns an error message if empty, otherwise `null`.
  static String? pin(String? value) {
    if ((value?.trim() ?? '').isEmpty) {
      return 'PIN cannot be empty';
    }
    return null;
  }
}
