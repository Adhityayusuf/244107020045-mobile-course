import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/models/post.dart';
import 'data/preview_fakes.dart';
import 'data/providers.dart';
import 'pages/paged_post_page.dart';
import 'pages/post_detail_page.dart';
import 'pages/post_list_page.dart';

void main() {
  runApp(
    ProviderScope(
      retry: (retryCount, error) => null,
      overrides: [...previewOverrides()],
      child: const MyApp(),
    ),
  );
}

/// Override repository palsu bila URL memakai `?demo=...` (khusus
/// screenshot dokumentasi yang deterministik, bukan alur normal):
/// loading | error | empty | success | paged | detail
///
/// Tipe `Override` Riverpod 3 tidak diekspor publik, jadi helper ini
/// memakai `List<dynamic>` (isinya tetap override provider yang valid).
List<dynamic> previewOverrides() {
  if (!kIsWeb) return [];
  String? demo;
  try {
    demo = Uri.base.queryParameters['demo'];
  } catch (_) {
    return [];
  }
  switch (demo) {
    case 'loading':
      return [
        postRepositoryProvider.overrideWithValue(
          FakePostRepository(hang: true),
        ),
      ];
    case 'error':
      return [
        postRepositoryProvider.overrideWithValue(
          FakePostRepository(throwError: true),
        ),
      ];
    case 'empty':
      return [
        postRepositoryProvider.overrideWithValue(
          FakePostRepository(items: const []),
        ),
      ];
    case 'success':
      return [
        postRepositoryProvider.overrideWithValue(
          FakePostRepository(items: demoPosts(5)),
        ),
      ];
    case 'paged':
      return [
        postRepositoryProvider.overrideWithValue(
          FakePostRepository(pages: {
            1: demoPosts(10, startId: 1),
            2: demoPosts(10, startId: 11),
            3: demoPosts(2, startId: 21),
          }),
        ),
      ];
    case 'detail':
      return [
        postRepositoryProvider.overrideWithValue(
          FakePostRepository(items: demoPosts(3)),
        ),
        commentRepositoryProvider.overrideWithValue(
          FakeCommentRepository(items: demoComments(1)),
        ),
      ];
    default:
      return [];
  }
}

/// Route awal: prioritas query `?route=`, lalu path URL browser
/// (`/simple`, `/post/:id`), default `/`.
String initialRoute() {
  if (kIsWeb) {
    try {
      final uri = Uri.base;
      final r = uri.queryParameters['route'];
      if (r != null && r.startsWith('/')) {
        return r;
      }
      if (uri.path == '/simple' || uri.path.startsWith('/post/')) {
        return uri.path;
      }
    } catch (_) {
      // Uri.base tidak tersedia di test: pakai '/'.
    }
  }
  return '/';
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Week 4 - REST API',
      debugShowCheckedModeBanner: false,
      routerConfig: GoRouter(
        initialLocation: initialRoute(),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              // Khusus screenshot: ?demo=paged&pages=3&scroll=bottom
              var preload = 0;
              var atBottom = false;
              if (kIsWeb) {
                try {
                  final params = Uri.base.queryParameters;
                  preload = int.tryParse(params['pages'] ?? '') ?? 0;
                  atBottom = params['scroll'] == 'bottom';
                } catch (_) {}
              }
              return PagedPostPage(
                preloadPages: preload,
                startAtBottom: atBottom,
              );
            },
          ),
          GoRoute(
            path: '/simple',
            builder: (context, state) => const PostListPage(),
          ),
          GoRoute(
            path: '/post/:id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              final extra = state.extra;
              return PostDetailPage(
                id: id,
                initial: extra is Post ? extra : null,
              );
            },
          ),
        ],
      ),
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
    );
  }
}
