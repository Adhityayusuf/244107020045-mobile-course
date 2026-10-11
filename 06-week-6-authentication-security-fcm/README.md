# 06 Week 6: Authentication, Security & FCM

Tugas minggu ke-6 mata kuliah Pemrograman Mobile (JTI Polinema). Proyek ini
membangun **Campus Notification App**: login dengan guard route, token aman
di secure storage, Dio dengan refresh otomatis, dan integrasi FCM
(permission, token lifecycle, foreground/background/terminated handler,
deep link, topic messaging).

Nama: M.Adhitya Yusuf Al-Ayyubi (NIM 244107020045, Kelas TI-2H)

> Catatan: folder teman (`Adidtiasmara/244107020094-mobile-course`) untuk
> minggu ini masih placeholder, sehingga isi mengikuti jobsheet modul
> secara penuh dengan konvensi struktur minggu sebelumnya.

## Tujuan

- Menjelaskan alur autentikasi dan perbedaan ID token vs access token vs
  refresh token.
- Menyimpan token secara aman dengan secure storage serta refresh otomatis.
- Menjelaskan arsitektur FCM: app server, Firebase, dan perangkat.
- Meminta notification permission dan mengelola token lifecycle.
- Membedakan notification payload vs data payload pada tiga app state.
- Menangani klik notifikasi (deep link GoRouter) dan topic messaging.
- Menerapkan keamanan dasar (tanpa secret di kode, tanpa log token).

## Fitur Utama

- **Login mock** (siap diganti Firebase Auth) dengan guard route: belum login
  selalu diarahkan ke `/login`.
- **Token aman**: access + refresh hanya di `flutter_secure_storage`
  (in-memory untuk test/demo); tidak di SharedPreferences/log/screenshot.
- **Dio refresh otomatis**: 401 memicu tukar refresh **sekali** lalu retry;
  refresh mati → sesi dibersihkan → paksa login ulang.
- **FCM**: permission runtime, `getToken` + `onTokenRefresh` (terkirim ke
  `POST /devices`), subscribe topik `pengumuman-kampus`.
- **Payload gabungan** `notification + data`; klik membuka `/pengumuman/:id`
  pada ketiga app state (foreground, background, terminated).
- **Token terpotong** di UI (12 karakter + `...`); token penuh tidak pernah
  tampil.
- 13 test lulus (route parsing, token store, auth mock, error mapping,
  provider, widget) tanpa Firebase/HTTP sungguhan.

## Stack Teknologi

- Flutter 3.47 (Dart 3.13)
- `flutter_riverpod` ^3 + `riverpod` ^3
- `go_router` ^18
- `dio` ^5
- `flutter_secure_storage` ^11
- `firebase_core` ^4 + `firebase_messaging` ^16
- `flutter_local_notifications` ^22
- `flutter_test` untuk unit dan widget test

## Struktur Folder

```text
06-week-6-authentication-security-fcm/
├── campus_notify/              # Project Flutter yang dapat dijalankan
│   ├── lib/
│   │   ├── main.dart           # Firebase guarded init + GoRouter guard
│   │   ├── routes.dart         # Konstanta rute + topik + endpoint devices
│   │   ├── data/
│   │   │   ├── auth_repository.dart  # mock login/refresh (titik Firebase Auth)
│   │   │   ├── token_store.dart      # TokenStore + TokenBackend + tokenPreview
│   │   │   ├── api_client.dart       # buildApiClient (refresh-once interceptor)
│   │   │   └── api_errors.dart       # DioException -> pesan ramah
│   │   ├── providers/
│   │   │   ├── auth_provider.dart    # tokenStore/auth/api/push + AuthNotifier
│   │   │   └── push_providers.dart   # PushUiState (token, izin, topik, banner)
│   │   ├── messaging/
│   │   │   └── push_service.dart     # routeFromMessage, handler top-level,
│   │   │                             # PushService + Fake + Firebase impl
│   │   └── pages/ (login_page.dart, home_page.dart, announcement_page.dart)
│   └── test/
│       ├── auth_push_test.dart # route, token store, auth mock, error, provider
│       └── widget_test.dart    # login error, token terpotong, banner
├── lib/                        # Salinan kode final (untuk portofolio)
├── test/                       # Salinan test final (untuk portofolio)
├── docs/
│   └── ai-challenge.md         # Prompt, output AI, perbaikan, tabel 3 state
├── screenshots/
└── README.md
```

