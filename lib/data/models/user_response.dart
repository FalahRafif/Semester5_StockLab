class UserResponse {
  final bool success;
  final String message;
  final List<UserData> users;

  UserResponse({
    required this.success,
    required this.message,
    required this.users,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    final List data = json['data'] ?? [];

    return UserResponse(
      success: json['status'] == 'success',
      message: json['message'] ?? '',
      users: data.map((e) => UserData.fromJson(e)).toList(),
    );
  }
}

class UserData {
  final int id;
  final String email;
  final String name;
  final String phone;
  final String role;
  final String avatar;

  UserData({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.avatar,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return UserData(
      id: parseInt(json['id']),
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}
