import 'package:dio/dio.dart';

/// Memetakan `DioException` menjadi pesan ramah pengguna agar UI hanya
/// menerima pesan, bukan exception mentah (Refactoring Challenge #3).
String apiErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi lambat atau timeout. Periksa internet Anda lalu coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa internet Anda.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 401) {
          return 'Sesi kedaluwarsa. Silakan login kembali.';
        }
        if (code == 404) return 'Data tidak ditemukan (404).';
        if (code == 500) return 'Server kampus bermasalah (500). Coba lagi nanti.';
        return 'Server bermasalah ($code). Coba lagi nanti.';
      default:
        return 'Terjadi kesalahan jaringan. Coba lagi.';
    }
  }
  if (error is Exception) {
    final text = error.toString().replaceFirst('Exception: ', '');
    return text.isEmpty ? 'Terjadi kesalahan. Coba lagi.' : text;
  }
  return 'Terjadi kesalahan tak terduga: $error';
}
