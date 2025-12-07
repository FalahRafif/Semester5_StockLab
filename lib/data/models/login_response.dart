class LoginResponse {
  final bool success;
  final String message;
  final String? token;
  final int? userId;
  final String? role;

  LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.userId,
    this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json["data"];

    int? parseRoleId(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return LoginResponse(
      success: json["status"] == "success",
      message: json["message"] ?? "",
      token: data != null ? data["token"] as String? : null,
      userId: data != null ? parseRoleId(data["user_id"]) : null,
      role: data != null ? data["role"] as String? : null,
    );
  }
}
