import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite singleton for the citizen app (offline QR outbox + history).
class AppDatabase {
  AppDatabase._();

  static const _fileName = 'civickey.db';
  static const _version = 3;

  static Database? _instance;

  static Future<Database> instance() async {
    if (_instance != null) return _instance!;
    final dir = await getDatabasesPath();
    final path = join(dir, _fileName);
    _instance = await openDatabase(
      path,
      version: _version,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE local_service_qr (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            national_id TEXT NOT NULL DEFAULT '',
            service_id TEXT NOT NULL,
            service_name TEXT NOT NULL,
            payload TEXT NOT NULL,
            content_hash TEXT NOT NULL,
            created_at TEXT NOT NULL,
            sync_status TEXT NOT NULL DEFAULT 'pending',
            last_error TEXT,
            retry_count INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE local_service_qr ADD COLUMN content_hash TEXT');
          await db.execute('ALTER TABLE local_service_qr ADD COLUMN last_error TEXT');
          await db.execute(
            'ALTER TABLE local_service_qr ADD COLUMN retry_count INTEGER NOT NULL DEFAULT 0',
          );
        }
        if (oldVersion < 3) {
          // Existing rows get empty national_id — they become invisible to
          // all users, which is the safest default since we can't tell who
          // created them.
          await db.execute(
            "ALTER TABLE local_service_qr ADD COLUMN national_id TEXT NOT NULL DEFAULT ''",
          );
        }
      },
    );
    return _instance!;
  }

  static Future<void> closeForTest() async {
    if (_instance != null) {
      await _instance!.close();
      _instance = null;
    }
  }
}
