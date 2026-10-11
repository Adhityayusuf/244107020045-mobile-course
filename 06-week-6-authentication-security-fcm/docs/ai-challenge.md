# AI Challenge - Week 6

Dokumen ini mencatat prompt, output awal AI, verifikasi, perbaikan manual,
keputusan final, dan hasil testing untuk bagian **AI Prompt Challenge** pada
praktikum Authentication, Security & FCM.

Nama: M.Adhitya Yusuf Al-Ayyubi (NIM 244107020045, Kelas TI-2H)

## 1. Prompt yang digunakan

Prompt diambil persis dari modul:

```text
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications,
flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
dan bagian yang tidak boleh mengakses BuildContext.
```

AI assistant yang dipakai: coding agent pada environment pengerjaan ini
(diminta membuat draf sesuai checklist modul, lalu diverifikasi dan
diperbaiki manual).

## 2. Output awal AI

Draf awal AI sudah mengikuti struktur modul: `TokenStore`
(`flutter_secure_storage`), `AuthRepository` mock, interceptor Dio dengan
refresh sekali, `PushService` (permission + token + topic), tiga handler
(`onMessage`, `onMessageOpenedApp`, `getInitialMessage`), background handler
top-level, dan guard route GoRouter.

## 3. Verifikasi terhadap AI Verification Checklist

| Checklist modul | Temuan pada draf awal | Tindakan |
| :--- | :--- | :--- |
| Background handler top-level + `@pragma('vm:entry-point')`? | Ya, fungsi top-level | Dipertahankan |
| `onTokenRefresh` mengirim token baru ke backend? | **Tidak.** Draf awal hanya mencetak token ke log | Diperbaiki: didokumentasikan pengiriman `POST /devices` + listener wajib |
| Foreground memakai local notification manual? | Ya | Dipertahankan (`showForegroundNotification`) |
| Klik ketiga state masuk rute benar? | Struktur benar, belum dibuktikan | Dibuktikan via demo deterministik + tabel uji 3 state |
| Token/secret tidak di-hardcode dan tidak di-log penuh? | **Melanggar sebagian.** Draf awal menampilkan token penuh di halaman Debug | Diperbaiki: `tokenPreview()` (12 karakter + `...`) |
| Perbedaan Android 13+ vs iOS ditandai? | Belum | Ditambah komentar platform di `FirebasePushService` |

## 4. Perbaikan manual yang dilakukan

### 4.1 Token tidak pernah penuh di UI/log/screenshot

Draf awal menampilkan token penuh di halaman Debug. Perbaikan: helper
`tokenPreview()` di `lib/data/token_store.dart` — semua UI, test, dan
screenshot hanya memakai 12 karakter pertama + `...`. Test
`tokenPreview memotong 12 karakter` membuktikan token penuh tidak utuh.

### 4.2 `TokenBackend`: secure di produksi, memori di test/demo

`TokenStore` konstruktor menerima `TokenBackend` sehingga unit/widget test
dan screenshot web memakai `MemoryTokenBackend` tanpa plugin platform
(tanpa `MissingPluginException`), sementara produksi memakai
`SecureTokenBackend` (`flutter_secure_storage` → Keychain/Keystore).
Refresh token tetap tidak pernah menyentuh SharedPreferences.

### 4.3 API `flutter_local_notifications` v22

Draf awal memakai API lama (positional args). Package terpasang (`^22.3.1`)
memakai named params (`settings:`, `id:`/`title:`/`notificationDetails:`).
Diperbaiki di `initLocalNotifications()` dan `showForegroundNotification()`
hingga `flutter analyze` bersih.

### 4.4 `AsyncValue.valueOrNull` tidak ada di Riverpod 3.4

Draf memakai `.valueOrNull`; API yang ada adalah `.value`. Diganti di
`main.dart` (guard route).

### 4.5 Tipe `Override` dari `package:riverpod/misc.dart`

Helper demo screenshot memakai `List<Override>`; tipe tersebut hanya
diekspor dari `package:riverpod/misc.dart` (bukan `flutter_riverpod`).
Ditambah import eksplisit + dependensi `riverpod` di `pubspec.yaml`.

### 4.6 Firebase opsional (mock-first)

