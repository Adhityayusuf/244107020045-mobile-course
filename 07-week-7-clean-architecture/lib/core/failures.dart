/// Failure domain: murni Dart, tanpa import Flutter/package apa pun.
///
/// Presentation hanya menerima [message] yang ramah pengguna, bukan
/// exception mentah dari Dio/SQLite.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

/// Kegagalan penyimpanan lokal (SQLite): baca/tulis/hapus catatan.
class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

/// Kegagalan validasi aturan bisnis (mis. judul kosong).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Kegagalan jaringan (refresh cache posts). Cache lokal tetap ditampilkan.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
