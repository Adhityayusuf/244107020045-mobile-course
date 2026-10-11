import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../routes.dart';

/// Mengubah data payload FCM menjadi rute aplikasi. Fungsi MURNI sehingga
/// bisa diunit-test tanpa Firebase (Refactoring Challenge #2).
///
/// Contoh payload gabungan dari backend (FCM HTTP v1):
/// ```json
/// { "message": {
///   "topic": "pengumuman-kampus",
///   "notification": { "title": "...", "body": "..." },
///   "data": { "route": "/pengumuman/3", "id": "3" }
/// } }
/// ```
String routeFromMessage(Map<String, String> data) {
  final route = data['route'] ?? AppRoutes.home;
  return route.startsWith('/') ? route : '/$route';
}

/// ID pengumuman dari data payload (`null` bila tidak ada).
String? idFromMessage(Map<String, String> data) => data['id'];

// ---------------------------------------------------------------------------
// Background handler: WAJIB fungsi top-level (bukan method kelas) karena
// berjalan di isolate terpisah. Dilarang mengakses BuildContext / Riverpod
// di sini; navigasi dilakukan saat notifikasi diklik.
// ---------------------------------------------------------------------------
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Catat/simpan ringan saja bila perlu. Navigasi ditangani
  // onMessageOpenedApp / getInitialMessage lewat data.route.
}

/// Deep link tertunda dari klik banner foreground (local notification).
/// Dibaca sekali saat startup setelah router siap.
String? pendingDeepLink;

// ---------------------------------------------------------------------------
// Abstraksi layanan push agar logika bisa diuji dan didemo tanpa Firebase
// sungguhan (emulator tanpa Play Services / web screenshot).
// ---------------------------------------------------------------------------
abstract class PushService {
  /// Meminta izin notifikasi runtime (wajib Android 13+ dan iOS).
  Future<bool> requestPermission();

  /// Mengambil registration token saat ini untuk dikirim ke backend.
  Future<String?> fetchToken();

  /// Stream rotasi token: backend WAJIB diperbarui di sini, jika tidak
  /// backend menyimpan token basi (tidak ada notifikasi masuk).
  Stream<String> get onTokenRefresh;

  Future<void> subscribeTopic(String topic);
  Future<void> unsubscribeTopic(String topic);
}

/// Implementasi produksi dengan Firebase. Bagian yang BERBEDA per platform:
/// - Android 13+: [requestPermission] menampilkan dialog runtime.
/// - iOS: butuh APNs key di Firebase Console + capability Push di Xcode,
///   dan opsi `announcement`/`carPlay`/`criticalAlert` hanya berlaku di iOS.
class FirebasePushService implements PushService {
  FirebasePushService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  @override
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<String?> fetchToken() => _messaging.getToken();

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Future<void> subscribeTopic(String topic) =>
      _messaging.subscribeToTopic(topic);

  @override
  Future<void> unsubscribeTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);
}

/// Implementasi palsu untuk test, demo, dan screenshot: deterministik,
/// tanpa jaringan dan tanpa plugin platform.
class FakePushService implements PushService {
  FakePushService({
    this.token = 'fcm-test-token-abc123def456ghi789',
    this.permissionGranted = true,
    this.topics = const {},
  });

  final String token;
  final bool permissionGranted;
  final Set<String> topics;

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<String?> fetchToken() async => token;

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Future<void> subscribeTopic(String topic) async => topics.add(topic);

  @override
  Future<void> unsubscribeTopic(String topic) async => topics.remove(topic);
}

// ---------------------------------------------------------------------------
// Local notification untuk foreground: sistem TIDAK menampilkan banner
// otomatis saat aplikasi terbuka, jadi wajib tampil manual.
// ---------------------------------------------------------------------------
final _local = FlutterLocalNotificationsPlugin();

/// Inisialisasi plugin local notification. Aman dipanggil di web (gagal
/// diam-diam karena plugin tidak didukung di sana).
Future<void> initLocalNotifications() async {
  try {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        // Klik banner foreground -> teruskan payload (route) ke router.
        pendingDeepLink = response.payload;
      },
    );
  } catch (_) {
    // Platform tanpa dukungan (mis. web screenshot): abaikan.
  }
}

/// Menampilkan banner lokal manual untuk pesan foreground.
Future<void> showForegroundNotification({
  required String title,
  required String body,
  required String route,
}) async {
  const androidDetails = AndroidNotificationDetails(
    'pengumuman',
    'Pengumuman Kampus',
    importance: Importance.high,
    priority: Priority.high,
  );
  await _local.show(
    id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title: title,
    body: body,
    notificationDetails:
        const NotificationDetails(android: androidDetails),
    payload: route,
  );
}
