import 'package:flutter_test/flutter_test.dart';
import 'package:civic_key/app/app.dart';
import 'package:civic_key/services/app_settings.dart';
import 'package:civic_key/services/token_storage.dart';
import 'package:civic_key/services/biometric_auth_service.dart';
import 'package:civic_key/utils/app_routes.dart';

class FakeAppSettings extends AppSettings {
  @override
  Future<bool> get requireBiometricOnAppOpen async => false;
}

class FakeTokenStorage extends SecureTokenStorage {
  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<void> clearSession() async {}
}

class FakeBiometricAuth extends BiometricAuthService {
  @override
  Future<bool> authenticate({required String reason}) async => true;

  @override
  Future<bool> get canUse async => true;
}

void main() {
  testWidgets('App loads login screen (skip splash)', (tester) async {
    await tester.pumpWidget(
      BridgeIdApp(
        initialTestRoute: AppRoutes.login, // 👈 key line
        appSettings: FakeAppSettings(),
        tokenStorage: FakeTokenStorage(),
        biometricAuthService: FakeBiometricAuth(),
      ),
    );

    await tester.pump();

    expect(find.text('Sign in'), findsOneWidget);
  });
}