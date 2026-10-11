import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'local/db.dart';
import 'models/post.dart';
import 'network_errors.dart';
import 'post_cache.dart';
import 'prefs.dart';
import 'repositories/post_repository.dart';

// ---------------------------------------------------------------------------
// Klien & repository bersama (prefs + posts). Fitur notes punya wiring
// sendiri di features/notes/presentation/providers/notes_providers.dart.
// ---------------------------------------------------------------------------
final dioProvider = Provider<Dio>((ref) => createDio());

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(ref.watch(dioProvider)),
);

final prefsRepositoryProvider = Provider<PrefsRepository>(
  (ref) => PrefsRepository(),
);

// Penyimpanan cache posts: native memakai SQLite, sisanya in-memory.
// Langsung memakai openNotesDb agar tidak bergantung pada fitur notes.
final postCacheProvider = Provider<PostCacheStore>(
  (ref) => SqflitePostCacheStore(openNotesDb),
);

// ---------------------------------------------------------------------------
// Preferensi (SharedPreferences)
// ---------------------------------------------------------------------------
final darkModeProvider = AsyncNotifierProvider<DarkModeNotifier, bool>(
  DarkModeNotifier.new,
  // Disable retry otomatis Riverpod 3 agar error langsung final & mudah diuji.
  retry: (retryCount, error) => null,
);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

// ---------------------------------------------------------------------------
// Toggle offline deterministik (untuk demo & test, tak bergantung Wi-Fi)
// ---------------------------------------------------------------------------
final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);

class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

// ---------------------------------------------------------------------------
// Cache-first read untuk data API (GET /posts)
// ---------------------------------------------------------------------------
class PostsViewState {
  const PostsViewState({
    this.posts = const [],
    this.source = 'empty',
    this.error,
  });

  /// 'empty' | 'cache' | 'network'
  final List<Post> posts;
  final String source;

  /// Pesan error bila refresh jaringan gagal (cache tetap ditampilkan).
  final String? error;

  PostsViewState copyWith({
    List<Post>? posts,
    String? source,
    String? error,
    bool clearError = false,
  }) {
    return PostsViewState(
      posts: posts ?? this.posts,
      source: source ?? this.source,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final postsProvider =
    NotifierProvider<PostsCacheNotifier, PostsViewState>(
  PostsCacheNotifier.new,
);

class PostsCacheNotifier extends Notifier<PostsViewState> {
  @override
  PostsViewState build() {
    Future.microtask(load);
    return const PostsViewState();
  }

  /// Cache-first: tampilkan cache lokal seketika, lalu refresh jaringan.
  Future<void> load() async {
    final cache = ref.read(postCacheProvider);
    final cached = await cache.load();
    state = PostsViewState(
      posts: cached,
      source: cached.isEmpty ? 'empty' : 'cache',
    );
    await refresh();
  }

  Future<void> refresh() async {
    if (ref.read(forceOfflineProvider)) {
      // Offline: pertahankan cache, tidak menyentuh jaringan.
      state = state.copyWith(
        clearError: true,
        source: state.posts.isEmpty ? 'empty' : 'cache',
      );
      return;
    }
    try {
      final posts = await ref.read(postRepositoryProvider).fetchPosts();
      await ref.read(postCacheProvider).save(posts);
      state = PostsViewState(posts: posts, source: 'network');
    } catch (e) {
      // Refresh gagal: pertahankan cache + tandai error.
      state = state.copyWith(
        source: state.posts.isEmpty ? 'error' : 'cache',
        error: friendlyErrorMessage(e),
      );
    }
  }
}
