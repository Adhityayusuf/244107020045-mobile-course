import 'package:flutter_test/flutter_test.dart';
import 'package:week7_notes_clean/core/failures.dart';
import 'package:week7_notes_clean/features/notes/domain/entities/note.dart';
import 'package:week7_notes_clean/features/notes/domain/usecases/add_note.dart';
import 'package:week7_notes_clean/features/notes/domain/usecases/get_notes.dart';
import 'package:week7_notes_clean/features/notes/domain/usecases/sync_notes.dart';

import 'fakes.dart';

void main() {
  test('GetNotes meneruskan daftar dari repository', () async {
    final repo = FakeNoteRepository(items: [
      Note(title: 'A', updatedAt: DateTime(2026, 9, 27)),
    ]);
    final result = await GetNotes(repo).call();
    expect(result.failure, isNull);
    expect(result.notes.length, 1);
    expect(result.notes.first.title, 'A');
  });

  test('GetNotes meneruskan failure tanpa melempar', () async {
    final repo = FakeNoteRepository(fail: true);
    final result = await GetNotes(repo).call();
    expect(result.failure, isA<LocalFailure>());
    expect(result.notes, isEmpty);
  });

  test('AddNote menolak judul kosong tanpa menyentuh database', () async {
    final repo = FakeNoteRepository();
    final result = await AddNote(repo).call(title: '   ');
    expect(result.note, isNull);
    expect(result.failure, isA<ValidationFailure>());
  });

  test('AddNote menyimpan judul valid sebagai dirty', () async {
    final repo = FakeNoteRepository();
    final result =
        await AddNote(repo).call(title: 'Belanja', body: 'susu');
    expect(result.failure, isNull);
    expect(result.note!.title, 'Belanja');
    expect(result.note!.dirty, isTrue);
  });

  test('SyncNotes menandai bersih dan melaporkan jumlah', () async {
    final repo = FakeNoteRepository(items: [
      Note(id: 1, title: 'a', updatedAt: DateTime.now(), dirty: true),
      Note(id: 2, title: 'b', updatedAt: DateTime.now(), dirty: false),
    ]);
    final result =
        await SyncNotes(repo, delay: Duration.zero).call();
    expect(result.failure, isNull);
    expect(result.synced, 1);
  });

  test('SyncNotes nol bila tidak ada yang kotor', () async {
    final repo = FakeNoteRepository(items: [
      Note(id: 1, title: 'a', updatedAt: DateTime.now()),
    ]);
    final result =
        await SyncNotes(repo, delay: Duration.zero).call();
    expect(result.failure, isNull);
    expect(result.synced, 0);
  });
}