> Kode yang dapat dijalankan ada di subfolder `campus_notify/`
> (di-ignore oleh Git). Folder `lib/` dan `test/` berisi salinan final untuk
> dokumentasi portofolio, mengikuti konvensi minggu sebelumnya.

## Alur Token

```text
Login --> access (pendek) + refresh (panjang) tersimpan aman
Request API --header Bearer access--> 401 expired?
Ya --> tukar refresh --> access baru --> ulangi request sekali
Refresh ikut kedaluwarsa --> logout, kembali ke /login
```

Refresh token hanya lewat body POST HTTPS dan hanya di secure storage.

## 1. Login + guard route

<table>
  <tr>
    <td align="center"><strong>Login</strong><br><br>
      <img src="screenshots/01-login.png" width="220" alt="Login"></td>
    <td align="center"><strong>Validasi gagal</strong><br><br>
      <img src="screenshots/02-login-error.png" width="220" alt="Login error"></td>
  </tr>
</table>

## 2. Beranda: token terpotong, izin, topik

<table>
  <tr>
    <td align="center"><strong>Beranda</strong><br><br>
      <img src="screenshots/03-home.png" width="220" alt="Beranda"></td>
    <td align="center"><strong>Token + topik</strong><br><br>
      <img src="screenshots/08-token-topic.png" width="220" alt="Token dan topik"></td>
    <td align="center"><strong>Izin notifikasi</strong><br><br>
      <img src="screenshots/09-permission.png" width="220" alt="Izin"></td>
  </tr>
</table>

Halaman detail `/pengumuman/3` (tujuan deep link):

<p align="center">
  <img src="screenshots/04-announcement.png" width="220" alt="Detail pengumuman">
</p>

## 3. Notification payload vs data payload

| Jenis | Isi | Perilaku sistem |
| :--- | :--- | :--- |
| `notification` | `title` + `body` tampilan | Android otomatis saat background/terminated; foreground butuh manual |
| `data` | key-value bebas (`route`, `id`) | Selalu ke handler; tidak ditampilkan otomatis |

Campus Notification App selalu memakai gabungan keduanya.

## 4. Pengujian tiga app state

| State | Yang diharapkan | Cara uji |
| :--- | :--- | :--- |
| Foreground | Banner lokal muncul, klik masuk ke `/pengumuman/3` | Aplikasi terbuka, kirim dari console/backend |
| Background | Banner sistem muncul, klik masuk ke rute yang benar | Tekan Home, kirim, klik banner |
| Terminated | Aplikasi terbuka ke rute yang benar via `getInitialMessage` | Swipe-close aplikasi, kirim, klik banner |

<table>
  <tr>
    <td align="center"><strong>Foreground (banner manual)</strong><br><br>
      <img src="screenshots/05-foreground.png" width="220" alt="Foreground"></td>
    <td align="center"><strong>Background (banner sistem)</strong><br><br>
      <img src="screenshots/06-background.png" width="220" alt="Background"></td>
    <td align="center"><strong>Terminated (deep link)</strong><br><br>
      <img src="screenshots/07-terminated.png" width="220" alt="Terminated"></td>
  </tr>
</table>

> Firebase Console butuh project Firebase asli; bukti di atas memakai demo
> deterministik (`FakePushService` + seed state) yang mensimulasikan ketiga
> alur handler. Implementasi handler asli ada di
> `lib/messaging/push_service.dart`.

### Topic messaging

- Broadcast (semua mahasiswa/kelas/UKM): topik `pengumuman-kampus`.
- Personal (nilai, tagihan): token perangkat, bukan topik.

