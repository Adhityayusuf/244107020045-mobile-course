import 'dart:async';

import 'package:dio/dio.dart';

import 'local/note.dart';
import 'models/post.dart';
import 'network_errors.dart';
import 'prefs.dart';
import 'repositories/note_repository.dart';
import 'repositories/post_repository.dart';
import 'sync.dart';

// ---------------------------------------------------------------------------
// Data demo deterministik
// ---------------------------------------------------------------------------
List<Note> demoNotes({required int count, int dirtyCount = 0}) {
  return List.generate(
    count,
    (i) => Note(
      id: i + 1,
      title: 'Judul catatan ${i + 1}',
      body: 'Isi ringkas catatan ${i + 1} yang tersimpan di SQLite.',
      updatedAt: DateTime.now().subtract(Duration(minutes: (i + 1) * 5)),
      dirty: i < dirtyCount,
    ),
  );
}

List<Post> demoPosts(int count, {int startId = 1}) {
  return List.generate(
    count,
    (i) => Post(
      id: startId + i,
      userId: 1,
      title: 'Judul post ${startId + i}',
      body: 'Isi ringkas post ${startId + i} dari API dummy.',
    ),
  );
}

// ---------------------------------------------------------------------------
// Fake NoteRepository (tanpa SQLite)
// ---------------------------------------------------------------------------
class FakeNoteRepository extends NoteRepository {
  FakeNoteRepository({this.notes = const [], this.throwError = false})
      : super(openDb: () => throw UnimplementedError('tidak dipakai'));

  List<Note> notes;
  final bool throwError;
  int _nextId = 100;

  @override
  Future<List<Note>> fetchNotes() async {
    if (throwError) throw Exception('db locked (simulasi)');
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return notes;
  }

  @override
  Future<Note?> findNote(int id) async {
    for (final n in notes) {
      if (n.id == id) return n;
    }
    return null;
  }

  @override
  Future<Note> addNote({required String title, String body = ''}) async {
    final note = Note(
      id: _nextId++,
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    notes = [...notes, note];
    return note;
  }

  @override
  Future<void> deleteNote(int id) async {
    notes = [for (final n in notes) if (n.id != id) n];
  }

  @override
  Future<int> countDirty() async => notes.where((n) => n.dirty).length;

  @override
  Future<void> markAllSynced() async {
    notes = [
      for (final n in notes)
        if (n.dirty)
          Note(
            id: n.id,
            title: n.title,
            body: n.body,
            updatedAt: n.updatedAt,
            dirty: false,
          )
        else
          n,
    ];
  }
}

// ---------------------------------------------------------------------------
// Fake PostRepository (tanpa HTTP)
// ---------------------------------------------------------------------------
class FakePostRepository extends PostRepository {
  FakePostRepository({this.posts = const [], this.throwError = false})
      : super(Dio());

  final List<Post> posts;
  final bool throwError;

  @override
  Future<List<Post>> fetchPosts() async {
    if (throwError) {
      throw const OfflineException();
    }
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return posts;
  }
}

// ---------------------------------------------------------------------------
// Seed PostCacheStore (in-memory) untuk demo
// ---------------------------------------------------------------------------
class SeedPostCacheStore implements PostCacheStore {
  SeedPostCacheStore(this.items);
  final List<Post> items;

  @override
  Future<List<Post>> load() async => items;

  @override
  Future<void> save(List<Post> posts) async {}
}

// ---------------------------------------------------------------------------
// Fake PrefsRepository (in-memory, tanpa SharedPreferences)
// ---------------------------------------------------------------------------
class FakePrefsRepository extends PrefsRepository {
  FakePrefsRepository({this.darkMode = false, this.lastOpened}) : super();

  bool darkMode;
  String? lastOpened;

  @override
  Future<bool> getDarkMode() async => darkMode;

  @override
  Future<void> setDarkMode(bool value) async => darkMode = value;

  @override
  Future<void> markOpenedNow() async {
    lastOpened = DateTime.now().toIso8601String();
  }

  @override
  Future<String?> getLastOpened() async => lastOpened;
}
