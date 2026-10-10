import 'package:flutter/material.dart';

import '../data/local/note.dart';

/// Badge kecil yang muncul hanya saat catatan `dirty` (belum tersinkron).
class DirtyBadge extends StatelessWidget {
  const DirtyBadge({super.key, this.label = 'Belum tersinkron'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.tertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Baris daftar catatan: judul, snippet isi, waktu, dan badge dirty.
class NoteTile extends StatelessWidget {
  const NoteTile({required this.note, this.onTap, super.key});

  final Note note;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.sticky_note_2_outlined),
      title: Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (note.body.isNotEmpty)
            Text(note.body, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                note.updatedAt.toLocal().toString().substring(0, 16),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 8),
              if (note.dirty) const DirtyBadge(),
            ],
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
