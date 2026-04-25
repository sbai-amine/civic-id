import 'package:flutter/widgets.dart';

class AppI18n {
  AppI18n._();

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
    Locale('fr'),
    Locale('tzm'),
  ];

  static const Map<String, Map<String, String>> _dictionary = {
    'en': {
      'home.title': 'BridgeID Verifier',
      'shell.brand': 'BridgeID',
      'home.verifyQr': 'Verify service QR',
      'home.subtitle': 'Scan a QR from the citizen app. When online, sync pending scans to the server.',
      'home.offlineScans': 'Offline scans',
      'home.pending': 'Pending',
      'home.syncing': 'Syncing',
      'home.synced': 'Synced',
      'home.failed': 'Failed',
      'home.syncNow': 'Sync now',
      'home.retryFailed': 'Retry failed',
      'home.resetQueue': 'Reset queue',
      'home.deleteSynced': 'Delete synced records',
      'home.clearLocal': 'Clear all local data',
      'home.scanQr': 'Scan QR code',
      'home.nothingPending': 'Nothing pending to upload.',
      'home.syncedCount': 'Uploaded {count} scan(s). Marked as synced.',
      'home.deleteSyncedTitle': 'Delete synced?',
      'home.deleteSyncedBody': 'This removes all rows already uploaded (synced). Pending scans are kept.',
      'home.clearAllTitle': 'Clear all data?',
      'home.clearAllBody': 'Removes every stored scan on this device.',
      'common.cancel': 'Cancel',
      'common.delete': 'Delete',
      'common.clearAll': 'Clear all',
      'scan.title': 'Scan QR',
      'scan.gallery': 'Gallery',
      'scan.torch': 'Torch',
      'scan.tip': 'Use torch or pick a photo. QR closes this screen automatically.',
      'scan.noQr': 'No QR found in that image.',
      'scan.imageError': 'Could not read image: {error}',
      'result.title': 'Scan result',
      'result.notSaved': 'Not saved for sync: {reason}',
      'result.stored': 'Stored on this device - pending sync when online.',
      'result.decoded': 'Decoded data',
      'result.userId': 'User ID',
      'result.timestamp': 'Timestamp',
      'result.couldNotRead': 'Could not read payload',
      'result.expected':
          'Expected JSON with string fields userID and timestamp (same format as the BridgeID citizen app).',
      'result.raw': 'Raw value',
      'result.testPayload': 'Test / manual payload',
      'result.override': 'Override raw string',
      'result.savedTestRow': 'Saved extra test row to local DB',
      'result.saveAdditional': 'Save as additional test row',
      'result.done': 'Done',
      'result.persistError': 'Could not save this scan to the local database. The result is still shown above.',
    },
    'ar': {},
    'fr': {},
    'tzm': {},
  };

  static String t(BuildContext context, String key) {
    final code = Localizations.localeOf(context).languageCode;
    return _dictionary[code]?[key] ?? _dictionary['en']![key] ?? key;
  }

  static String tf(BuildContext context, String key, {Map<String, String> args = const {}}) {
    var value = t(context, key);
    args.forEach((k, v) {
      value = value.replaceAll('{$k}', v);
    });
    return value;
  }
}
