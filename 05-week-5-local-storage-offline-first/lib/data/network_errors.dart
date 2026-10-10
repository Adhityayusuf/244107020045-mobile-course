import 'package:dio/dio.dart';

/// Kesalahan eksplisit yang dilempar saat refresh jaringan dipaksa offline
/// (toggle `forceOffline`). Dibiarkan terpisah dari [DioException] agar UI
/// bisa membedakan "offline" (cache tetap valid) dari "server error".
class OfflineException implements Exception {
  const OfflineException();
  @override
  String toString() => 'Koneksi offline; menampilkan data cache.';
}

/// Mengubah error teknis menjadi pesan ramah pengguna.
String friendlyErrorMessage(Object error) {
  if (error is OfflineException) {
    return 'Koneksi offline. Data ditampilkan dari cache lokal.';
  }
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi lambat atau timeout. Periksa internet Anda lalu coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Data cache tetap ditampilkan.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 404) return 'Data tidak ditemukan (404).';
        if (code == 401 || code == 403) {
          return 'Akses ditolak ($code). Periksa kredensial Anda.';
        }
        return 'Server bermasalah ($code). Coba lagi nanti.';
      default:
        return 'Terjadi kesalahan jaringan. Data cache tetap ditampilkan.';
    }
  }
  return 'Terjadi kesalahan tak terduga: $error';
}
