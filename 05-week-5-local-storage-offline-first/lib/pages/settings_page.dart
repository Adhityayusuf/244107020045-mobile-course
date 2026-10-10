import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';

final _prefsRepositoryProvider = prefsRepositoryProvider;

/// Menampilkan waktu terakhir aplikasi dibuka (dari SharedPreferences).
final lastOpenedProvider = FutureProvider<String?>((ref) {
  return ref.watch(_prefsRepositoryProvider).getLastOpened();
});

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(darkModeProvider);
    final lastOpened = ref.watch(lastOpenedProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Tema gelap'),
            subtitle: const Text('Disimpan via SharedPreferences'),
            value: dark.value ?? false,
            onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Terakhir dibuka'),
            subtitle: Text(lastOpened ?? 'Belum tercatat'),
          ),
        ],
      ),
    );
  }
}
