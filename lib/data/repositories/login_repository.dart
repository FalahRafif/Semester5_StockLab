import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/login_response.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginRepository {
  final String baseUrl = dotenv.env['BASE_URL']!;

  Future<LoginResponse> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/stocklab-api/v1/login");
    print("Calling: $url");

    try {
      final response = await http
          .post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": email,
          "password": password,
        }),
      )
          .timeout(const Duration(seconds: 10));

      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      // Jika sukses
      return LoginResponse.fromJson(jsonDecode(response.body));
    }
    catch (e) {
      return LoginResponse(
        success: false,
        message: "Terjadi kesalahan: $e",
      );
    }

  }
}
