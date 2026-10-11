import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week7_notes_clean/features/notes/domain/entities/note.dart';
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
}
