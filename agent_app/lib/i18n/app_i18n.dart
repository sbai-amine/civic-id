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
      'home.offlineScans': 'Scan uploads',
      'home.pending': 'Waiting to upload',
      'home.syncing': 'Uploading',
      'home.synced': 'Uploaded',
      'home.failed': "Couldn't upload",
      'home.syncNow': 'Upload now',
      'home.retryFailed': 'Retry failed uploads',
      'home.resetQueue': 'Reset upload queue',
      'home.deleteSynced': 'Delete uploaded records',
      'home.clearLocal': 'Clear all local data',
      'home.scanQr': 'Scan QR code',
      'home.nothingPending': 'Nothing waiting to upload.',
      'home.syncedCount': 'Uploaded {count} scan(s).',
      'home.deleteSyncedTitle': 'Delete uploaded records?',
      'home.deleteSyncedBody':
          'Removes scans already uploaded to the server from this device. Waiting scans are kept. The server copy is the audit trail.',
      'home.clearAllTitle': 'Clear all local data?',
      'home.clearAllBody':
          'Removes every stored scan on this device, including ones that have not yet been uploaded. This cannot be undone.',
      'home.operator.label': 'Active operator',
      'home.operator.unnamed': '(unnamed device)',
      'home.operator.switch': 'Switch',
      'home.authError.title': 'Agent key not accepted',
      'home.authError.body':
          'The server rejected this device\'s key. Replace it with one issued for this backend.',
      'home.authError.replaceKey': 'Replace key',
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
      'result.revealId': 'Reveal',
      'result.hideId': 'Hide',
      'settings.localData.title': 'Local data',
      'settings.localData.subtitle':
          'Destructive actions on this device. The server copy is the audit trail.',
      'settings.deleteSynced': 'Delete uploaded records',
      'settings.clearAll': 'Clear all local data',
      'settings.confirmReason': 'Reason (required)',
      'settings.confirmReasonHint': 'Why are you wiping data on this device?',
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
