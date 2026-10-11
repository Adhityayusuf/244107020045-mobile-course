import 'package:campus_notify/data/token_store.dart';
import 'package:campus_notify/messaging/push_service.dart';
import 'package:campus_notify/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_notify/pages/home_page.dart';
import 'package:campus_notify/providers/auth_provider.dart';
import 'package:campus_notify/providers/push_providers.dart';

void main() {
  testWidgets('LoginPage menampilkan error validasi', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(
            TokenStore(backend: MemoryTokenBackend()),
          ),
        ],
        child: const MaterialApp(
          home: LoginPage(demoError: 'Email atau kata sandi tidak valid'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Email atau kata sandi tidak valid'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });

  testWidgets('HomePage menampilkan token terpotong, bukan penuh', (tester) async {
    const full = 'fcm-test-token-abc123def456ghi789';
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(
            TokenStore(backend: MemoryTokenBackend()),
          ),
          pushServiceProvider.overrideWithValue(FakePushService()),
          pushUiProvider.overrideWith(_SeededToken.new),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pump();
    // Preview terpotong tampil...
    expect(find.text(tokenPreview(full)), findsOneWidget);
    // ...token penuh tidak pernah tampil.
    expect(find.text(full), findsNothing);
  });

  testWidgets('HomePage banner foreground tampil saat di-seed', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(
            TokenStore(backend: MemoryTokenBackend()),
          ),
          pushServiceProvider.overrideWithValue(FakePushService()),
          pushUiProvider.overrideWith(_SeededBanner.new),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pump();
    expect(find.textContaining('Ketuk untuk membuka'), findsOneWidget);
    expect(find.text('Jadwal kuliah berubah'), findsWidgets);
  });
}

class _SeededToken extends PushUiNotifier {
  @override
  PushUiState build() {
    return const PushUiState(
      tokenPreviewText: 'fcm-test-tok...',
      permissionGranted: true,
      topicSubscribed: true,
    );
  }
}

class _SeededBanner extends PushUiNotifier {
  @override
  PushUiState build() {
    return const PushUiState(
      tokenPreviewText: 'fcm-test-tok...',
      permissionGranted: true,
      topicSubscribed: true,
      bannerKind: 'local',
      bannerTitle: 'Jadwal kuliah berubah',
      bannerBody: 'Kelas Mobile pindah ke Ruang A2 jam 13.00',
    );
  }
}
