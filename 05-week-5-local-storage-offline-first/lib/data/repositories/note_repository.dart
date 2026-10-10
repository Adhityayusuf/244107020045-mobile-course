import 'package:sqflite/sqflite.dart';

import '../local/db.dart';
import '../local/note.dart';

/// Satu-satunya pintu ke tabel `notes`. UI tidak pernah menyentuh SQLite
/// langsung; mereka hanya membaca provider yang memanggil repository ini.
///
/// Konstruktor menerima `openDb` agar test dapat menyuntikkan database
/// palsu/in-memory tanpa memakai SQLite sungguhan.
class NoteRepository {
  NoteRepository({Future<Database> Function()? openDb})
      : _openDb = openDb ?? openNotesDb;

  final Future<Database> Function() _openDb;

  /// Ekspos factory pembuka database agar penyimpana cache posts
  /// (sqflite-backed) dapat memakai database yang sama.
  Future<Database> Function() get openDb => _openDb;

  Future<List<Note>> fetchNotes() async {
    final db = await _openDb();
    final rows = await db.query('notes', orderBy: 'updated_at DESC');
    return rows.map(Note.fromMap).toList();
  }

  Future<Note?> findNote(int id) async {
    final db = await _openDb();
    final rows =
        await db.query('notes', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Note.fromMap(rows.first);
  }

  /// Menyimpan catatan baru. Selalu ditandai `dirty` karena belum tersinkron.
  Future<Note> addNote({required String title, String body = ''}) async {
    final db = await _openDb();
    final note = Note(
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    final id = await db.insert('notes', note.toMap());
    return Note(
      id: id,
      title: note.title,
      body: note.body,
      updatedAt: note.updatedAt,
      dirty: true,
    );
  }

  Future<void> deleteNote(int id) async {
    final db = await _openDb();
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  /// Jumlah catatan yang belum tersinkron (basis antrean + badge UI).
  Future<int> countDirty() async {
    final db = await _openDb();
    final rows =
        await db.rawQuery('SELECT COUNT(*) AS c FROM notes WHERE dirty = 1');
    return (rows.first['c'] as num?)?.toInt() ?? 0;
  }

  /// Menandai semua catatan bersih. Dipanggil HANYA setelah sinkronisasi
  /// sukses, agar badge tidak kembali nol secara prematur.
  Future<void> markAllSynced() async {
    final db = await _openDb();
    await db.update('notes', {'dirty': 0}, where: 'dirty = 1');
  }
}
