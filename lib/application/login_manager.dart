import '../data/repositories/login_repository.dart';

class LoginManager {
  final repo = LoginRepository();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return {
        "success": false,
        "message": "Email dan password tidak boleh kosong"
      };
    }

    final result = await repo.login(email, password);

    return {
      "success": result.success,
      "message": result.message,
      "token": result.token,
      "user_id": result.userId,
    };
  }
}
