import '../data/repositories/user_repository.dart';
import '../data/models/user_response.dart';
import 'dart:io';

class UserManager {
  final UserRepository _repo = UserRepository();

  Future<UserResponse> getUsers() async {
    return await _repo.getUsers();
  }

  Future<UserResponse> createUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    File? avatarFile,
  }) async {
    // Validasi ringan (controller-level)
    if (email.isEmpty ||
        password.isEmpty ||
        name.isEmpty ||
        phone.isEmpty) {
      return UserResponse(
        success: false,
        message: 'Semua field wajib diisi',
        users: [],
      );
    }

    return await _repo.createUser(
      email: email,
      password: password,
      name: name,
      phone: phone,
      avatarFile: avatarFile,
    );
  }
}
