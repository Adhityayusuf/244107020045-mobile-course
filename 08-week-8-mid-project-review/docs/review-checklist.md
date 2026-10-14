# Review Checklist - Week 8

Audit riwayat, kualitas commit, dan kesiapan tengah semester untuk project
Minggu 5-7 (`week5_offline_notes`, `campus_notify`, `week7_notes_clean`).

Nama: M.Adhitya Yusuf Al-Ayyubi (NIM 244107020045, Kelas TI-2H)

## 1. Audit riwayat git

Perintah dan temuan (dijalankan di root portfolio):

```text
$ git log --oneline -15
c0fcfc3 docs: tandai week 7 selesai di README root
807a4a6 docs: week 7 clean architecture feature-first notes domain data presentation
...

$ git branch -a
* main  (+ remotes/origin/main, tanpa develop/feature)

$ git status
bersih
```

| Temuan | Status | Tindak lanjut |
| :--- | :--- | :--- |
| Semua commit langsung ke `main` | ⚠️ Ditemukan | Buat `develop` sekali dari `main`, push, jadikan target PR; `main` tidak disentuh langsung lagi |
| Tidak ada branch `feature/*` / `fix/*` | ⚠️ Ditemukan | Kerja Week 8 di `fix/01-detail-date-format` → merge ke `develop` |
| Pesan commit tidak konvensional (`fix bug`, `update`) | ✅ Tidak ada | Semua pesan sudah `tipe(scope): deskripsi`; 3 di antaranya masih bisa diperketat (lihat §2) |
| Branch berumur > 1 minggu | ✅ Tidak ada | Hanya `main`; setelah Week 8, branch dihapus seusai merge |
| File tak terlacak yang seharusnya di-commit/di-ignore | ✅ Tidak ada | `git status` bersih; project runnable + `*.py` + `*_output.txt` sudah di-ignore |

Screenshot bukti: `screenshots/01-git-log.png`, `02-branches.png`.

## 2. Tiga pesan commit yang diperketat (simulasi)

Riwayat sudah konvensional, jadi tabel ini berisi tiga pesan yang masih bisa
diperketat beserta alasannya (format `tipe(scope): deskripsi` tetap dipakai):

| Sebelum | Sesudah | Alasan |
| :--- | :--- | :--- |
| `docs: gaya screenshot terminal PowerShell untuk week 1-2` | `docs(screenshots): gaya terminal PowerShell week 1` + commit terpisah untuk week 2 | Satu commit = satu perubahan logis; dua minggu = dua commit agar revert per minggu bisa |
| `docs: tulis ulang semua README dengan gaya sendiri anti-copas` | `docs: tulis ulang README week 1-6 dengan gaya sendiri` | Hindari kata informal (`anti-copas`); sebut cakupan eksplisit (week 1-6) |
| `docs: week 7 clean architecture feature-first notes domain data presentation` | `docs(week7): clean architecture feature-first untuk fitur notes` | Scope eksplisit + deskripsi fokus satu hal (struktur), bukan daftar kata kunci |

Catatan jujur: riwayat yang sudah ter-push tidak ditulis ulang (rewrite
publik merusak kolaborator); tabel ini menjadi acuan gaya commit ke depan.

## 3. Alur kerja Week 8 (bukti GitFlow)

```text
main (c0fcfc3)
 └─ develop (new, dari main)
     └─ fix/01-detail-date-format → 1 commit kecil
         └─ merge --no-ff ke develop → push develop
```

- Issue: `fix/01` — "Tanggal detail memakai `toString()` mentah, bukan
  `formatNoteTime`" (teks issue lengkap di bawah).
- PR: `fix/01-detail-date-format` → `develop`, 28 baris tambah / 1 hapus
  (< 300), 1 fitur, 1 hari.
- Template PR (masalah/solusi/cara uji/screenshot) di bawah.
- Merge hanya setelah review AI terverifikasi + 3 mesin hijau.

Teks issue:

```text
Judul: [fix] Tanggal halaman detail tidak memakai formatNoteTime
Isi: `note_detail_page.dart` menampilkan 'Diperbarui: ${note.updatedAt.toLocal()}'
     (format mentah + detik), melanggar aturan Week 7 (formatting di core/format.dart).
     NoteTile sudah memakai formatNoteTime; halaman detail tertinggal.
Reproduksi: buka /note/1 → baris "Diperbarui" memuat detik.
Kriteria: baris memakai formatNoteTime + ada widget test + analyze/test hijau.
```

Template PR:

```text
Judul: fix(notes): format tanggal detail via formatNoteTime + test
Masalah: tanggal detail memakai toString() mentah (ada detik), tidak konsisten
         dengan NoteTile.
Solusi: pakai formatNoteTime(core) + 1 widget test regresi.
Cara uji: 1) buka /note/1 → "Diperbarui: yyyy-MM-dd HH:mm" (tanpa detik).
         2) flutter test test/widget_test.dart (17 lolos).
         3) flutter analyze bersih, dart format bersih.
Screenshot: 04-detail-after.png
```

Catatan: `gh` CLI tidak tersedia di mesin ini, jadi issue/PR GitHub dibuat
manual via web (branch sudah ter-push sehingga tombol Compare & Pull Request
muncul otomatis). Review AI + keputusan tercatat di
`docs/ai-review-vs-keputusan.md`.

## 4. Kesiapan tengah semester

| Kriteria | Bukti | Status |
| :--- | :--- | :--- |
| Struktur feature-first terbukti | Tiga grep sterilitas Week 7 nol hasil | ✅ |
| `flutter analyze` bersih | `05-machines.png` | ✅ |
| `dart format` rapi | `05-machines.png` (0 changed) | ✅ |
| `flutter test` hijau | 17 test lulus | ✅ |
| PR kecil + commit jelas | `fix/01` (28+/1-), merge commit di `develop` | ✅ |
| README + screenshot + cara menjalankan | Tiap folder minggu | ✅ (Week 1 dilengkapi section Menjalankan) |
| Komentar review ditindaklanjuti | `ai-review-vs-keputusan.md` (2 diterima, 2 ditolak) | ✅ |

**Definisi selesai Week 8:** aplikasi berjalan identik dengan akhir Week 7
(+ 1 perbaikan kecil), tiga mesin hijau, 1 PR kecil di-merge via review,
README memuat status paruh semester + peta issue/PR. Semua terpenuhi.
