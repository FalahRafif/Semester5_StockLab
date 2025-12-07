class LoginResponse {
  final bool success;
  final String message;
  final String? token;
  final int? roleId;
  final String? role;

  LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.roleId,
    this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json["data"];

    return LoginResponse(
      success: json["status"] == "success",
      message: json["message"] ?? "",
      token: data != null ? data["token"] : null,
      roleId: data != null ? data["roleId"] : null,
      role: data != null ? data["role"] : null,
    );
  }
}
