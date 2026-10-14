# Minggu 1 — Ekosistem Mobile & Refresh Flutter

Minggu pembuka. Isinya siapin environment, ngulang dasar Dart, dan bikin
aplikasi Flutter pertama (profil mahasiswa).

**M.Adhitya Yusuf Al-Ayyubi · NIM 244107020045 · TI-2H**

## Yang saya kerjakan

**1. Latihan mandiri Dart.** Bikin fungsi `hitungLuasPersegiPanjang`,
kelas `Profil` (`nama`, `nim`, `email` yang boleh null/empty), terus
penanganan email kosong yang aman (pakai `?.` + nilai default, tanpa
operator `!`).
Kode: [`my_first_app/lib/latihan_mandiri.dart`](my_first_app/lib/latihan_mandiri.dart),
dijalankan pakai `dart run lib/latihan_mandiri.dart`.

![Latihan Mandiri](screenshots/LatihanMandiri.png)

**2. Praktikum: aplikasi profil.** Ngikutin kode codelab, jalan di Chrome
viewport HP 390x844.
Kode: [`my_first_app/lib/main.dart`](my_first_app/lib/main.dart).

![Praktikum](screenshots/Praktikum.png)

**3. Mini assignment.** Profil mahasiswa + NIM + info tambahan (kelas TI-2H)
pakai widget dasar.

![Assignment](screenshots/Tugas.png)

## Bukti environment beres

`flutter doctor` nggak ada masalah yang nghambat target Android (ada
2 issue minor yang nggak ngaruh ke target web/Chrome — penjelasannya di
bagian Kendala).

![Doctor](screenshots/FlutterDoctor.png)

`flutter devices` kedeteksi emulator/perangkat fisik:

![Devices](screenshots/FlutterDevices.png)

## Menjalankan

```bash
cd my_first_app
flutter pub get
flutter run -d chrome
```

Latihan mandiri (dari dalam `my_first_app/`):

```bash
dart run lib/latihan_mandiri.dart
```

## Hot reload vs hot restart

**Hot reload** masukin perubahan kode ke aplikasi yang lagi jalan tanpa
ngulang dari awal. Cepat buat iterasi UI, state-nya tetap kejaga.

**Hot restart** berhentiin terus jalanin ulang aplikasi dari awal. Lebih
lambat, dipakainya pas perubahannya gede dan ngaruh ke state, butuh
inisialisasi ulang, atau pas ada error fatal.

## Kendala setup yang saya temui

- `flutter doctor`: Android licenses belum diterima
  (`flutter doctor --android-licenses`) dan instalasi Visual Studio Build
  Tools nggak lengkap. Untungnya dua-duanya nggak nghambat target
  Chrome/web yang saya pakai di sini; Chrome sama Edge kedeteksi di
  `flutter devices`.
- Android Studio sempat nggak ngenalin Flutter sebagai target Android.
  Beres setelah saya pastiin Android SDK, Command-line Tools, dan emulator
  kepasang lewat SDK/Device Manager.

## Refleksi

**Kapan native lebih tepat daripada cross-platform?**
Kalau aplikasinya nuntut performa tinggi atau optimasi khusus di perangkat
tertentu, native lebih cocok karena cross-platform kurang optimal di situ.
Tapi kalau harus rilis ke banyak platform tanpa nulis banyak bahasa native,
cross-platform yang menang.

**Gimana state berhubungan sama widget tree dan UI deklaratif?**
State itu nentuin data yang lagi dipakai. Pas state berubah, widget tree
dibangun ulang secara deklaratif, jadi tampilan ngikutin data terbaru tanpa
harus ngubah UI satu-satu.

**Kenapa commit kecil berpesan jelas ngebantu?**
Buat tim, commit kecil bikin perubahan gampang dilacak spesifik, konflik
minim, koordinasi gampang. Buat portfolio, riwayat yang rapi nunjukin proses
belajar dan kerja yang profesional.
