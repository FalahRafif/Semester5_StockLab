import '../data/repositories/user_repository.dart';
import '../data/models/user_response.dart';
import 'dart:io';
import 'transaction_manager.dart';

class UserManager {
  final UserRepository _repo = UserRepository();

  Future<UserResponse> getUsers() async {
    return await _repo.getUsers();
  }

  Future<void> testing() async {
    // final filePath =
    //     r'C:/Users/frthe/Downloads/1a167098-0659-43e9-ba96-1dad8fae9cac (2) (1).png';
    //
    // final imageFile = File(filePath);
    //
    // final result = await TransactionManager().createTransaction(productId: "19", userId: "24", quantity: "10", moveType: "IN");
    // print('================');
    // print(result.success);
    // print(result.message);
    // print('================');
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

  Future<UserResponse> deleteUser(int id) async {
    if (id <= 0) {
      return UserResponse(
        success: false,
        message: 'ID user tidak valid',
        users: [],
      );
    }

    return await _repo.deleteUser(id: id);
  }
}
