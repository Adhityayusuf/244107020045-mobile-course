# Portofolio Praktikum Pemrograman Mobile

Kumpulan tugas mingguan mata kuliah Pemrograman Mobile — Jurusan Teknologi
Informasi, Politeknik Negeri Malang. Dikerjakan dengan Flutter SDK dan
bahasa Dart. Tiap folder minggu mandiri: ada kode, test, screenshot bukti,
dan catatan pengerjaan.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev/) [![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev/) [![Progress](https://img.shields.io/badge/progress-minggu_06-blue)](portfolio-summary.md)

## Profil

- **Nama:** M.Adhitya Yusuf Al-Ayyubi
- **NIM:** 244107020045 — **Kelas:** TI-2H
- **Prodi:** Teknik Informatika, **Jurusan:** Teknologi Informasi
- **Kampus:** Politeknik Negeri Malang

## Peta pengerjaan

| # | Materi | Kondisi | Bukti |
| --- | --- | --- | --- |
| 01 | Ekosistem Mobile & Flutter Refresh | Selesai | [`01-...`](01-week-1-mobile-development-ecosystem-flutter-refresh) |
| 02 | Declarative UI & Responsive Design | Selesai | [`02-...`](02-week-2-declarative-ui-responsive-design) |
| 03 | Navigation & State Management (Riverpod) | Selesai | [`03-...`](03-week-3-navigation-state-management) |
| 04 | Networking & REST API | Selesai | [`04-...`](04-week-4-networking-rest-api) |
| 05 | Local Storage & Offline-First | Selesai | [`05-...`](05-week-5-local-storage-offline-first) |
| 06 | Authentication, Security & FCM | Selesai | [`06-...`](06-week-6-authentication-security-fcm) |
| 07 | Clean Architecture | Belum mulai | [`07-...`](07-week-7-clean-architecture) |
| 08 | Mid Project Review & Code Review | Belum mulai | [`08-...`](08-week-8-mid-project-review) |
| 09 | AI-assisted Development / Vibe Coding | Belum mulai | [`09-...`](09-week-9-ai-assisted-development) |
| 10 | AI Feature Integration | Belum mulai | [`10-...`](10-week-10-ai-feature-integration) |
| 11 | Performance Optimization | Belum mulai | [`11-...`](11-week-11-performance-optimization) |
| 12 | Testing & Quality Assurance | Belum mulai | [`12-...`](12-week-12-testing-quality-assurance) |
| 13 | CI/CD & Automation | Belum mulai | [`13-...`](13-week-13-ci-cd-automation) |
| 14 | Deployment & Monitoring | Belum mulai | [`14-...`](14-week-14-deployment-monitoring) |
| 15 | Secure Mobile Development | Belum mulai | [`15-...`](15-week-15-secure-mobile-development) |
| 16 | Final Project Expo | Belum mulai | [`16-...`](16-week-16-final-project-expo) |

## Ringkasan tiap minggu

### Minggu 1 — Ekosistem & refresh Flutter

Environment siap (`flutter doctor`/`devices`), latihan dasar Dart, dan
aplikasi profil mahasiswa pertama. Ada catatan hot reload vs hot restart.
Selengkapnya: [`01-.../README.md`](01-week-1-mobile-development-ecosystem-flutter-refresh/README.md)

### Minggu 2 — UI deklaratif & responsif

Dashboard Academic Overview (profil + 4 kartu: Assignments, Attendance, GPA,
Current Week). Satu kolom di 390px, dua kolom di 1100px via `LayoutBuilder`;
ganti tema pakai `CupertinoSwitch` + label `Semantics`. 4 widget test lolos.
Selengkapnya: [`02-.../README.md`](02-week-2-declarative-ui-responsive-design/README.md)

### Minggu 3 — Navigasi & state

Multi-halaman GoRouter (`/`, `/produk`, `/stats`, detail berparameter) dan
state Riverpod (`Notifier` + filter Semua/Aktif/Selesai). `AsyncValue`
menangani loading, error + tombol Coba lagi, success, dan empty. 6 test
lolos, analyze bersih.
Selengkapnya: [`03-.../README.md`](03-week-3-navigation-state-management/README.md)

### Minggu 4 — Networking & REST API

Klien `dio` terpusat (base URL, timeout 10 detik, interceptor), model
`Post`/`Comment` yang aman null, repository pattern, 4 state UI, infinite
scroll 10 item/halaman, dan detail `/post/:id` + komentar. 10 test lolos,
analyze bersih.
Selengkapnya: [`04-.../README.md`](04-week-4-networking-rest-api/README.md)

### Minggu 5 — Penyimpanan lokal & offline-first

Tema + terakhir dibuka di `SharedPreferences`; CRUD catatan di SQLite;
dirty flag + Sync; cache-first `GET /posts`; toggle `forceOffline` untuk
bukti mode pesawat; detail `/note/:id`. 7 test lolos, analyze bersih.
Selengkapnya: [`05-.../README.md`](05-week-5-local-storage-offline-first/README.md)

### Minggu 6 — Auth, keamanan & FCM

Login mock + guard route, token di secure storage, Dio refresh sekali saat
401, FCM (permission, token lifecycle, topik, handler 3 state + deep link
`/pengumuman/:id`). 13 test lolos, analyze bersih.
Selengkapnya: [`06-.../README.md`](06-week-6-authentication-security-fcm/README.md)

## Menjalankan salah satu project

```bash
flutter doctor
cd 02-week-2-declarative-ui-responsive-design
flutter pub get
flutter run -d chrome
```

## Sumber

- Codelab praktikum JTI Polinema (<https://jti-polinema.github.io/flutter-codelab/>)
- Dokumentasi Flutter (<https://docs.flutter.dev/>) · Panduan Dart (<https://dart.dev/guides>) · Riverpod (<https://riverpod.dev/docs>)
