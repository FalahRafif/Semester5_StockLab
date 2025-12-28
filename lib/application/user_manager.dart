import '../data/repositories/user_repository.dart';
import '../data/models/user_response.dart';

class UserManager {
  final UserRepository _repo = UserRepository();

  Future<UserResponse> getUsers() async {
    return await _repo.getUsers();
  }
}
