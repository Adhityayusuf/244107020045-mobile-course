/// Sesi hasil login: access berumur pendek + refresh berumur panjang.
class AuthSession {
  const AuthSession({required this.access, required this.refresh});
  final String access;
  final String refresh;
}

/// Repository auth (mock yang siap diganti Firebase Auth).
///
/// GANTI method [login] dengan
/// `FirebaseAuth.instance.signInWithEmailAndPassword` (atau GoogleSignIn)
/// saat backend Firebase sudah siap. Pola repository dan token refresh-nya
/// identik, sehingga migrasi hanya mengganti sumber token.
class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!email.contains('@') || password.length < 6) {
      throw Exception('Email atau kata sandi tidak valid');
    }
    // Simulasi JWT: header.payload.signature. Jangan parse manual di
    // produksi; verifikasi dilakukan server.
    return AuthSession(
      access: 'mock-access-for-$email',
      refresh: 'mock-refresh-for-$email',
    );
  }

  /// Menukar refresh token dengan access token baru.
  Future<String> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) throw Exception('Refresh token hilang');
    return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}
