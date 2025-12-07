import '../data/repositories/login_repository.dart';
import '../data/models/login_response.dart';

class LoginManager {
  final repo = LoginRepository();

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return LoginResponse(
        success: false,
        message: "Email dan password tidak boleh kosong",
      );
    }

    final result = await repo.login(email, password);
    print(result);
    return result;
  }
}
