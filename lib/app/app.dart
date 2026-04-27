import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../i18n/app_i18n.dart';
import '../screens/dashboard_screen.dart';
import '../screens/government_issuance_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/admin_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/qr_history_screen.dart';
import '../screens/services_screen.dart';
import '../screens/splash_screen.dart';
import '../services/app_settings.dart';
import '../services/biometric_auth_service.dart';
import '../services/locale_controller.dart';
import '../services/token_storage.dart';
import '../utils/app_routes.dart';

/// Root widget: theme, routing, and Material design shell.
class BridgeIdApp extends StatefulWidget {
  const BridgeIdApp({super.key, this.navigatorKey});

  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  State<BridgeIdApp> createState() => _BridgeIdAppState();
}

class _BridgeIdAppState extends State<BridgeIdApp> with WidgetsBindingObserver, _SessionResumeLock {
  final LocaleController _locale = LocaleController.instance;

  @override
  void initState() {
    super.initState();
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
    onAppLifecycleForLock(state, widget.navigatorKey, () => setState(() {}));
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
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD3DBEA)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD3DBEA)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF0F4CBA), width: 1.4),
          ),
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 4,
          shadowColor: const Color(0x1A0B1324),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.govIssuance: (_) => const GovernmentIssuanceScreen(),
        AppRoutes.dashboard: (_) => const DashboardScreen(),
        AppRoutes.services: (_) => const ServicesScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.qrHistory: (_) => const QrHistoryScreen(),
        AppRoutes.admin: (_) => const AdminScreen(),
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
  ) async {
    if (kIsWeb) return;
    if (state == AppLifecycleState.paused) {
      _lastPause = DateTime.now();
      return;
    }
    if (state != AppLifecycleState.resumed) return;
    if (_lastPause == null) return;
    if (DateTime.now().difference(_lastPause!) < const Duration(seconds: 1)) {
      return;
    }

    final need = await AppSettings().requireBiometricOnAppOpen;
    if (!need) return;
    final t = await SecureTokenStorage().readAccessToken();
    if (t == null || t.isEmpty) return;

    final ok = await BiometricAuthService().authenticate(reason: 'Unlock BridgeID');
    if (!ok && mounted) {
      await SecureTokenStorage().clearSession();
      navKey?.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.login,
        (r) => false,
      );
    }
  }
}
