import 'package:flutter/widgets.dart';

class AppI18n {
  AppI18n._();

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
    Locale('fr'),
    Locale('tzm'),
  ];

  static const languageOptions = <({String code, String label})>[
    (code: 'en', label: 'English'),
    (code: 'ar', label: 'Arabic'),
    (code: 'fr', label: 'Français'),
    (code: 'tzm', label: 'Tamazight (Latin)'),
  ];

  static const Map<String, Map<String, String>> _dictionary = {
    'en': {
      'common.retry': 'Retry',
      'common.refresh': 'Refresh',
      'common.cancel': 'Cancel',
      'common.delete': 'Delete',
      'common.ok': 'OK',
      'common.done': 'Done',
      'common.signOut': 'Sign out',
      'app.name': 'BridgeID',
      'nav.profile': 'Profile',
      'nav.qrHistory': 'QR history',
      'app.tagline': 'Your civic access, simplified.',
      'form.nationalId.label': 'National ID',
      'form.nationalId.hint': 'Enter your national ID',
      'form.pin.label': 'PIN',
      'form.pin.hint': 'Enter your PIN',
      'form.pin.show': 'Show PIN',
      'form.pin.hide': 'Hide PIN',
      'profile.title': 'Profile',
      'profile.lastSync': 'Last sync',
      'profile.never': 'Never',
      'profile.appVersion': 'App version',
      'profile.nationalId': 'National ID',
      'profile.bioOpen': 'Lock with biometrics on open',
      'profile.bioSync': 'Require biometrics to sync',
      'profile.appLanguage': 'App language',
      'services.title': 'Services',
      'serviceQr.title': 'Service QR',
      'serviceQr.description':
          'Generate a QR code that encodes your user ID and the current time (UTC).',
      'serviceQr.generate': 'Generate QR',
      'serviceQr.payloadHint': 'Scanning decodes JSON with userID and timestamp.',
      'serviceQr.savedPending': 'Saved on this device - pending sync when online.',
      'serviceQr.missingUser': 'No saved user ID. Sign out and sign in again, then try once more.',
      'sync.nothingPending': 'Nothing pending to upload.',
      'sync.alreadySynced': 'Everything is already synced.',
      'sync.uploadedRecords': 'Uploaded {count} record(s).',
      'sync.syncedRecords': 'Synced {count} record(s).',
      'sync.failedToPending': 'Failed rows moved back to pending queue.',
      'sync.queueReset': 'Queue normalized. Retry counters reset.',
      'login.title': 'Sign in',
      'login.subtitle': 'Use your national ID and PIN to continue.',
      'login.button': 'Log in',
      'dashboard.welcome': 'Welcome back',
      'dashboard.hero.subtitle':
          'Manage your civic services and keep your offline records synced.',
      'dashboard.pending': 'Pending',
      'dashboard.syncing': 'Syncing',
      'dashboard.synced': 'Synced',
      'dashboard.failed': 'Failed',
      'dashboard.retryFailed': 'Retry failed',
      'dashboard.syncNow': 'Sync now',
      'dashboard.resetQueue': 'Reset queue',
      'dashboard.services.title': 'Services',
      'dashboard.services.subtitle':
          'Browse official services, fees, and required documents.',
      'dashboard.recent.title': 'Recent activity',
      'dashboard.recent.empty': 'No activity yet. Generate your first service QR.',
      'dashboard.browseServices': 'View all services',
      'services.notSignedIn': 'No saved session. Sign in again to load services.',
      'services.loadFailed': 'Could not load services',
      'services.empty': 'No services available',
      'services.goSignIn': 'Go to sign in',
      'serviceDetail.title': 'Service details',
      'serviceDetail.description': 'Description',
      'serviceDetail.fees': 'Fees',
      'serviceDetail.requiredDocs': 'Required documents',
      'serviceDetail.generateQr': 'Generate service QR',
      'serviceDetail.requestSigned': 'Request signed',
      'serviceDetail.signing': 'Signing...',
      'serviceDetail.signNow': 'Sign request digitally',
      'serviceDetail.signedCreated': 'Signed request created ({id})',
      'serviceDetail.signHint':
          'Creates a one-time code with your user ID and timestamp. You can sync it later from the dashboard.',
      'serviceQr.secureKeyMissing':
          'Sign out and sign in again to load a secure QR key for this account.',
      'serviceQr.saveFailed':
          'QR works offline, but saving to the local database failed. You can still show this code to an agent.',
      'serviceQr.scanTitle': 'Scan to verify identity',
      'history.refreshTooltip': 'Refresh',
      'history.empty': 'No saved QR records yet.\nGenerate one from a service.',
      'history.emptyPayload': '(empty payload)',
      'history.share': 'Export / share payload',
      'history.shareSubject': 'BridgeID QR - {name}',
      'admin.title': 'Admin Console',
      'admin.missingKey': 'Missing ADMIN_API_KEY. Run with --dart-define=ADMIN_API_KEY=...',
      'admin.users': 'Users',
      'admin.serviceRecords': 'Service Records',
      'admin.agentScans': 'Agent Scans',
      'admin.activeKeys': 'Active Keys',
      'admin.agentKeys': 'Agent Keys',
      'admin.logs': 'Audit Logs',
      'admin.noLogs': 'No logs found.',
      'admin.enable': 'Enable',
      'admin.disable': 'Disable',
      'admin.keyEnabled': 'Agent key enabled',
      'admin.keyDisabled': 'Agent key disabled',
      'admin.verifyDoc': 'Verify Signed Document',
      'admin.verifyDocId': 'Signed Document ID',
      'admin.verifySignature': 'Verify Signature',
      'admin.signatureValid': 'Signature valid: {ok}\nPayload hash: {hash}',
      'profile.language.title': 'Language',
      'profile.language.subtitle': 'Choose your preferred language for the app.',
      'profile.security': 'Security',
      'profile.bio.web': 'Biometric options are not available in the web build.',
      'profile.openAdmin': 'Open Admin Console',
    },
    'ar': {
      'common.retry': 'إعادة المحاولة',
      'common.refresh': 'تحديث',
      'common.cancel': 'إلغاء',
      'common.delete': 'حذف',
      'common.ok': 'موافق',
      'common.done': 'تم',
      'common.signOut': 'تسجيل الخروج',
      'app.name': 'BridgeID',
      'nav.profile': 'الملف الشخصي',
      'nav.qrHistory': 'سجل QR',
      'profile.language.title': 'اللغة',
      'profile.language.subtitle': 'اختر لغة التطبيق.',
      'profile.security': 'الأمان',
      'profile.bio.web': 'القياسات الحيوية غير متاحة على الويب.',
      'profile.openAdmin': 'لوحة الإدارة',
    },
    'fr': {
      'common.retry': 'Réessayer',
      'common.refresh': 'Actualiser',
      'common.cancel': 'Annuler',
      'common.delete': 'Supprimer',
      'common.ok': 'OK',
      'common.done': 'Terminer',
      'common.signOut': 'Se déconnecter',
      'app.name': 'BridgeID',
      'nav.profile': 'Profil',
      'nav.qrHistory': 'Historique QR',
      'profile.language.title': 'Langue',
      'profile.language.subtitle': 'Choisissez la langue de l’application.',
      'profile.security': 'Sécurité',
      'profile.bio.web': 'La biométrie n’est pas disponible sur le web.',
      'profile.openAdmin': 'Console d’administration',
    },
    'tzm': {
      'common.retry': 'Retry',
      'common.refresh': 'Refresh',
      'common.cancel': 'Cancel',
      'common.delete': 'Delete',
      'common.ok': 'OK',
      'common.done': 'Done',
      'common.signOut': 'Sign out',
      'app.name': 'BridgeID',
      'nav.profile': 'Profile',
      'nav.qrHistory': 'QR history',
      'profile.language.title': 'Tutlayt',
      'profile.language.subtitle': 'Fren tutlayt i tesbedded deg usnas.',
      'profile.security': 'Taɣellist',
      'profile.bio.web': 'Biometric ur tella ara deg web.',
      'profile.openAdmin': 'Tafelwit n unedbal',
    },
  };

  static String t(BuildContext context, String key) {
    final code = Localizations.localeOf(context).languageCode;
    return _dictionary[code]?[key] ?? _dictionary['en']![key] ?? key;
  }

  static String tf(
    BuildContext context,
    String key, {
    Map<String, String> args = const {},
  }) {
    var value = t(context, key);
    args.forEach((k, v) {
      value = value.replaceAll('{$k}', v);
    });
    return value;
  }
}
