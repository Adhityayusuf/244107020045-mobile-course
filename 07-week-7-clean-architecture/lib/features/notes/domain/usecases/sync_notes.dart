import '../../../../core/failures.dart';
import '../repositories/note_repository.dart';

/// Antrean sinkronisasi catatan kotor (dirty flag).
///
/// Backend tulis belum tersedia sehingga "server" disimulasikan dengan
/// delay. Aturan bisnis yang dijaga: catatan ditandai bersih HANYA setelah
/// "server" menjawab sukses. Konflik: *last-write-wins* `updated_at`.
/// Mengembalikan jumlah catatan yang tersinkron.
class SyncNotes {
  const SyncNotes(
    this._repository, {
    this.delay = const Duration(seconds: 1),
  });

  final NoteRepository _repository;
  final Duration delay;

  Future<({int synced, Failure? failure})> call() async {
    final dirty = await _repository.countDirty();
    if (dirty.failure != null) {
      return (synced: 0, failure: dirty.failure);
    }
    if (dirty.count == 0) return (synced: 0, failure: null);
    // Simulasi upload ke REST API.
    await Future<void>.delayed(delay);
    final mark = await _repository.markAllSynced();
    if (mark != null) return (synced: 0, failure: mark);
    return (synced: dirty.count, failure: null);
  }
}
