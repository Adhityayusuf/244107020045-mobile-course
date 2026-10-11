import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod/misc.dart' show Override;

import 'data/token_store.dart';
import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'providers/push_providers.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase bersifat opsional di codelab ini: mock auth berjalan tanpa
  // backend. Inisialisasi dibungkus try/catch agar aplikasi (dan screenshot
  // web tanpa google-services) tetap berjalan. Titik pasang Firebase
  // didokumentasikan di README/docs.
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );
  } catch (_) {
    // Firebase belum dikonfigurasi (tanpa google-services.json): lanjut
    // dengan mock auth + FakePushService.
  }

  try {
    await initLocalNotifications();
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
  const _Demo({
    this.route = AppRoutes.login,
    this.overrides = const [],
    this.loginError,
    this.seedPush,
  });

  final String route;
  final List<Override> overrides;
  final String? loginError;
  final PushUiState? seedPush;
}

MemoryTokenBackend _loggedInStore() {
  final backend = MemoryTokenBackend();
  // Seed sinkron: backend memori menulis langsung (future selesai seketika
  // sebelum provider build membaca).
  backend.write(TokenStore.accessKey, 'mock-access-demo-user');
  backend.write(TokenStore.refreshKey, 'mock-refresh-demo-user');
  return backend;
}

const _demoToken = 'fcm-test-token-abc123def456ghi789';
const _demoTitle = 'Jadwal kuliah berubah';
const _demoBody = 'Kelas Mobile pindah ke Ruang A2 jam 13.00';

_Demo _demoFor(String? demo) {
  PushUiState push({
    String? bannerKind,
    bool openedVia = false,
    bool permission = true,
    bool topic = true,
  }) {
    return PushUiState(
      tokenPreviewText: tokenPreview(_demoToken),
      permissionGranted: permission,
      topicSubscribed: topic,
      bannerKind: bannerKind,
      bannerTitle: _demoTitle,
      bannerBody: _demoBody,
      openedViaNotification: openedVia,
    );
  }

  List<Override> loggedIn() => [
        tokenStoreProvider.overrideWithValue(
          TokenStore(backend: _loggedInStore()),
        ),
        pushServiceProvider.overrideWithValue(FakePushService()),
      ];

  switch (demo) {
    case 'login-error':
      return _Demo(
        route: AppRoutes.login,
        loginError: 'Email atau kata sandi tidak valid',
      );
    case 'home':
      return _Demo(
        route: AppRoutes.home,
        overrides: loggedIn(),
        seedPush: push(),
      );
    case 'announcement':
      return _Demo(
        route: AppRoutes.announcement('3'),
        overrides: loggedIn(),
        seedPush: push(),
      );
    case 'foreground':
      return _Demo(
        route: AppRoutes.home,
        overrides: loggedIn(),
        seedPush: push(bannerKind: 'local'),
      );
    case 'background':
      return _Demo(
        route: AppRoutes.home,
        overrides: loggedIn(),
        seedPush: push(bannerKind: 'system'),
      );
    case 'terminated':
      return _Demo(
        route: AppRoutes.announcement('3'),
        overrides: loggedIn(),
        seedPush: push(openedVia: true),
      );
    case 'token-topic':
      return _Demo(
        route: AppRoutes.home,
        overrides: loggedIn(),
        seedPush: push(),
      );
    case 'permission':
      return _Demo(
        route: AppRoutes.home,
        overrides: loggedIn(),
        seedPush: push(),
      );
    default:
      // Alur normal: mulai dari login, backend memori kosong.
      return _Demo(
        overrides: [
          pushServiceProvider.overrideWithValue(FakePushService()),
        ],
      );
  }
}

class _Root extends ConsumerWidget {
  const _Root({required this.demo});
  final _Demo demo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Seed state push demo sekali setelah frame pertama.
    if (demo.seedPush != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          ref.read(pushUiProvider.notifier).seed(demo.seedPush!);
        } catch (_) {}
      });
    }

    final loggedIn = ref.watch(authStateProvider).value ?? false;

    return MaterialApp.router(
      title: 'Campus Notify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      routerConfig: GoRouter(
        initialLocation: demo.route,
        redirect: (context, state) {
          final goingLogin = state.matchedLocation == AppRoutes.login;
          if (!loggedIn && !goingLogin) return AppRoutes.login;
          if (loggedIn && goingLogin) return AppRoutes.home;
          return null;
        },
        routes: [
          GoRoute(
            path: AppRoutes.login,
            builder: (context, state) =>
                LoginPage(demoError: demo.loginError),
          ),
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.announcementDetail,
            builder: (context, state) => AnnouncementPage(
              id: state.pathParameters['id'] ?? '',
            ),
          ),
        ],
      ),
    );
  }
}
