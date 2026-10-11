import '../../../../core/failures.dart';
import '../entities/note.dart';

/// Kontrak yang dibutuhkan domain. Hidup di `domain` agar domain tidak
/// bergantung pada Dio/SQLite; layer data yang mengimplementasikannya.
///
/// Sukses/gagal eksplisit via *record* Dart: presentation menerima
/// [Failure] berisi pesan ramah, bukan exception yang bocor.
abstract class NoteRepository {
  Future<({List<Note> notes, Failure? failure})> fetchNotes();

  Future<({Note? note, Failure? failure})> findNote(int id);

  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  });

  Future<Failure?> deleteNote(int id);

  Future<({int count, Failure? failure})> countDirty();

  Future<Failure?> markAllSynced();
}
