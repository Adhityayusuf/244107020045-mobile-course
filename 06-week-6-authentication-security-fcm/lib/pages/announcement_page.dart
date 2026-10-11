import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/push_providers.dart';

/// Tujuan deep link notifikasi: `/pengumuman/:id`. Dibuka dari daftar,
/// klik banner foreground/background, atau `getInitialMessage` (terminated).
class AnnouncementPage extends ConsumerWidget {
  const AnnouncementPage({
    required this.id,
    super.key,
  });

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openedVia = ref.watch(pushUiProvider).openedViaNotification;

    return Scaffold(
      appBar: AppBar(title: Text('Pengumuman #$id')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (openedVia)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .tertiary
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    size: 18,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Dibuka dari klik notifikasi'),
                  ),
                ],
              ),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jadwal kuliah berubah',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kelas Pemrograman Mobile pindah ke Ruang A2 jam 13.00. '
                    'Harap datang 10 menit lebih awal dan bawa laptop '
                    'dengan Flutter SDK terbaru.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Rute: /pengumuman/$id · payload: notification + data {route, id}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
