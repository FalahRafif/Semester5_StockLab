import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_response.dart';
import '../services/token_service.dart';

class UserRepository {
  final String baseUrl = dotenv.env['BASE_URL']!;
  final Dio _dio;

  UserRepository() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  Future<UserResponse> getUsers() async {
    const endpoint = '/v1/users';
    print("Calling: $baseUrl$endpoint");

    try {
      final token = await TokenService.getToken();

      if (token == null) {
        return UserResponse(
          success: false,
          message: 'Token tidak valid atau sudah expired',
          users: [],
        );
      }

      final response = await _dio.get(
        endpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print("Status: ${response.statusCode}");
      print("Body: ${response.data}");

      return UserResponse.fromJson(response.data);
    } catch (e) {
      print("Error: $e");
      return UserResponse(
        success: false,
        message: 'Gagal mengambil data users',
        users: [],
      );
    }
  }
}
