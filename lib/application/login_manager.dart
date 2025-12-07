import '../data/repositories/login_repository.dart';
import '../data/models/login_response.dart';
import '../data/services/token_service.dart';

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
    print(email);
    print(password);
    print(result.token);
    print(result.role);
    // Jika sukses → simpan token & role
    if (result.success && result.token != null && result.role != null) {
      await TokenService.saveAuth(
        token: result.token!,
        userId: result.userId!,
        role: result.role!,
        expiresInSeconds: 86400, // 24 jam
      );
    }

    final roleId = await TokenService.getRole();
    print(roleId);
    return result;
  }
}