`main()` membungkus `Firebase.initializeApp()` dan registrasi background
handler dalam try/catch: tanpa `google-services.json` aplikasi tetap jalan
dengan mock auth + `FakePushService`. Titik pasang Firebase
(`google-services.json` → `android/app/`, `GoogleService-Info.plist` untuk
iOS, `await Firebase.initializeApp()` sebelum `runApp`) didokumentasikan di
README. Ini disengaja agar codelab bisa berjalan tanpa backend.

## 5. Keputusan final

- Auth: **mock `AuthRepository` + JWT simulasi** (siap diganti Firebase Auth
  tanpa mengubah repository/provider).
- Penyimpanan token: **`flutter_secure_storage`** (produksi),
  **in-memory** (test/demo). Tidak ada token di SharedPreferences, kode,
  log, atau screenshot penuh.
- Notifikasi: **gabungan `notification + data`**; `notification` untuk teks
  manusia, `data.route`/`data.id` untuk deep link.
- Topik `pengumuman-kampus` untuk broadcast; **token perangkat** untuk pesan
  personal (nilai, tagihan).
- Konflik/refresh: interceptor Dio mencoba refresh **sekali** saat 401 lalu
  mengulang request; refresh mati → `clear()` → paksa `/login`.

## 6. Tabel pengujian tiga app state

Payload uji: `notification {title: "Jadwal kuliah berubah", body: "Kelas
Mobile pindah ke Ruang A2 jam 13.00"}` + `data {route: "/pengumuman/3",
id: "3"}`. Karena Firebase Console butuh backend asli, pembuktian memakai
demo deterministik (`FakePushService` + seed state) yang mensimulasikan
ketiga alur handler:

| State | Yang diharapkan | Bukti |
| :--- | :--- | :--- |
| Foreground | Banner lokal manual muncul, klik masuk `/pengumuman/3` | `05-foreground.png` (banner + label foreground) |
| Background | Banner sistem muncul, klik masuk rute benar | `06-background.png` (banner gaya sistem) |
| Terminated | Aplikasi terbuka ke rute benar via `getInitialMessage` | `07-terminated.png` (chip "Dibuka dari klik notifikasi") |

Implementasi handler asli (`onMessage` → `showForegroundNotification`,
`onMessageOpenedApp` → `go(route)`, `getInitialMessage` + `pendingDeepLink`
saat startup) ada di `lib/messaging/push_service.dart` dan siap dipakai
saat Firebase dikonfigurasi.

## 7. Hasil testing

Perintah dan hasil (di dalam `campus_notify/`, tanpa Firebase/HTTP
sungguhan — semua memakai fake/in-memory):

```text
$ flutter analyze
Analyzing campus_notify...
No issues found!

$ flutter test
00:00 +0: routeFromMessage menangani route kosong dan tanpa slash
00:00 +1: routeFromMessage data payload membawa id pengumuman
00:00 +2: TokenStore memori save lalu read dan clear
00:00 +3: TokenStore memori tokenPreview memotong 12 karakter
00:00 +4: AuthRepository mock login valid mengembalikan sesi
00:00 +5: AuthRepository mock login invalid melempar (email/password)
00:01 +6: AuthRepository mock refresh gagal -> sesi dibersihkan (paksa login ulang)
00:01 +7: apiErrorMessage 401 meminta login ulang
00:01 +8: apiErrorMessage timeout dan connection error ramah pengguna
00:01 +9: authStateProvider membaca status login dari token tersimpan
00:02 +10: LoginPage menampilkan error validasi
00:03 +11: HomePage menampilkan token terpotong, bukan penuh
00:03 +12: HomePage banner foreground tampil saat di-seed
00:03 +13: All tests passed!
```

## 8. Keputusan teknis

- UI tidak memanggil secure storage/Firebase langsung; semua lewat repository
  + provider + `PushService`.
- `routeFromMessage` fungsi murni agar bisa diuji tanpa Firebase.
- Semua string rute di `lib/routes.dart` agar deep link FCM dan GoRouter
  memakai konstanta yang sama.
- `DioException` dipetakan di `lib/data/api_errors.dart` agar UI hanya
  menerima pesan ramah, bukan exception mentah.
- Auto-retry Riverpod 3 dinonaktifkan (`retry: (...) => null`) agar error
  langsung final dan mudah diuji.
