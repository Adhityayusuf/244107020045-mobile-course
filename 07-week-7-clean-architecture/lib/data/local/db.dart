import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Nama file database. Dipakai satu konsolidasi di seluruh repository.
const String kNotesDbName = 'offline_notes.db';

/// Membuka (dan membuat skema bila perlu) database catatan offline.
///
/// Satu fungsi pembuka dipakai seluruh repository agar skema terpusat.
/// Pada platform web, factory harus disiapkan dulu (lihat
/// `notes_database_factory.dart`).
Future<Database> openNotesDb() async {
  final dir = await getDatabasesPath();
  return openDatabase(
    p.join(dir, kNotesDbName),
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE notes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          body TEXT NOT NULL DEFAULT '',
          updated_at TEXT NOT NULL,
          dirty INTEGER NOT NULL DEFAULT 0
        )
      ''');
      // Tabel cache untuk pola cache-first read data API.
      await db.execute('''
        CREATE TABLE cached_posts(
          id INTEGER PRIMARY KEY,
          payload TEXT NOT NULL,
          cached_at TEXT NOT NULL
        )
      ''');
    },
  );
}
