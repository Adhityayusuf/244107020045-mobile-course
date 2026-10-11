import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'models/post.dart';

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
