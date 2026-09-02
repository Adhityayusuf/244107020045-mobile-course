void main() {
  hitungLuasPersegiPanjang(panjang: 3, lebar: 3);
  profil(nama : 'Abdul Ghofur Almiqbadi', nim: '244107020155');
}

void hitungLuasPersegiPanjang({required int panjang, required int lebar}) {
  int luas = panjang*lebar;
  print('Luas persegi panjang dari panjang: $panjang dan lebar: $lebar adalah $luas');
}

void profil({required String nama, required String nim, String? email}) {
  print('NAMA: $nama\nNIM: $nim');
  if (email != null){
    print('Email: $email');
  }
}
