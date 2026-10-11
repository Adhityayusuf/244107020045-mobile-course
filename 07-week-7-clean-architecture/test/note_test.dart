import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week7_notes_clean/core/format.dart';
import 'package:week7_notes_clean/features/notes/data/models/note_model.dart';
import 'package:week7_notes_clean/features/notes/domain/entities/note.dart';
import 'package:week7_notes_clean/features/notes/domain/repositories/note_repository.dart';
import 'package:week7_notes_clean/features/notes/presentation/providers/notes_providers.dart';

import 'fakes.dart';

void main() {
  test('fromMap aman terhadap field yang hilang', () {
    final note = NoteModel.fromMap({'title': 'Belanja'});
    expect(note.title, 'Belanja');
    expect(note.body, '');
    expect(note.dirty, isFalse);
  });

  test('flag dirty bertahan pada serialisasi', () {
    final note = NoteModel(
      title: 'a',
      updatedAt: DateTime(2026, 9, 27),
      dirty: true,
    );
    final restored = NoteModel.fromMap(note.toMap());
    expect(restored.dirty, isTrue);
  });

  test('model selalu dikonversi ke entity di batas layer', () {
    final entity = NoteModel.fromMap({'title': 'x'}).toEntity();
    expect(entity, isA<Note>());
    expect(entity.title, 'x');
  });

  test('formatNoteTime murni dan deterministik', () {
    expect(
      formatNoteTime(DateTime(2026, 10, 12, 8, 5)),
      '2026-10-12 08:05',
    );
  });

  test('provider sukses dengan repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(
          FakeNoteRepository(items: [
            Note(title: 'Tes', updatedAt: DateTime.now()),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);
    final notes = await container.read(notesProvider.future);
    expect(notes.length, 1);
    expect(notes.first.title, 'Tes');
  });

  test('provider error dengan repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(
          FakeNoteRepository(fail: true),
        ),
      ],
    );
    addTearDown(container.dispose);
    await expectLater(
      container.read(notesProvider.future),
      throwsA(isA<Exception>()),
    );
  });

  test('SyncNotes via provider menandai antrean bersih', () async {
    final repo = FakeNoteRepository(items: [
      Note(id: 1, title: 'a', updatedAt: DateTime.now(), dirty: true),
    ]);
    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    expect(await container.read(dirtyCountProvider.future), 1);
  });

  test('kontrak domain diimplementasikan fake tanpa SQLite', () {
    expect(FakeNoteRepository(), isA<NoteRepository>());
  });
}
