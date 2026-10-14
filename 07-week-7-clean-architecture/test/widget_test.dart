import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week7_notes_clean/core/format.dart';
import 'package:week7_notes_clean/features/notes/domain/entities/note.dart';
import 'package:week7_notes_clean/features/notes/presentation/pages/note_detail_page.dart';
import 'package:week7_notes_clean/features/notes/presentation/widgets/note_tile.dart';

void main() {
  Widget wrap(Note note) {
    return MaterialApp(
      home: Scaffold(body: NoteTile(note: note)),
    );
  }

  testWidgets('NoteTile menampilkan badge belum tersinkron', (tester) async {
    await tester.pumpWidget(wrap(
      Note(
        id: 1,
        title: 'Belanja',
        body: 'susu',
        updatedAt: DateTime.now(),
        dirty: true,
      ),
    ));
    expect(find.text('Belanja'), findsOneWidget);
    expect(find.text('Belum tersinkron'), findsOneWidget);
  });

  testWidgets('NoteTile tidak menampilkan badge saat tersinkron',
      (tester) async {
    await tester.pumpWidget(wrap(
      Note(
        id: 1,
        title: 'Belanja',
        body: 'susu',
        updatedAt: DateTime.now(),
        dirty: false,
      ),
    ));
    expect(find.text('Belanja'), findsOneWidget);
    expect(find.text('Belum tersinkron'), findsNothing);
  });

  testWidgets('NoteDetailPage memakai formatNoteTime, bukan toString mentah',
      (tester) async {
    final updatedAt = DateTime(2026, 10, 12, 8, 5);
    await tester.pumpWidget(
      MaterialApp(
        home: ProviderScope(
          child: NoteDetailPage(
            noteId: 1,
            initial: Note(id: 1, title: 'Belanja', updatedAt: updatedAt),
          ),
        ),
      ),
    );
    expect(
      find.text('Diperbarui: ${formatNoteTime(updatedAt)}'),
      findsOneWidget,
    );
    expect(find.textContaining('08:05:00'), findsNothing);
  });
}
