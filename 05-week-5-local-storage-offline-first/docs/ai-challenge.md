# AI Challenge - Week 5

Dokumen ini mencatat prompt, output awal AI, verifikasi, perbaikan, keputusan
final, dan hasil testing untuk bagian **AI Prompt Challenge** pada praktikum
Local Storage & Offline First.

Nama: M.Adhitya Yusuf Al-Ayyubi (NIM 244107020045, Kelas TI-2H)

## 1. Prompt yang digunakan

Prompt diambil persis dari modul:

```text
Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema.
Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift
untuk dua kebutuhan ini. Requirements:
- Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream),
  type-safety, ukuran boilerplate, dan kemudahan testing.
- Beri rekomendasi final: mana untuk preferensi, mana untuk catatan,
  beserta alasannya dalam 1 tabel.
- Tunjukkan skema tabel/kotak untuk 1000+ catatan.
Jelaskan trade-off setiap pilihan.
```

AI assistant yang dipakai: coding agent pada environment pengerjaan ini
(diminta mengusulkan pilihan storage sesuai checklist modul, lalu
diverifikasi dan diperbaiki).

## 2. Output awal AI

### 2.1 Tabel perbandingan storage (versi awal AI)

| Kriteria | SharedPreferences | Hive | sqflite (SQLite) | Drift |
| :--- | :--- | :--- | :--- | :--- |
| Kompleksitas query | Tidak ada (key-value) | Rendah (box key-value) | Sedang (SQL manual) | Rendah (API type-safe) |
| Kebutuhan relasi | Tidak cocok | Terbatas | Kuat (JOIN, FK) | Kuat (FK + stream) |
| Reaktivitas (stream) | Tidak ada | `watch()` per box | Tidak ada (manual) | Ya, stream per query |
| Type-safety | Rendah | Sedang (adapter) | Rendah (String/Map) | Tinggi (generated) |
| Ukuran boilerplate | Sangat kecil | Kecil | Sedang | Besar (codegen) |
| Kemudahan testing | Mudah (mock store) | Sedang | Sedang (in-memory) | Mudah (in-memory) |
| **Rekomendasi AI** | Preferensi | Alternatif | **Catatan** | Alternatif besar |

Rekomendasi awal AI: **SharedPreferences untuk preferensi, sqflite untuk
catatan.**

### 2.2 Skema tabel catatan 1000+ (versi awal AI)

```sql
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL
);
```

### 2.3 Kode CRUD awal AI (dipotong)

```dart
Future<List<Note>> fetchNotes() async {
  final db = await openNotesDb();
  final rows = await db.query('notes', orderBy: 'updated_at DESC');
  return rows.map(Note.fromMap).toList();
}
```

## 3. Verifikasi terhadap AI Verification Checklist

| Checklist modul | Temuan pada output awal | Tindakan |
| :--- | :--- | :--- |
| Apakah AI menempatkan daftar catatan di SharedPreferences? | Tidak. AI menaruh catatan di sqflite dan menolak SharedPreferences untuk koleksi | Aman, dipertahankan |
| Apakah skema mendukung antrean sync (dirty / updated_at)? | **Tidak.** Skema awal hanya punya `updated_at`, tanpa `dirty` | Ditambah kolom `dirty INTEGER NOT NULL DEFAULT 0` |
| Apakah klaim "real-time" didukung stream? | AI tidak mengklaim real-time untuk sqflite; reaktivitas diserahkan ke Riverpod | Aman. Reaktivitas ditangani `AsyncNotifierProvider` |
| Apakah estimasi boilerplate masuk akal? | Ya. `flutter pub add sqflite path` ringan; Drift butuh `build_runner` + codegen | Dipertahankan |
| Test menguji field hilang + repository palsu? | AI belum membuat test | Ditambah `test/note_test.dart` + `FakeNoteRepository` |

## 4. Perbaikan yang dilakukan

### 4.1 Dirty flag untuk antrean sinkronisasi

Skema awal AI tidak mendukung sync offline. Ditambahkan kolom `dirty` pada
tabel `notes` serta method `countDirty()` dan `markAllSynced()` pada
`NoteRepository`, lalu `syncNotes()` di `lib/data/sync.dart` (hitung kotor →
simulasi upload → tandai bersih hanya setelah sukses).

### 4.2 Tabel cache untuk cache-first read

