class LoginManager {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // Simulasi validasi
    if (email.isEmpty || password.isEmpty) {
      return {
        "success": false,
        "message": "Email dan password tidak boleh kosong"
      };
    }

    // Simulasi cek user (bisa diganti API)
    if (email == "admin@gmail.com" && password == "admin123") {
      return {
        "success": true,
        "message": "Login berhasil"
      };
    }

    return {
      "success": false,
      "message": "Email atau password salah"
    };
  }
}
