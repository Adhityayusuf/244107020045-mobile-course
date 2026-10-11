# AI Challenge - Week 7

Dokumen ini mencatat prompt, output awal AI, verifikasi, tabel
usulan-vs-keputusan-final, dan bukti tiga grep sterilitas untuk bagian
**AI Prompt Challenge** pada praktikum Clean Architecture.

Nama: M.Adhitya Yusuf Al-Ayyubi (NIM 244107020045, Kelas TI-2H)

## 1. Prompt yang digunakan

Prompt diambil persis dari modul:

```text
Project Flutter saya: campus_notify (auth + FCM + daftar pengumuman).
Kondisi kini: folder lib/{data, providers, pages, messaging},
repository tercampur dengan implementasi, widget memanggil Dio langsung.
Tugas:
1. Usulkan struktur feature-first Clean Architecture
   (presentation/domain/data) untuk fitur auth + announcements.
2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana,
   dan kapan use case benar-benar dibutuhkan vs repository langsung.
4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).
Jelaskan trade-off setiap keputusan.
```

AI assistant yang dipakai: coding agent pada environment pengerjaan ini
(diminta mengusulkan reorganisasi, lalu saya nilai sendiri dan putuskan).

## 2. Output awal AI

AI mengusulkan pemecahan lengkap `campus_notify` menjadi
`features/auth/{domain,data,presentation}` dan
`features/announcements/{domain,data,presentation}`, dengan:

- entity tanpa mapping, model terpisah dengan `toEntity()`;
- interface repository di `domain`, implementasi di `data`;
- satu use case per operasi CRUD;
- wiring DI seluruhnya di file provider;
- `Failure`/record untuk sukses-gagal tanpa exception bocor.

Untuk tiap file lama AI memberi tujuan baru (pindah/pecah/hapus).

## 3. Verifikasi terhadap AI Verification Checklist

| Checklist modul | Temuan pada usulan AI | Tindakan |
| :--- | :--- | :--- |
| Domain bebas Flutter/Dio/SQLite? | Dinyatakan benar **tanpa bukti grep** | Saya buktikan dengan grep (lihat bagian 6), bukan Reading sekilas |
| Use case untuk tiap CRUD satu-baris? | **Ya, AI membuat `GetPosts`, `GetPost`, `DeletePost`, ...** | Saya **tolak** sebagian besar: over-engineering untuk app kecil |
| Entity bebas mapping? | Ya | Dipertahankan (`NoteModel extends Note` + `toEntity()`) |
| Wiring terpusat di provider? | Ya | Dipertahankan (`notes_providers.dart`) |
| Widget tidak `new Repository()`? | Ya | Dibuktikan grep ke-3 nol hasil |

## 4. Perbaikan/penyesuaian yang saya lakukan

### 4.1 Menolak use case per CRUD satu-baris (over-engineering)

AI membuat use case untuk setiap operasi CRUD. Saya menolak untuk operasi
yang benar-benar satu-baris tanpa aturan bisnis. Yang saya jadikan use case
hanya operasi dengan **aturan bisnis nyata**:

| Use case | Alasan harus ada |
| :--- | :--- |
| `SyncNotes` | Aturan: tandai bersih hanya setelah "server" sukses; punya gate `countDirty` |
| `AddNote` | Aturan validasi: judul kosong ditolak **sebelum** menyentuh database |
| `GetNotes` | Dipakai sebagai satu pintu baca + seam test (konsisten untuk notifier) |

`findNote`, `deleteNote`, `markAllSynced`, dan `countDirty` tetap repository
langsung ke notifier karena tidak punya aturan bisnis.

### 4.2 Feature scope: hanya `notes`, bukan dua fitur penuh

Jobsheet FC #1 meminta pola yang sama diterapkan ke fitur kedua. Saya
memilih **hanya** fitur `notes` yang di-refactor penuh, karena:
prefs/posts/cache bukan domain bisnis (baca-simpan preferensi + cache API),
jadi tidak punya aturan bisnis worthy use case. Menerapkan use case ke sana
justru over-engineering. Trade-off ini saya catat di README.

### 4.3 Cache tidak bergantung pada fitur notes

Dulu `postCacheProvider` mengambil `openDb` dari `NoteRepository` (layer
data fitur notes) — itu coupling tersembunyi antar fitur. Setelah
refactor, `postCacheProvider` memakai `openNotesDb` langsung, jadi
memindahkan/hapus fitur notes tidak merusak cache posts.

### 4.4 Formatting tanggal ke fungsi murni

`note_tile.dart` lama memformat tanggal inline
(`note.updatedAt.toLocal().toString().substring(0, 16)`) — logika
formatting di presentation. Dipindah ke `core/format.dart`
(`formatNoteTime`) yang murni dan ada unit test-nya (Refactoring #2).

### 4.5 Demo/fake repositori mengikuti kontrak baru

`FakeNoteRepository` (demo) dan `FakeNoteRepository` (test) sebelumnya
`extends NoteRepository` (kelas konkret). Sekarang keduanya
`implements NoteRepository` (kontrak domain) — pemisahan interface/impl
justru membuat substitution lebih benar (LSP).

## 5. Tabel usulan AI vs keputusan final

| Usulan AI | Keputusan saya | Alasan |
| :--- | :--- | :--- |
| Pecah `campus_notify` jadi fitur auth + announcements | Refactor **hanya fitur notes** dari Week 5 | Sesuai instructions codelab ("refactor project Anda"); prefs/posts bukan domain bisnis |
| Satu use case per CRUD | **Tolak**; hanya 3 use case (GetNotes, AddNote, SyncNotes) | Use case tanpa aturan bisnis = boilerplate; Liskov/dipakai test |
| `Failure` + record `({notes, failure})` | **Terima** | Sukses/gagal eksplisit, tidak ada exception bocor ke UI |
| `NoteModel extends Note` + `toEntity()` | **Terima** | Mapping hanya di model; boundary data→domain jelas |
| Wiring DI di file provider Riverpod | **Terima** | Tanpa package DI tambahan, sesuai prompt |
| Tambah `get_it`/injector | **Tolak** | Riverpod sudah cukup untuk DI; dependency tambahan berlebihan |

## 6. Hasil verifikasi (tiga grep + analisis + test)

Tiga grep sterilitas (`lib/features/notes/presentation`,
`lib/features/notes/domain`, `lib/core`) — semuanya **nol hasil**, dibuktikan
dengan benar (bukan Reading):

```text
1) presentation steril data mentah        0 hasil
2) domain steril framework                0 hasil
3) instansiasi manual di pages/widgets     0 hasil
```

Screenshot bukti: `screenshots/07-grep.png`.

```text
$ flutter analyze
No issues found!

$ flutter test
... +16: All tests passed!
```

Screenshot: `screenshots/08-analyze-test.png`.

## 7. Keputusan teknis

- **Entity** (`Note`) murni Dart; **Model** (`NoteModel`) memegang
  `toMap/fromMap/toEntity`; boundary selalu `.toEntity()`.
- **Kontrak** `NoteRepository` (abstract) di domain; `NoteRepositoryImpl`
  (SQLite) di data. Exception platform → `LocalFailure`.
- **Wiring** hanya di `notes_providers.dart`: impl → use case → notifier.
  Widget hanya `ref.watch` provider.
- **Cache** tidak lagi bergantung pada fitur notes (coupling dihapus).
- **Formatting** di `core/format.dart` (murni, ada test).
- Auto-retry Riverpod 3 tetap dimatikan (`retry: (...) => null`) agar error
  langsung final dan mudah diuji.
