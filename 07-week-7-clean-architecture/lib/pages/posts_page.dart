import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';

class PostsPage extends ConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postsProvider);
    final offline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data API'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_outlined),
            tooltip: 'Kembali ke catatan',
            onPressed: () => context.go('/'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.read(postsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          _StatusBanner(state: state, offline: offline),
          Expanded(
            child: state.posts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_off, size: 48),
                        const SizedBox(height: 8),
                        const Text('Belum ada data.'),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: state.posts.length,
                    itemBuilder: (context, index) {
                      final post = state.posts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                              child: Text('${post.id}')),
                          title: Text(post.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          subtitle: Text(post.body,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.state, required this.offline});

  final PostsViewState state;
  final bool offline;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String message;
    if (state.error != null) {
      color = Theme.of(context).colorScheme.error;
      message = state.error!;
    } else if (offline) {
      color = Theme.of(context).colorScheme.tertiary;
      message = 'Mode offline · ${_sourceLabelText(state.source)}';
    } else {
      color = Theme.of(context).colorScheme.primary;
      message = _sourceLabelText(state.source);
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: color.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(
            state.error != null ? Icons.error_outline : Icons.cloud_done,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }

  String _sourceLabelText(String source) {
    switch (source) {
      case 'network':
        return 'Dari jaringan (tersimpan ke cache)';
      case 'cache':
        return 'Dari cache lokal (offline)';
      case 'error':
        return 'Cache lokal + refresh gagal';
      default:
        return 'Belum ada data';
    }
  }
}
