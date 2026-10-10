import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/note.dart';
import '../data/providers.dart';
import '../widgets/note_tile.dart';

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({required this.noteId, this.initial, super.key});

  final int noteId;

  /// Catatan yang dikirim dari daftar (bila ada), menghindari fetch ulang.
  final Note? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Baca dari repository lokal; pakai [initial] bila sudah ada dari daftar.
    final noteAsync =
        initial != null ? AsyncValue.data(initial!) : ref.watch(noteDetailProvider(noteId));

    return Scaffold(
      appBar: AppBar(title: Text('Catatan #${initial?.id ?? noteId}')),
      body: noteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat: $err'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(noteDetailProvider(noteId)),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (note) {
          if (note == null) {
            return const Center(child: Text('Catatan tidak ditemukan.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  if (note.dirty)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: DirtyBadge(),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (note.body.isNotEmpty) ...[
                Text(note.body, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 12),
              ],
              Text(
                'Diperbarui: ${note.updatedAt.toLocal()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}
