import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/push_providers.dart';
import '../routes.dart';

/// Beranda setelah login: status sesi, token terpotong, topik, dan izin.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final push = ref.watch(pushUiProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman Kampus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (push.bannerKind != null) const SizedBox(height: 76),
              _TokenCard(push: push),
              const SizedBox(height: 12),
              _StatusCard(push: push),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.campaign_outlined),
                  title: const Text('Jadwal kuliah berubah'),
                  subtitle: const Text(
                    'Kelas Mobile pindah ke Ruang A2 jam 13.00',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.announcement('3')),
                ),
              ),
            ],
          ),
          if (push.bannerKind == 'local')
            _LocalBanner(
              title: push.bannerTitle,
              body: push.bannerBody,
              onTap: () => context.push(AppRoutes.announcement('3')),
            ),
          if (push.bannerKind == 'system')
            _SystemBanner(
              title: push.bannerTitle,
              body: push.bannerBody,
            ),
        ],
      ),
    );
  }
}

class _TokenCard extends StatelessWidget {
  const _TokenCard({required this.push});
  final PushUiState push;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.smartphone, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Token perangkat',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              push.tokenPreviewText,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 4),
            Text(
              'Terpotong demi keamanan. Token penuh tidak pernah ditampilkan.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.push});
  final PushUiState push;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              push.permissionGranted
                  ? Icons.notifications_active
                  : Icons.notifications_off_outlined,
            ),
            title: const Text('Izin notifikasi'),
            trailing: Text(
              push.permissionGranted ? 'Diizinkan' : 'Belum diminta',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.forum_outlined),
            title: const Text('Topik pengumuman-kampus'),
            trailing: Text(
              push.topicSubscribed ? 'Berlangganan' : 'Berhenti',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner manual foreground (local notification): muncul di dalam aplikasi.
class _LocalBanner extends StatelessWidget {
  const _LocalBanner({
    required this.title,
    required this.body,
    required this.onTap,
  });

  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 12,
      right: 12,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.campaign,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(body, maxLines: 2),
                      Text(
                        'Ketuk untuk membuka · foreground',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Banner gaya sistem (background): meniru banner OS di atas aplikasi.
class _SystemBanner extends StatelessWidget {
  const _SystemBanner({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 12,
      right: 12,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.school,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'CAMPUS NOTIFY · sekarang',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(body, maxLines: 2),
            ],
          ),
        ),
      ),
    );
  }
}
