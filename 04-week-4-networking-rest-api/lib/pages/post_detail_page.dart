import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/post.dart';
import '../data/network_errors.dart';
import '../data/providers.dart';

final postDetailProvider = FutureProvider.family<Post, int>((ref, id) async {
  final repository = ref.watch(postRepositoryProvider);
  return repository.fetchPost(id);
});

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({required this.id, this.initial, super.key});

  final int id;
  final Post? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = initial != null
        ? AsyncData(initial!)
        : ref.watch(postDetailProvider(id));
    final commentsAsync = ref.watch(commentsOfPostProvider(id));

    return Scaffold(
      appBar: AppBar(title: Text('Post $id')),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(friendlyErrorMessage(err), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(postDetailProvider(id)),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (post) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(post.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(post.body),
            const SizedBox(height: 16),
            Text('Komentar', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            commentsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text(friendlyErrorMessage(err)),
              data: (comments) => Column(
                children: [
                  for (final comment in comments)
                    Card(
                      child: ListTile(
                        title: Text(comment.name),
                        subtitle: Text(comment.body),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
