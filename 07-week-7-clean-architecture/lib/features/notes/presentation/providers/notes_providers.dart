import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/db.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/sync_notes.dart';

/// Satu-satunya tempat wiring DI fitur notes: implementasi disuntikkan
/// ke use case, use case ke notifier. Widget tidak pernah
/// `new Repository()` sendiri.
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(openDb: openNotesDb);
});

final getNotesProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});

final addNoteProvider = Provider<AddNote>((ref) {
  return AddNote(ref.watch(noteRepositoryProvider));
});

final syncNotesProvider = Provider<SyncNotes>((ref) {
  return SyncNotes(ref.watch(noteRepositoryProvider));
});

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
  // Nonaktifkan retry otomatis Riverpod 3 agar error langsung final.
  retry: (retryCount, error) => null,
);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    final result = await ref.watch(getNotesProvider).call();
    if (result.failure != null) throw Exception(result.failure!.message);
    return result.notes;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final result = await ref.read(getNotesProvider).call();
      if (result.failure != null) throw Exception(result.failure!.message);
      state = AsyncValue.data(result.notes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add({required String title, String body = ''}) async {
    final result =
        await ref.read(addNoteProvider).call(title: title, body: body);
    if (result.failure != null) {
      state = AsyncValue.error(
        Exception(result.failure!.message),
        StackTrace.current,
      );
      return;
    }
    await refresh();
  }

  Future<void> remove(int id) async {
    final failure = await ref.read(noteRepositoryProvider).deleteNote(id);
    if (failure != null) {
      state = AsyncValue.error(Exception(failure.message), StackTrace.current);
      return;
    }
    await refresh();
  }

  /// Menjalankan antrean sinkronisasi lalu memperbarui daftar.
  /// Mengembalikan jumlah catatan yang baru tersinkron.
  Future<int> sync() async {
    final result = await ref.read(syncNotesProvider).call();
    if (result.failure != null) {
      state = AsyncValue.error(
        Exception(result.failure!.message),
        StackTrace.current,
      );
      return 0;
    }
    await refresh();
    return result.synced;
  }
}

/// Badge antrean: jumlah catatan yang belum tersinkron.
final dirtyCountProvider = FutureProvider<int>((ref) async {
  final result = await ref.watch(noteRepositoryProvider).countDirty();
  if (result.failure != null) throw Exception(result.failure!.message);
  return result.count;
});

/// Detail satu catatan dari repository (bukan state list).
final noteDetailProvider = FutureProvider.family<Note?, int>((ref, id) async {
  final result = await ref.watch(noteRepositoryProvider).findNote(id);
  if (result.failure != null) throw Exception(result.failure!.message);
  return result.note;
});