Modul meminta cache-first read untuk data API. Ditambahkan tabel
`cached_posts(id, payload, cached_at)` dan abstraksi `PostCacheStore`
(`SqflitePostCacheStore` untuk native, `InMemoryPostCacheStore`/`SeedPostCacheStore`
untuk web/test/demo). `PostsCacheNotifier` menampilkan cache seketika, refresh
jaringan di background, dan tetap menampilkan cache bila refresh gagal.

### 4.3 Aturan konflik eksplisit

Dipilih **last-write-wins berdasarkan `updated_at`**: daftar selalu diurutkan
`updated_at DESC`, dan saat sync catatan yang lebih baru menang. Aturan ini
didokumentasikan di README agar sinkronisasi dua arah tidak menimpa data
secara diam-diam.

### 4.4 `openDb` disuntikkan untuk testing

Constructor `NoteRepository({Future<Database> Function()? openDb})`
memungkinkan test memakai `FakeNoteRepository` tanpa menyentuh SQLite
sungguhan (mengikuti contoh modul). Test berjalan tanpa database dan tanpa
HTTP.

### 4.5 Dukungan web untuk demo/screenshot

Agar screenshot bisa diambil di browser (viewport mobile 390x844),
ditambahkan `initializeDatabaseFactory()` di
`lib/data/local/notes_database_factory.dart` yang mengisi
`databaseFactory` sqflite dengan `databaseFactoryFfiWebNoWebWorker` dari
`sqflite_common_ffi_web` saat `kIsWeb`. Di Android tetap memakai sqflite asli.

### 4.6 Perbaikan kecil saat implementasi

- `AsyncValue.valueOrNull` tidak ada di Riverpod 3.4: dipakai `.value`.
- Tipe `Override` hanya diekspor dari `package:riverpod/misc.dart`: diimpor
  eksplisit untuk helper demo screenshot.
- `PrefsRepository` memakai initializing formal `this.prefs` agar lolos
  `prefer_initializing_formals`.
- Banner "Mode offline" ditambahkan ke `NotesPage` agar bukti mode pesawat
  terlihat berbeda dari daftar normal.

## 5. Keputusan final

| Kebutuhan | Pilihan | Alasan |
| :--- | :--- | :--- |
| Preferensi (tema, terakhir dibuka) | **SharedPreferences** | Nilai primitif kecil, tanpa query, API paling sederhana |
| Daftar catatan (1000+) | **sqflite (SQLite)** | Query terurut, update parsial, kolom `dirty` untuk antrean sync |
| Cache posts API | **sqflite** (native) / in-memory (web) | Payload JSON terindeks `id`, mudah di-invalidate |

Keputusan ini **sama** dengan rekomendasi awal AI (SharedPreferences +
sqflite), tetapi skema dan lapisan sync diperbaiki agar benar-benar
offline-first.

## 6. Hasil testing

Perintah dan hasil (dijalankan di dalam `week5_offline_notes/`, tanpa SQLite
atau HTTP sungguhan di test — semua memakai repository palsu):

```text
$ flutter analyze
Analyzing week5_offline_notes...
No issues found!

$ flutter test
00:00 +0: test/note_test.dart: fromMap aman terhadap field yang hilang
00:00 +1: test/note_test.dart: flag dirty bertahan pada serialisasi
00:00 +2: test/widget_test.dart: NoteTile menampilkan badge belum tersinkron
00:00 +3: test/note_test.dart: provider sukses dengan repository palsu
00:00 +4: test/note_test.dart: provider error dengan repository palsu
00:00 +5: test/note_test.dart: countDirty menghitung catatan belum tersinkron
00:00 +6: test/widget_test.dart: NoteTile tidak menampilkan badge saat sinkron
00:01 +7: All tests passed!
```

## 7. Keputusan teknis

- UI tidak pernah memanggil SQLite/SharedPreferences langsung; semua lewat
  repository + provider.
- Daftar catatan tidak disimpan di SharedPreferences karena koleksi butuh query,
  update parsial, dan sinkronisasi yang tidak praktis pada key-value.
- `dirty` disimpan sebagai integer 0/1 agar cocok dengan tipe SQLite.
- `updated_at` disimpan sebagai ISO-8601 agar urutannya leksikografis sama
  dengan urutan waktu (aman untuk `ORDER BY`).
- Cache-first: UI menampilkan cache seketika, refresh jaringan berjalan di
  background dan tetap menampilkan cache bila refresh gagal.
- Auto-retry Riverpod 3 dinonaktifkan (`retry: (...) => null`) agar error
  langsung final dan mudah diuji; retry tetap manual via tombol **Coba lagi**.
