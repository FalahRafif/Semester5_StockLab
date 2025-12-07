import 'package:dio/dio.dart';
import '../models/login_response.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginRepository {
  final String baseUrl = dotenv.env['BASE_URL']!;
  final Dio _dio;

  LoginRepository() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  Future<LoginResponse> login(String email, String password) async {
    final endpoint = '/stocklab-api/v1/login';
    print("Calling: $baseUrl$endpoint");

    try {
      final response = await _dio.post(
        endpoint,
        data: {
          "email": email,
          "password": password,
        },
      );

      print("Status: ${response.statusCode}");
      print("Body: ${response.data}");

      return LoginResponse.fromJson(response.data);
    } catch (e) {
      print("Error: $e");
      return LoginResponse(
        success: false,
        message: "Terjadi kesalahan, Username atau Password Salah",
      );
    }
  }
}
