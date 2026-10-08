# AI Challenge - Week 3

Dokumen ini mencatat prompt, output awal AI, verifikasi, perbaikan, dan hasil
testing untuk bagian **AI Challenge** pada praktikum Navigation & State
Management.

Nama: M.Adhitya Yusuf Al-Ayyubi (NIM 244107020045, Kelas TI-2H)

## 1. Prompt yang digunakan

Prompt diambil persis dari modul:

```text
Buatkan halaman Flutter bernama StatsPage menggunakan flutter_riverpod.
Requirements:
- ConsumerWidget dengan satu AsyncNotifierProvider yang mensimulasikan
  pengambilan data statistik (delay 2 detik, kadang gagal 30%).
- UI harus menangani loading (spinner), error (pesan + tombol retry),
  dan success (ListView 3 item).
- Berikan unit test untuk notifier-nya.
Jelaskan setiap bagian kode dalam komentar.
```

AI assistant yang dipakai: coding agent pada environment pengerjaan ini
(diminta menulis kode sesuai checklist modul, lalu diverifikasi).

## 2. Output awal AI

AI menghasilkan `StatsNotifier` (`AsyncNotifier<Stats>`) dengan `Random`,
`delay`, dan `failureRate` sebagai parameter konstruktor, model `Stats`
(`total`, `done`, `remaining`, `completion`, `percent`), `StatsPage`
(`ConsumerWidget` dengan `AsyncValue.when`: loading berlabel, error +
tombol **Coba lagi**, success berupa cincin progres + tiga baris angka,
empty saat belum ada tugas), serta unit test sukses/gagal di
`stats_provider_test.dart`. Sejak awal sudah dipakai `NotifierProvider`
(Refactoring: filter), `AsyncValue.guard` untuk refresh, dan operasi todo
berbasis objek.

## 3. Verifikasi terhadap AI Verification Checklist

| Checklist modul | Temuan pada output awal | Tindakan |
| :--- | :--- | :--- |
| State diubah immutable (tidak ada `state.add`/mutasi list) | `add`/`toggle`/`remove` selalu membuat list baru | Dipertahankan, dibuktikan unit test |
| `ref.watch` hanya di `build`, `ref.read` di callback | Sudah benar | Dipertahankan |
| Ketiga state AsyncValue ditangani | Loading, error + retry, success, dan empty | Dipertahankan |
| Provider bertipe eksplisit, tidak duplikat | `NotifierProvider` / `AsyncNotifierProvider` eksplisit | Dipertahankan |
| Tidak memakai API Riverpod lama (`StateProvider`, `StateNotifierProvider`, `Consumer` bertingkat) | Tidak ada API lama | Tidak perlu perbaikan |
| `flutter analyze` dan `flutter test` lolos | Bersih, 6 test lulus | Dibuktikan di bawah |

## 4. Perbaikan yang dilakukan

### 4.1 Random di-inject agar unit test deterministik

Sejak awal `Random`, `delay`, dan `failureRate` dijadikan parameter
konstruktor, lalu di-override di test:

```dart
statsProvider.overrideWith(
  () => StatsNotifier(random: Random(0), delay: Duration.zero, failureRate: 0),
);
```

Tanpa ini unit test tidak bisa memaksa sukses (`failureRate: 0`) atau
gagal (`failureRate: 1`).

### 4.2 Auto-retry Riverpod 3 dinonaktifkan

Riverpod 3 otomatis mengulang provider yang gagal (exponential backoff),
sehingga error state tidak bertahan dan unit test gagal bisa menggantung.
Perbaikan: retry dimatikan agar retry tetap manual lewat tombol:

```dart
ProviderScope(
  retry: (retryCount, error) => null,
  child: const MyApp(),
)
```

Unit test memakai `ProviderContainer(retry: (retryCount, error) => null)`
yang sama.

### 4.3 Operasi todo berbasis objek, bukan index

`toggle(index)` / `remove(index)` dari contoh modul bisa menghapus item
yang salah saat filter aktif (index tampil != index state). Perbaikan:
method menerima objek `Todo` dan mencocokkan dengan `identical`.

### 4.4 Statistik dari data sungguhan, bukan hardcoded

`StatsNotifier.build()` membaca `todoListProvider` (di-`watch` agar ikut
ter-update) dan menghitung `total`/`done` dari daftar sebenarnya. Model
`Stats` memisahkan angka dari presentasi sehingga unit test memeriksa
angka, bukan string.

## 5. Hasil testing

Perintah dan hasil (dijalankan di dalam `week3_todo/`):

```text
$ flutter analyze
Analyzing week3_todo...
No issues found!

$ flutter test
00:00 +0: ... statistik sukses menghitung total, selesai, dan sisa
00:00 +1: ... add, toggle, dan remove menghasilkan state baru
00:00 +2: ... filteredTodosProvider mengikuti filter
00:00 +3: ... menambah tugas baru (widget)
00:00 +4: ... berpindah ke halaman statistik lewat GoRouter (widget)
00:01 +5: ... statistik gagal memunculkan AsyncError
00:02 +6: All tests passed!
```

Unit test `stats_provider_test.dart` menguji `StatsNotifier` secara langsung
(sukses: total 2, selesai 1, sisa 1, 50%; gagal: `AsyncError`), sehingga
halaman statistik terverifikasi tanpa membangun UI. Widget test membangun
aplikasi lewat GoRouter dan memastikan alur tambah tugas serta navigasi ke
Statistik (baris "Total tugas" dan "Belum selesai" tampil).

## 6. Keputusan teknis

- Memakai `AsyncNotifier` + `AsyncValue` (bukan tiga boolean) supaya loading,
  error, dan data tidak bisa berada di kondisi saling bertentangan.
- Menonaktifkan auto-retry agar perilaku UI dapat diprediksi dan sesuai
  instruksi modul (retry manual).
- Statistik dihitung dari state todo yang sebenarnya, sehingga halaman tidak
  menampilkan angka fiktif.
- Provider mengembalikan model `Stats`, bukan `List<String>`, agar angka dan
  presentasi terpisah dan dapat diuji.
- Operasi todo berbasis objek (bukan index) agar tetap benar saat filter aktif.
- `StatefulShellRoute.indexedStack` untuk `NavigationBar` agar state tiap tab
  bertahan saat berpindah halaman.
