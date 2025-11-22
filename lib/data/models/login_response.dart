class LoginResponse {
  final bool success;
  final String message;
  final String? token;
  final int? userId;

  LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.userId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      token: json["token"],
      userId: json["user_id"],
    );
  }
}
