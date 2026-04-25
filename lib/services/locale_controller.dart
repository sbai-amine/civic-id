import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'app_settings.dart';

class LocaleController extends ChangeNotifier {
  LocaleController({AppSettings? settings}) : _settings = settings ?? AppSettings();

  static final LocaleController instance = LocaleController();

  final AppSettings _settings;
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> load() async {
    final code = await _settings.preferredLocaleCode;
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocaleCode(String code) async {
    if (_locale.languageCode == code) return;
    _locale = Locale(code);
    await _settings.setPreferredLocaleCode(code);
    notifyListeners();
  }
}
