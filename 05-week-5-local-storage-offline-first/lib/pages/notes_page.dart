import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import '../widgets/note_tile.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key, this.autoOpenAdd = false});

  /// Khusus screenshot demo (`?demo=add-note`): langsung buka dialog tambah.
  final bool autoOpenAdd;

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  @override
  void initState() {
    super.initState();
    if (widget.autoOpenAdd) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openAddDialog());
    }
  }

  void _openAddDialog() {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Catatan baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Judul'),
                onSubmitted: (_) => FocusScope.of(dialogContext).nextFocus(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Isi (opsional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final title = titleCtrl.text.trim();
                if (title.isEmpty) return;
                ref.read(notesProvider.notifier).add(
                      title: title,
                      body: bodyCtrl.text.trim(),
                    );
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sync() async {
    final notifier = ref.read(notesProvider.notifier);
    final synced = await notifier.sync();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          synced == 0
              ? 'Semua catatan sudah tersinkron.'
              : '$synced catatan tersinkron.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);
    final dirtyCount = ref.watch(dirtyCountProvider).value ?? 0;
    final offline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_outlined),
            tooltip: 'Data API',
            onPressed: () => context.go('/posts'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan',
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddDialog,
        child: const Icon(Icons.add),
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat catatan: $err'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(notesProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (notes) {
          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sticky_note_2_outlined, size: 48),
                  const SizedBox(height: 8),
                  const Text('Belum ada catatan.'),
                ],
              ),
            );
          }
          return Column(
            children: [
              if (offline)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Theme.of(context)
                      .colorScheme
                      .tertiary
                      .withValues(alpha: 0.12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.wifi_off,
                        size: 18,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Mode offline · data dari SQLite lokal',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              _SyncBar(
                dirtyCount: dirtyCount,
                onSync: _sync,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Dismissible(
                      key: ValueKey(note.id ?? index),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) =>
                          ref.read(notesProvider.notifier).remove(note.id!),
                      child: NoteTile(
                        note: note,
                        onTap: () =>
                            context.push('/note/${note.id ?? 0}', extra: note),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SyncBar extends StatelessWidget {
  const _SyncBar({required this.dirtyCount, required this.onSync});

  final int dirtyCount;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Text(
            dirtyCount == 0
                ? 'Semua catatan tersinkron'
                : '$dirtyCount belum tersinkron',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          FilledButton.tonalIcon(
            onPressed: onSync,
            icon: const Icon(Icons.sync, size: 18),
            label: const Text('Sync'),
          ),
        ],
      ),
    );
  }
}
