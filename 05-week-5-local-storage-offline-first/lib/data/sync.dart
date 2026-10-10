import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'models/post.dart';
import 'repositories/note_repository.dart';

/// Antrean sinkronisasi catatan kotor (dirty flag).
///
/// Backend tulis belum tersedia, sehingga "server" disimulasikan dengan
/// delay. Yang dinilai adalah **mekanismenya**, bukan servernya.
/// Konstran konflik: *last-write-wins* berdasarkan `updated_at`
/// (dokumentasi di README).
Future<int> syncNotes(
  NoteRepository repo, {
  Duration delay = const Duration(seconds: 1),
}) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  // Simulasi upload ke REST API.
  await Future<void>.delayed(delay);
  // Tandai bersih HANYA setelah "server" menjawab sukses.
  await repo.markAllSynced();
  return dirtyCount;
}

/// Abstraksi penyimpanan cache posts untuk pola cache-first read.
/// Di-backing-in oleh SQLite (native) atau in-memory (web/test/demo).
abstract class PostCacheStore {
  Future<List<Post>> load();
  Future<void> save(List<Post> posts);
}

/// Penyimpanan in-memory: dipakai di web, test, dan demo screenshot.
class InMemoryPostCacheStore implements PostCacheStore {
  List<Post> _items = const [];

  @override
  Future<List<Post>> load() async => _items;

  @override
  Future<void> save(List<Post> posts) async => _items = List.of(posts);
}

/// Penyimpanan berbasis tabel `cached_posts` di SQLite (native).
class SqflitePostCacheStore implements PostCacheStore {
  SqflitePostCacheStore(this._openDb);
  final Future<Database> Function() _openDb;

  @override
  Future<List<Post>> load() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts');
    return rows
        .map(
          (row) => Post.fromJson(
            (jsonDecode(row['payload'] as String) as Map).cast<String, dynamic>(),
          ),
        )
        .toList();
  }

  @override
  Future<void> save(List<Post> posts) async {
    final db = await _openDb();
    await db.transaction((txn) async {
      await txn.delete('cached_posts');
      for (final post in posts) {
        await txn.insert('cached_posts', {
          'id': post.id,
          'payload': post.toJsonString(),
          'cached_at': DateTime.now().toIso8601String(),
        });
      }
    });
  }
}
