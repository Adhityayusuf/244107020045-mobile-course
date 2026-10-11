import 'package:week7_notes_clean/core/failures.dart';
import 'package:week7_notes_clean/features/notes/domain/entities/note.dart';
import 'package:week7_notes_clean/features/notes/domain/repositories/note_repository.dart';

/// Repository palsu: mengimplementasikan kontrak domain tanpa SQLite.
class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({this.items = const [], this.fail = false});

  final List<Note> items;
  final bool fail;

  LocalFailure get _error => const LocalFailure('db locked (simulasi)');

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    if (fail) return (notes: const <Note>[], failure: _error);
    return (notes: items, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> findNote(int id) async {
    for (final n in items) {
      if (n.id == id) return (note: n, failure: null);
    }
    return (note: null, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    final note = Note(
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    return (note: note, failure: null);
  }

  @override
  Future<Failure?> deleteNote(int id) async => null;

  @override
  Future<({int count, Failure? failure})> countDirty() async {
    return (count: items.where((n) => n.dirty).length, failure: null);
  }

  @override
  Future<Failure?> markAllSynced() async => null;
}
