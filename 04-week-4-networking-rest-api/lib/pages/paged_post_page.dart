import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/network_errors.dart';
import '../data/paged_posts.dart';
import '../widgets/post_tile.dart';

class PagedPostPage extends ConsumerStatefulWidget {
  const PagedPostPage({super.key, this.preloadPages = 0, this.startAtBottom = false});

  /// Khusus dokumentasi screenshot (`?demo=paged&pages=3&scroll=bottom`):
  /// muat N halaman pertama lalu lompat ke ujung bawah list.
  final int preloadPages;
  final bool startAtBottom;

  @override
  ConsumerState<PagedPostPage> createState() => _PagedPostPageState();
}

class _PagedPostPageState extends ConsumerState<PagedPostPage> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.pixels >=
          _controller.position.maxScrollExtent - 200) {
        ref.read(pagedPostsProvider.notifier).loadNextPage();
      }
    });
    if (widget.preloadPages > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _preload());
    }
  }

  Future<void> _preload() async {
    final notifier = ref.read(pagedPostsProvider.notifier);
    for (var i = 0; i < widget.preloadPages; i++) {
      await notifier.loadNextPage();
    }
    if (widget.startAtBottom && mounted && _controller.hasClients) {
      await WidgetsBinding.instance.endOfFrame;
      if (mounted && _controller.hasClients) {
        _controller.jumpTo(_controller.position.maxScrollExtent);
        await WidgetsBinding.instance.endOfFrame;
      }
      if (mounted && _controller.hasClients) {
        _controller.jumpTo(_controller.position.maxScrollExtent);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pagedPostsProvider);
    if (state.error != null && state.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Posts Paged')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(friendlyErrorMessage(state.error!)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    ref.read(pagedPostsProvider.notifier).loadFirstPage(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts Paged'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'Daftar penuh',
            onPressed: () => context.go('/simple'),
          ),
        ],
      ),
      body: ListView.builder(
        controller: _controller,
        itemCount: state.items.length + 1,
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            if (!state.hasMore) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('Semua data termuat.')),
              );
            }
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final post = state.items[index];
          return PostTile(
            post: post,
            onTap: () => context.push('/post/${post.id}', extra: post),
          );
        },
      ),
    );
  }
}
