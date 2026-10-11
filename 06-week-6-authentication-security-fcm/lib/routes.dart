/// Semua string rute aplikasi terpusat di sini agar deep link dari FCM
/// dan GoRouter memakai konstanta yang sama (Refactoring Challenge #1).
abstract final class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const announcementDetail = '/pengumuman/:id';

  static String announcement(String id) => '/pengumuman/$id';

  /// Topik broadcast kampus (tanpa spasi, untuk pengumuman umum).
  static const campusTopic = 'pengumuman-kampus';

  /// Endpoint (dokumentasi) tempat token FCM dikirim ke backend.
  static const devicesEndpoint = '/devices';
}
