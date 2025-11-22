import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_response.dart';

class LoginRepository {
  final String baseUrl = "http://localhost:3000";

  Future<LoginResponse> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      // 401 / 400 dll
      return LoginResponse.fromJson(jsonDecode(response.body));
    }
  }
}
