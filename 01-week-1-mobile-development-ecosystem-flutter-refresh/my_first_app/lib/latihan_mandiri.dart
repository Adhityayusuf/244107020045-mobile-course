// Latihan mandiri Week 1: dasar Dart + null safety.
// Dijalankan dengan: dart run lib/latihan_mandiri.dart
// (dari dalam folder my_first_app)
// ignore_for_file: avoid_print (file latihan console, print memang tujuannya)

void main() {
  // 1. Fungsi hitung luas persegi panjang.
  const panjang = 8.0;
  const lebar = 5.0;
  print(
    'Luas persegi panjang ($panjang x $lebar) = '
    '${hitungLuasPersegiPanjang(panjang, lebar)}',
  );

  // 2 & 3. Class Profil + penanganan email kosong secara aman.
  const denganEmail = Profil(
    nama: 'M.Adhitya Yusuf Al-Ayyubi',
    nim: '244107020045',
    email: '244107020045@student.polinema.ac.id',
  );
  const tanpaEmail = Profil(
    nama: 'M.Adhitya Yusuf Al-Ayyubi',
    nim: '244107020045',
    email: null,
  );
  print(denganEmail.deskripsi());
  print(tanpaEmail.deskripsi());
}

/// Mengembalikan luas persegi panjang dari [panjang] dan [lebar].
double hitungLuasPersegiPanjang(double panjang, double lebar) {
  return panjang * lebar;
}

class Profil {
  const Profil({required this.nama, required this.nim, this.email});

  final String nama;
  final String nim;
  final String? email;

  /// Email kosong/null ditangani aman tanpa operator `!`.
  String deskripsi() {
    final alamat = email?.trim();
    final tampil = (alamat == null || alamat.isEmpty)
        ? 'BELUM DIISI'
        : alamat;
    return 'Profil(nama: $nama, nim: $nim, email: $tampil)';
  }
}
