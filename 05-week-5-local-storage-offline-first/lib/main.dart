import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod/misc.dart' show Override;

import 'data/local/note.dart';
import 'data/local/notes_database_factory.dart';
import 'data/prefs.dart';
import 'data/preview_fakes.dart';
import 'data/providers.dart';
import 'pages/note_detail_page.dart';
import 'pages/notes_page.dart';
import 'pages/posts_page.dart';
import 'pages/settings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDatabaseFactory();
  // Tandai waktu terakhir dibuka (kegagalan tidak boleh menghentikan app).
  try {
    await PrefsRepository().markOpenedNow();
  } catch (_) {}
  final demo = _demoFor(_readDemo());
  runApp(
    ProviderScope(
      overrides: demo.overrides,
      retry: (retryCount, error) => null,
      child: _Root(demo: demo),
    ),
  );
}

/// `?demo=...` hanya tersedia di web; aman (null) di test/native.
String? _readDemo() {
  if (!kIsWeb) return null;
  try {
    return Uri.base.queryParameters['demo'];
  } catch (_) {
    return null;
  }
}

/// Konfigurasi deterministik untuk screenshot dokumentasi (bukan alur normal).
class _Demo {
  const _Demo({this.route = '/', this.overrides = const [], this.autoOpenAdd = false});

  final String route;
  final List<Override> overrides;
  final bool autoOpenAdd;
}

_Demo _demoFor(String? demo) {
  switch (demo) {
    case 'notes':
      return _Demo(overrides: [
        noteRepositoryProvider.overrideWithValue(
          FakeNoteRepository(notes: demoNotes(count: 4, dirtyCount: 2)),
        ),
      ]);
    case 'notes-synced':
      return _Demo(overrides: [
        noteRepositoryProvider.overrideWithValue(
          FakeNoteRepository(notes: demoNotes(count: 4, dirtyCount: 0)),
        ),
      ]);
    case 'dirty-badge':
      return _Demo(route: '/note/1', overrides: [
        noteRepositoryProvider.overrideWithValue(
          FakeNoteRepository(notes: demoNotes(count: 4, dirtyCount: 2)),
        ),
      ]);
    case 'add-note':
      return _Demo(autoOpenAdd: true, overrides: [
        noteRepositoryProvider.overrideWithValue(
          FakeNoteRepository(notes: demoNotes(count: 3, dirtyCount: 1)),
        ),
      ]);
    case 'offline-notes':
      return _Demo(overrides: [
        noteRepositoryProvider.overrideWithValue(
          FakeNoteRepository(notes: demoNotes(count: 4, dirtyCount: 2)),
        ),
        forceOfflineProvider.overrideWith(_ForceOfflineTrueNotifier.new),
      ]);
    case 'settings':
      return _Demo(route: '/settings');
    case 'settings-dark':
      return _Demo(route: '/settings', overrides: [
        prefsRepositoryProvider.overrideWithValue(
          FakePrefsRepository(
            darkMode: true,
            lastOpened: '2026-10-10T08:00:00.000',
          ),
        ),
      ]);
    case 'note-detail':
      return _Demo(route: '/note/1', overrides: [
        noteRepositoryProvider.overrideWithValue(
          FakeNoteRepository(notes: demoNotes(count: 4, dirtyCount: 0)),
        ),
      ]);
    case 'posts-cache':
      return _Demo(route: '/posts', overrides: [
        postCacheProvider.overrideWithValue(SeedPostCacheStore(demoPosts(4))),
        postRepositoryProvider.overrideWithValue(FakePostRepository()),
        forceOfflineProvider.overrideWith(_ForceOfflineTrueNotifier.new),
      ]);
    case 'posts-network':
      return _Demo(route: '/posts', overrides: [
        postCacheProvider.overrideWithValue(SeedPostCacheStore(const [])),
        postRepositoryProvider.overrideWithValue(
          FakePostRepository(posts: demoPosts(5)),
        ),
      ]);
    case 'posts-error':
      return _Demo(route: '/posts', overrides: [
        postCacheProvider.overrideWithValue(SeedPostCacheStore(demoPosts(4))),
        postRepositoryProvider.overrideWithValue(FakePostRepository(throwError: true)),
      ]);
    default:
      return const _Demo();
  }
}

/// Notifier kecil untuk memaksa `forceOffline` saat demo.
class _ForceOfflineTrueNotifier extends ForceOfflineNotifier {
  @override
  bool build() => true;
}

class _Root extends ConsumerWidget {
  const _Root({required this.demo});
  final _Demo demo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider).value ?? false;
    return MaterialApp.router(
      title: 'Week 5 - Offline Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: GoRouter(
        initialLocation: demo.route,
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => NotesPage(
              autoOpenAdd: demo.autoOpenAdd,
            ),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/posts',
            builder: (context, state) => const PostsPage(),
          ),
          GoRoute(
            path: '/note/:id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              final extra = state.extra;
              return NoteDetailPage(
                noteId: id,
                initial: extra is Note ? extra : null,
              );
            },
          ),
        ],
      ),
    );
  }
}
