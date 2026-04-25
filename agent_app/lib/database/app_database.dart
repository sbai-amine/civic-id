import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite for the Agent app (offline scan inbox).
class AgentAppDatabase {
  AgentAppDatabase._();

  static const _fileName = 'civickey_agent.db';
  static const _version = 4;

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
          CREATE TABLE local_scans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            raw_payload TEXT NOT NULL,
            user_id TEXT,
            payload_timestamp TEXT,
            parse_ok INTEGER NOT NULL,
            scanned_at TEXT NOT NULL,
            content_hash TEXT,
            sync_status TEXT NOT NULL DEFAULT 'pending',
            last_error TEXT,
            retry_count INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE qr_nonce_cache (
            nonce TEXT NOT NULL PRIMARY KEY,
            seen_at TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          await db.execute('ALTER TABLE local_scans ADD COLUMN content_hash TEXT');
        }
        if (oldV < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS qr_nonce_cache (
              nonce TEXT NOT NULL PRIMARY KEY,
              seen_at TEXT NOT NULL
            )
          ''');
        }
        if (oldV < 4) {
          await db.execute('ALTER TABLE local_scans ADD COLUMN last_error TEXT');
          await db.execute(
            'ALTER TABLE local_scans ADD COLUMN retry_count INTEGER NOT NULL DEFAULT 0',
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
