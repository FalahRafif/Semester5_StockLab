import '../data/repositories/user_repository.dart';
import '../data/models/user_response.dart';
import 'dart:io';

class UserManager {
  final UserRepository _repo = UserRepository();

  Future<UserResponse> getUsers() async {
    return await _repo.getUsers();
  }

  Future<void> testing() async {

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

  Future<UserResponse> updateUser({
    required String id,
    required String email,
    required String password,
    required String name,
    required String phone,
    File? avatarFile,
  }) async {
    final parsedId = int.tryParse(id) ?? 0;

    if (parsedId <= 0) {
      return UserResponse(
        success: false,
        message: 'ID user tidak valid',
        users: [],
      );
    }

    if (email.isEmpty || name.isEmpty || phone.isEmpty) {
      return UserResponse(
        success: false,
        message: 'Field wajib tidak boleh kosong',
        users: [],
      );
    }

    return await _repo.updateUser(
      id: parsedId,
      email: email,
      password: password,
      name: name,
      phone: phone,
      avatarFile: avatarFile,
    );
  }
}
