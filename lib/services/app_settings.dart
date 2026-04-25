import 'package:shared_preferences/shared_preferences.dart';

/// User preferences (biometric toggles, etc.). Not secret data.
class AppSettings {
  static const _kBioApp = 'civickey.bio.app';
  static const _kBioSync = 'civickey.bio.sync';
  static const _kLocale = 'civickey.locale';

  Future<bool> get requireBiometricOnAppOpen async =>
      (await SharedPreferences.getInstance()).getBool(_kBioApp) ?? false;

  Future<void> setRequireBiometricOnAppOpen(bool v) async {
    (await SharedPreferences.getInstance()).setBool(_kBioApp, v);
  }

  Future<bool> get requireBiometricOnSync async =>
      (await SharedPreferences.getInstance()).getBool(_kBioSync) ?? false;

  Future<void> setRequireBiometricOnSync(bool v) async {
    (await SharedPreferences.getInstance()).setBool(_kBioSync, v);
  }

  Future<String> get preferredLocaleCode async =>
      (await SharedPreferences.getInstance()).getString(_kLocale) ?? 'en';

  Future<void> setPreferredLocaleCode(String localeCode) async {
    (await SharedPreferences.getInstance()).setString(_kLocale, localeCode);
  }
}
