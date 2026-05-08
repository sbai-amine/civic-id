import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../i18n/app_i18n.dart';
import '../screens/dashboard_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/qr_history_screen.dart';
import '../screens/services_screen.dart';
import '../screens/splash_screen.dart';
import '../services/app_settings.dart';
import '../services/biometric_auth_service.dart';
import '../services/citizen_sync_service.dart';
import '../services/locale_controller.dart';
import '../services/token_storage.dart';
import '../utils/app_routes.dart';

class BridgeIdApp extends StatefulWidget {
  const BridgeIdApp({
    super.key,
    this.navigatorKey,
    this.appSettings,
    this.tokenStorage,
    this.biometricAuthService,
    this.initialTestRoute, // 👈 NEW
  });

  final GlobalKey<NavigatorState>? navigatorKey;

  final AppSettings? appSettings;
  final SecureTokenStorage? tokenStorage;
  final BiometricAuthService? biometricAuthService;

  final String? initialTestRoute; // 👈 NEW

  @override
  State<BridgeIdApp> createState() => _BridgeIdAppState();
}

class _BridgeIdAppState extends State<BridgeIdApp>
    with WidgetsBindingObserver, _SessionResumeLock {
  final LocaleController _locale = LocaleController.instance;

  late final AppSettings _appSettings;
  late final SecureTokenStorage _tokenStorage;
  late final BiometricAuthService _biometric;

  @override
  void initState() {
    super.initState();

    _appSettings = widget.appSettings ?? AppSettings();
    _tokenStorage = widget.tokenStorage ?? SecureTokenStorage();
    _biometric = widget.biometricAuthService ?? BiometricAuthService();

    WidgetsBinding.instance.addObserver(this);
    _locale.addListener(_onLocaleChanged);
    _locale.load();
  }

  @override
  void dispose() {
    _locale.removeListener(_onLocaleChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    onAppLifecycleForLock(
      state,
      widget.navigatorKey,
      () => setState(() {}),
      _appSettings,
      _tokenStorage,
      _biometric,
    );
    if (state == AppLifecycleState.resumed) {
      // Fire-and-forget silent retry of pending QR uploads. The citizen never
      // sees the queue; if offline, it just leaves rows pending for next time.
      unawaited(CitizenSyncService.instance.trigger());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: widget.navigatorKey,
      title: 'BridgeID',
      debugShowCheckedModeBanner: false,
      locale: _locale.locale,
      supportedLocales: AppI18n.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),

      // 👇 THIS is the key change
      initialRoute: widget.initialTestRoute ?? AppRoutes.splash,

      routes: {
  if (widget.initialTestRoute == null)
    AppRoutes.splash: (_) => const SplashScreen(),

  AppRoutes.login: (_) => const LoginScreen(),
  AppRoutes.register: (_) => const RegisterScreen(),
  AppRoutes.dashboard: (_) => const DashboardScreen(),
  AppRoutes.services: (_) => const ServicesScreen(),
  AppRoutes.profile: (_) => const ProfileScreen(),
  AppRoutes.qrHistory: (_) => const QrHistoryScreen(),
},
    );
  }
}

mixin _SessionResumeLock on State<BridgeIdApp> {
  static DateTime? _lastPause;

  Future<void> onAppLifecycleForLock(
    AppLifecycleState state,
    GlobalKey<NavigatorState>? navKey,
    void Function() setState,
    AppSettings appSettings,
    SecureTokenStorage tokenStorage,
    BiometricAuthService biometric,
  ) async {
    if (kIsWeb) return;

    if (state == AppLifecycleState.paused) {
      _lastPause = DateTime.now();
      return;
    }

    if (state != AppLifecycleState.resumed) return;
    if (_lastPause == null) return;

    if (DateTime.now().difference(_lastPause!) <
        const Duration(seconds: 1)) {
      return;
    }

    final need = await appSettings.requireBiometricOnAppOpen;
    if (!need) return;

    final t = await tokenStorage.readAccessToken();
    if (t == null || t.isEmpty) return;

    final ok =
        await biometric.authenticate(reason: 'Unlock BridgeID');

    if (!ok && mounted) {
      await tokenStorage.clearSession();
      navKey?.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.login,
        (r) => false,
      );
    }
  }
}