## 5. Token lifecycle

1. Minta izin → 2. `getToken()` → kirim `POST /devices` →
3. `onTokenRefresh` memperbarui backend (token basi = tidak ada notifikasi) →
4. subscribe `pengumuman-kampus`.

## Refactoring Challenge

1. **Rute terpusat** di `lib/routes.dart` untuk FCM dan GoRouter.
2. **`routeFromMessage`** fungsi murni yang bisa diunit-test tanpa Firebase.
3. **`api_errors.dart`** memetakan `DioException` agar UI hanya menerima pesan.

## Testing

```bash
cd campus_notify
flutter analyze
flutter test
```

Hasil:

```text
$ flutter analyze
Analyzing campus_notify...
No issues found!

$ flutter test
00:00 +0: routeFromMessage menangani route kosong dan tanpa slash
...
00:03 +13: All tests passed!
```

<p align="center">
  <img src="screenshots/10-analyze-test.png" width="420" alt="flutter analyze dan flutter test">
</p>

## Cara Menjalankan

```bash
cd campus_notify
flutter pub get
flutter run                 # Android (mock auth, tanpa Firebase)
flutter run -d chrome       # Web (FakePushService)
```

Untuk Firebase asli:

1. Buat project di Firebase Console, tambahkan aplikasi Android sesuai
   `applicationId`.
2. Unduh `google-services.json` ke `android/app/` (iOS:
   `GoogleService-Info.plist` + capability Push + APNs key).
3. `Firebase.initializeApp()` sudah dipanggil guarded di `main()`.

## AI Verification Checklist

| Item | Status | Catatan |
| :--- | :---: | :--- |
| Background handler top-level + pragma? | ✅ | Fungsi top-level, tanpa BuildContext |
| `onTokenRefresh` ke backend (bukan log)? | ⚠️ Diperbaiki | Didokumentasikan `POST /devices` |
| Foreground local notification manual? | ✅ | `showForegroundNotification` |
| Klik 3 state ke rute benar? | ✅ | Tabel + screenshot 05/06/07 |
| Tanpa hardcode/log token penuh? | ⚠️ Diperbaiki | `tokenPreview()` 12 karakter |
| Perbedaan Android 13+ vs iOS? | ✅ | Komentar di `FirebasePushService` |

## Checklist Verifikasi Mandiri

- [x] Token hanya di secure storage, tidak di SharedPreferences/log/screenshot.
- [x] 401 memicu refresh sekali lalu retry; refresh mati memaksa login ulang.
- [x] Ketiga app state teruji; klik masuk ke rute yang benar.
- [x] Topik untuk broadcast, token untuk pesan personal.
- [x] `flutter analyze` bersih dan semua test lulus.
- [x] Hasil AI diverifikasi dan didokumentasikan pada folder `docs/`.

## Refleksi

1. **Mengapa refresh token tidak boleh di SharedPreferences?**
   SharedPreferences tidak terenkripsi; bila bocor, penyerang bisa memperbarui
   sesi tanpa batas hingga refresh dicabut server. Secure storage memakai
   Keychain/Keystore yang terenkripsi OS.
2. **Apa yang rusak bila `onTokenRefresh` diabaikan satu semester?**
   Token basi menumpuk di backend (reinstall, clear data, rotasi keamanan)
   sehingga pengumuman penting tidak sampai ke banyak perangkat.
3. **Kapan topik vs token?**
   Topik: pengumuman umum (jadwal berubah, libur). Token: personal (nilai,
   tagihan UKT, undangan khusus).
4. **Bagian draf AI yang ditolak/diperbaiki?**
   Token penuh di Debug (diganti preview), `onTokenRefresh` hanya log
   (diwajibkan kirim backend), API local-notification lama (disesuaikan v22),
   dan Firebase diwajibkan (dibuat opsional/mock-first).

Detail lengkap ada di [`docs/ai-challenge.md`](docs/ai-challenge.md).
