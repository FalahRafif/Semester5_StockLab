import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_response.dart';
import '../services/token_service.dart';
import 'dart:io';

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

  Future<UserResponse> createUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    File? avatarFile,
  }) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        return UserResponse(
          success: false,
          message: 'Token tidak valid',
          users: [],
        );
      }

      final formData = FormData.fromMap({
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
        if (avatarFile != null)
          'avatar': await MultipartFile.fromFile(
            avatarFile.path,
            filename: avatarFile.path.split('/').last,
          ),
      });

      final response = await _dio.post(
        '/v1/users/create',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final raw = response.data['data'];

      return UserResponse(
        success: response.data['status'] == 'success',
        message: response.data['message'] ?? '',
        users: raw != null ? [UserData.fromJson(raw)] : [],
      );
    } on DioException catch (e) {
      print('STATUS  : ${e.response?.statusCode}');
      print('RESPONSE: ${e.response?.data}');
      return UserResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Gagal membuat user',
        users: [],
      );
    }
  }

  Future<UserResponse> updateUser({
    required int id,
    required String email,
    required String password,
    required String name,
    required String phone,
    File? avatarFile,
  }) async {
    try {
      final token = await TokenService.getToken();

      if (token == null) {
        return UserResponse(
          success: false,
          message: 'Token tidak valid',
          users: [],
        );
      }

      final formData = FormData.fromMap({
        'id': id.toString(),
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
        if (avatarFile != null)
          'avatar': await MultipartFile.fromFile(
            avatarFile.path,
            filename: avatarFile.path.split('/').last,
          ),
      });

      final response = await _dio.put(
        '/v1/users/update/$id',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Jangan set Content-Type manual, Dio akan set multipart boundary
          },
        ),
      );

      final raw = response.data['data'];

      return UserResponse(
        success: response.data['status'] == 'success',
        message: response.data['message'] ?? '',
        users: raw != null ? [UserData.fromJson(raw)] : [],
      );
    } on DioException catch (e) {
      print('STATUS  : ${e.response?.statusCode}');
      print('RESPONSE: ${e.response?.data}');

      return UserResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Gagal update user',
        users: [],
      );
    }
  }



}
