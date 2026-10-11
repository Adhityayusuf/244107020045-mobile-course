import '../../../../core/failures.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// Mengambil daftar catatan (terurut `updated_at` terbaru oleh repository).
/// Tipis dan disengaja: menjadi satu pintu baca + seam untuk test.
class GetNotes {
  const GetNotes(this._repository);
  final NoteRepository _repository;

  Future<({List<Note> notes, Failure? failure})> call() {
    return _repository.fetchNotes();
  }
}
