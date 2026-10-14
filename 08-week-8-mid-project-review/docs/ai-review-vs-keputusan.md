# AI Review vs Keputusan - Week 8

Prompt, output awal AI sebagai reviewer, verifikasi tiap temuan, dan
keputusan final untuk PR `fix/01-detail-date-format`.

Nama: M.Adhitya Yusuf Al-Ayyubi (NIM 244107020045, Kelas TI-2H)

## 1. Prompt yang digunakan

Prompt diambil persis dari modul:

```text
Review PR Flutter ini sebagai senior Flutter dev.
Konteks: feature-first Clean Architecture (presentation -> domain <- data),
Riverpod, GoRouter, SQLite + Dio.
Fokus: kebenaran, arsitektur, dan test. Abaikan style.
Berikan 5 temuan teratas + level (blocker/saran)
+ alasan + usulan potongan kode perbaikan.
```

Diff yang direview (28 tambah / 1 hapus): `note_detail_page.dart` memakai
`formatNoteTime`, 1 widget test regresi, 1 komentar dokumen presisi.

## 2. Output awal AI (5 temuan)

| # | Level | Temuan + usulan AI |
| :---: | :--- | :--- |
| 1 | Saran | Presisi menit tidak terdokumentasi: kalau produk butuh detik, test tidak menangkap. Usul: komentar dokumen di `formatNoteTime`. |
| 2 | Saran | `find.textContaining('08:05:00')` lemah: hanya membuktikan string detik tidak muncul, bukan bahwa format benar. Usul: bandingkan juga terhadap `toString()` mentah. |
| 3 | Blocker(?) | `AsyncValue.data(initial!)` melewati provider sehingga path loading/error tak teruji. Usul: uji juga tanpa `initial`. |
| 4 | Saran | Terapkan `formatNoteTime` juga di halaman posts/settings agar konsisten di seluruh aplikasi. |
| 5 | Saran | Pindahkan prefix `'Diperbarui: '` ke file l10n agar siap multi-bahasa. |

## 3. Verifikasi tiap temuan (wajib bukti, bukan Reading)

| # | Verifikasi | Hasil |
| :--- | :--- | :--- |
| 1 | Cek `core/format.dart`: tidak ada komentar presisi | ✅ **Benar ada** |
| 2 | Cek test: assertion utama adalah `find.text('Diperbarui: 2026-10-12 08:05')` (eksak); `textContaining` hanya penjaga regresi | ⚠️ **Sebagian benar** — assertion eksak sudah cukup kuat |
| 3 | Cek `note_detail_page.dart`: `initial` dipakai untuk menghindari fetch ulang dari daftar (by design, didokumentasikan di Week 7) | ❌ **Tuduhan keliru** — bukan bug, melainkan desain yang disengaja |
| 4 | Grep `toLocal\|DateTime\|toIso8601` di `pages/posts_page.dart` + `pages/settings_page.dart` | ❌ **Tidak ada** — kedua halaman tidak me-render tanggal sama sekali |
| 5 | Cek kebutuhan produk: aplikasi satu bahasa (Indonesia), tidak ada l10n di pubspec | ⚠️ Benar secara umum, **over-engineering** untuk konteks ini |

## 4. Keputusan final

| # | Keputusan | Alasan + tindak lanjut |
| :--- | :--- | :--- |
| 1 | ✅ **DITERIMA** | Komentar presisi menit + zona lokal ditambahkan ke `formatNoteTime` (masuk commit PR). |
| 2 | ✅ **DITERIMA SEBAGIAN** | Assertion eksak dipertahankan (sudah kuat); tidak menambah assertion ekstra agar test tetap fokus. |
| 3 | ❌ **DITOLAK** | `initial` adalah optimasi yang disengaja (hindari fetch ulang); path loading/error sudah diuji lewat `note_test.dart` (provider gagal → `throwsA`). |
| 4 | ❌ **DITOLAK** | Grep membuktikan tidak ada tanggal di posts/settings — usulan tanpa objek. |
| 5 | ❌ **DITOLAK** | l10n untuk 1 string di app satu bahasa = over-engineering; formatter/CI tidak butuh ini. |

Skor: **2 diterima** (1 jadi kode), **2 ditolak dengan bukti**, 1 sebagian.
Review AI berguna sebagai checklist, tetapi 2 dari 5 temuannya salah/tidak
berlaku — diterimakan mentah akan menambah kode tanpa nilai.

## 5. Bukti test/analyze sesudah tindak lanjut

```text
$ flutter analyze
Analyzing week7_notes_clean...
No issues found!

$ dart format --set-exit-if-changed lib test
Formatted 30 files (0 changed)

$ flutter test
00:01 +17: All tests passed!
```

![Tiga mesin hijau](../screenshots/05-machines.png)
