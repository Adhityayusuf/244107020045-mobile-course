import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Backend penyimpanan token. Abstraksi ini memungkinkan test/demo memakai
/// memori tanpa plugin platform, sementara produksi memakai secure storage
/// (Keychain di iOS, Keystore di Android).
abstract class TokenBackend {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> deleteAll();
}

/// Backend produksi: terenkripsi oleh OS. Token TIDAK PERNAH disimpan di
/// SharedPreferences (tidak terenkripsi) atau di-hardcode di kode.
class SecureTokenBackend implements TokenBackend {
  SecureTokenBackend({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}

/// Backend in-memory: untuk unit test, widget test, dan demo screenshot web
/// (plugin secure storage tidak tersedia di semua environment).
class MemoryTokenBackend implements TokenBackend {
  final Map<String, String> _map = {};

  @override
  Future<void> write(String key, String value) async => _map[key] = value;

  @override
  Future<String?> read(String key) async => _map[key];

  @override
  Future<void> deleteAll() async => _map.clear();
}

/// Satu-satunya pintu keluar-masuk token. UI dan Dio tidak menyentuh
/// storage secara langsung.
class TokenStore {
  TokenStore({TokenBackend? backend})
      : _backend = backend ?? SecureTokenBackend();

  final TokenBackend _backend;
  static const accessKey = 'access_token';
  static const refreshKey = 'refresh_token';

  Future<void> save({required String access, required String refresh}) async {
    await _backend.write(accessKey, access);
    await _backend.write(refreshKey, refresh);
  }

  /// Menimpa access token hasil refresh tanpa mengubah refresh token.
  Future<void> saveAccess(String access) =>
      _backend.write(accessKey, access);

  Future<String?> readAccess() => _backend.read(accessKey);
  Future<String?> readRefresh() => _backend.read(refreshKey);

  /// Dipakai saat logout dan saat refresh ikut kedaluwarsa.
  Future<void> clear() => _backend.deleteAll();
}

/// Menampilkan token secara aman: 12 karakter pertama + `...`.
/// Token penuh TIDAK PERNAH tampil di UI, log, atau screenshot laporan.
String tokenPreview(String? token) {
  if (token == null || token.isEmpty) return '-';
  if (token.length <= 12) return '$token...';
  return '${token.substring(0, 12)}...';
}
