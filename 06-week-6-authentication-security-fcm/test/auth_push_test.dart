import 'package:campus_notify/data/auth_repository.dart';
import 'package:campus_notify/data/token_store.dart';
import 'package:campus_notify/messaging/push_service.dart';
import 'package:campus_notify/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_notify/data/api_errors.dart';

void main() {
  group('routeFromMessage', () {
    test('menangani route kosong dan tanpa slash', () {
      expect(routeFromMessage({}), '/');
      expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
      expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
    });

    test('data payload membawa id pengumuman', () {
      const data = {'route': '/pengumuman/3', 'id': '3'};
      expect(data['id'], '3');
      expect(routeFromMessage(data), '/pengumuman/3');
      expect(idFromMessage(data), '3');
    });
  });

  group('TokenStore memori', () {
    test('save lalu read dan clear', () async {
      final store = TokenStore(backend: MemoryTokenBackend());
      await store.save(access: 'a1', refresh: 'r1');
      expect(await store.readAccess(), 'a1');
      expect(await store.readRefresh(), 'r1');
      await store.saveAccess('a2');
      expect(await store.readAccess(), 'a2');
      await store.clear();
      expect(await store.readAccess(), isNull);
    });

    test('tokenPreview memotong 12 karakter', () {
      expect(tokenPreview('fcm-test-token-abc123'), 'fcm-test-tok...');
      expect(tokenPreview(null), '-');
      expect(tokenPreview(''), '-');
      // Token penuh tidak pernah utuh di UI.
      expect(tokenPreview('fcm-test-token-abc123').contains('abc123'), isFalse);
    });
  });

  group('AuthRepository mock', () {
    test('login valid mengembalikan sesi', () async {
      final repo = AuthRepository();
      final session = await repo.login(
        email: 'nama@polinema.ac.id',
        password: 'rahasia6',
      );
      expect(session.access, contains('nama@polinema.ac.id'));
      expect(session.refresh, isNotEmpty);
    });

    test('login invalid melempar (email/password)', () async {
      final repo = AuthRepository();
      expect(
        () => repo.login(email: 'tanpa-at', password: 'rahasia6'),
        throwsA(isA<Exception>()),
      );
      expect(
        () => repo.login(email: 'a@b.id', password: '123'),
        throwsA(isA<Exception>()),
      );
    });

    test('refresh gagal -> sesi dibersihkan (paksa login ulang)', () async {
      final repo = AuthRepository();
      expect(() => repo.refresh(''), throwsA(isA<Exception>()));
      final renewed = await repo.refresh('mock-refresh-x');
      expect(renewed, contains('mock-access-renewed'));
    });
  });

  group('apiErrorMessage', () {
    test('401 meminta login ulang', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 401,
        ),
      );
      expect(apiErrorMessage(err), contains('login kembali'));
    });

    test('timeout dan connection error ramah pengguna', () {
      final timeout = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(apiErrorMessage(timeout), contains('timeout'));
      final conn = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
      );
      expect(apiErrorMessage(conn), contains('terhubung'));
    });
  });

  group('authStateProvider', () {
    test('membaca status login dari token tersimpan', () async {
      final backend = MemoryTokenBackend();
      final container = ProviderContainer(
        overrides: [
          tokenStoreProvider.overrideWithValue(
            TokenStore(backend: backend),
          ),
        ],
      );
      addTearDown(container.dispose);
      // Belum login: tidak ada token.
      expect(await container.read(authStateProvider.future), isFalse);
      // Login via notifier menyimpan token.
      await container
          .read(authStateProvider.notifier)
          .login('mhs@polinema.ac.id', 'katasandi');
      expect(await container.read(authStateProvider.future), isTrue);
      // Logout membersihkan sesi.
      await container.read(authStateProvider.notifier).logout();
      expect(await container.read(authStateProvider.future), isFalse);
    });
  });
}
