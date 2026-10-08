# AI Challenge - Week 4

Dokumen ini mencatat prompt, output awal AI, verifikasi, perbaikan, dan hasil
testing untuk bagian **AI Challenge** pada praktikum Networking & REST API.

Nama: M.Adhitya Yusuf Al-Ayyubi (NIM 244107020045, Kelas TI-2H)

## 1. Prompt yang digunakan

Prompt diambil persis dari modul:

```text
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error ramah pengguna untuk timeout, connection error,
  404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
```

AI assistant yang dipakai: coding agent pada environment pengerjaan ini
(diminta menulis kode sesuai checklist modul, lalu diverifikasi).

## 2. Output awal AI

AI menghasilkan `Comment` (`fromJson` cast defensif untuk kelima field),
`CommentRepository.fetchComments(postId)` memakai Dio terpusat (timeout
10 detik dari `createDio()`), `commentsOfPostProvider`
(`FutureProvider.family`) untuk state loading/error/data komentar,
unit test `Comment.fromJson` dengan field hilang, serta integrasi ke
halaman detail `/post/:id` (judul + isi + daftar komentar).

## 3. Verifikasi terhadap AI Verification Checklist

| Checklist modul | Temuan pada output awal | Tindakan |
| :--- | :--- | :--- |
| UI tidak memanggil Dio langsung | Halaman hanya `ref.watch` provider | Dipertahankan |
| `fromJson` aman null | `as String? ?? ''`, `(as num?)?.toInt() ?? 0` | Dipertahankan, dibuktikan unit test field hilang |
| Semua `DioExceptionType` dipetakan | timeout, connectionError, badResponse (404/401/403/5xx) di `friendlyErrorMessage` | Dipertahankan |
| `baseUrl`/timeout terpusat | `createDio()` di `api_client.dart` (+ override via `--dart-define=API_BASE_URL`) | Dipertahankan |
| Test menguji field hilang + edge case | fromJson field hilang ada; ditambah edge case 404 dan provider sukses | Dilengkapi |
| `flutter analyze` dan `flutter test` lolos | Bersih, 10 test lulus | Dibuktikan di bawah |

## 4. Perbaikan yang dilakukan

### 4.1 Provider komentar dipindah ke data layer

Awalnya `commentsProvider` didefinisikan di file halaman
(`post_detail_page.dart`) sehingga unit test harus mengimpor UI. Perbaikan:
dipindah ke `lib/data/providers.dart` sebagai `commentsOfPostProvider`
(`FutureProvider.family`) agar bisa diuji tanpa widget.

### 4.2 Tipe `Override` tidak bisa dinamai di Riverpod 3

Helper screenshot `previewOverrides()` awalnya beranotasi
`List<Override>`, tetapi tipe `Override` tidak diekspor publik di
Riverpod 3 (hanya internal). Perbaikan: memakai `List<dynamic>` dengan
komentar penjelasan. Tidak berdampak ke alur normal aplikasi.

### 4.3 Unused import

`flutter analyze` menemukan 2 warning `unused_import` (sisa refactor
provider komentar). Perbaikan: hapus import yang tidak dipakai hingga
`No issues found!`.

### 4.4 Route awal menimpa URL browser

`GoRouter(initialLocation: ...)` memaksa route awal sehingga screenshot
rute `/post/1` gagal (selalu kembali ke `/`). Perbaikan: `initialRoute()`
membaca path URL browser (`/simple`, `/post/:id`) bila tidak ada override
`?route=`.

## 5. Hasil testing

Perintah dan hasil (dijalankan di dalam `week4_api/`, tanpa HTTP sungguhan
di test — semua memakai repository palsu):

```text
$ flutter analyze
Analyzing week4_api...
No issues found!

$ flutter test
00:00 +0: Comment.fromJson aman terhadap field yang hilang
00:00 +1: fromJson aman terhadap field yang hilang
00:00 +2: friendlyErrorMessage untuk 404
00:00 +3: friendlyErrorMessage untuk connection error
00:00 +4: provider komentar sukses dengan repository palsu
00:00 +5: provider sukses dengan repository palsu
00:00 +6: provider error dengan repository palsu
00:00 +7: PostTile menampilkan judul, isi, dan id post
00:00 +8: daftar penuh menampilkan data dari repository palsu
00:00 +9: PagedPostPage menampilkan data dari repository palsu
00:01 +10: All tests passed!
```

## 6. Keputusan teknis

- UI tidak pernah memanggil Dio langsung: semua akses data lewat repository
  + provider, sehingga test tidak butuh internet (repository palsu).
- `fromJson` defensif (`as String? ?? ''`) agar respons API yang tidak sesuai
  dokumentasi tidak menyebabkan crash.
- `friendlyErrorMessage` terpusat di `network_errors.dart` dipakai ulang
  halaman daftar, paged, dan detail.
- Auto-retry Riverpod 3 dinonaktifkan (`retry: (...) => null`) agar error
  langsung final dan mudah diuji; retry tetap manual via tombol
  **Coba lagi** (`ref.invalidate`).
- Pagination memakai guard ganda (`isLoadingMore`, `hasMore`) dan data lama
  dipertahankan saat halaman berikutnya gagal.
- `baseUrl` dapat ditimpa via `--dart-define=API_BASE_URL=` untuk menguji
  skenario error koneksi.
