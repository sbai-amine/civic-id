/// Backend base URL (no trailing slash).
///
/// Override at run time, e.g. Android emulator to host machine:
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000`
abstract final class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3000',
  );
}
