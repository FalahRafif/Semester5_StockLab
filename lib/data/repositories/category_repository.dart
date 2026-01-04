import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/category_response.dart';
import '../services/token_service.dart';

class CategoryRepository {
  final String baseUrl = dotenv.env['BASE_URL']!;
  final Dio _dio;

  CategoryRepository() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  Future<CategoryResponse> getCategories() async {
    const endpoint = '/v1/categories';
    print("Calling: $baseUrl$endpoint");

    try {
      final token = await TokenService.getToken();

      if (token == null) {
        return CategoryResponse(
          success: false,
          message: 'Token tidak valid atau sudah expired',
          categories: [],
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

      return CategoryResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('STATUS  : ${e.response?.statusCode}');
      print('RESPONSE: ${e.response?.data}');

      return CategoryResponse(
        success: false,
        message: e.response?.data?['message'] ??
            'Gagal mengambil data kategori',
        categories: [],
      );
    } catch (e) {
      print("Error: $e");
      return CategoryResponse(
        success: false,
        message: 'Terjadi kesalahan pada sistem',
        categories: [],
      );
    }
  }

  Future<CategoryResponse> createCategory({
    required String name,
  }) async {
    try {
      final token = await TokenService.getToken();

      if (token == null) {
        return CategoryResponse(
          success: false,
          message: 'Token tidak valid atau sudah expired',
          categories: [],
        );
      }

      final formData = FormData.fromMap({
        'name': name,
      });

      final response = await _dio.post(
        '/v1/categories/create',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Jangan set Content-Type manual (multipart)
          },
        ),
      );

      final raw = response.data['data'];

      return CategoryResponse(
        success: response.data['status'] == 'success',
        message: response.data['message'] ?? '',
        categories:
        raw != null ? [CategoryData.fromJson(raw)] : [],
      );
    } on DioException catch (e) {
      print('STATUS  : ${e.response?.statusCode}');
      print('RESPONSE: ${e.response?.data}');

      return CategoryResponse(
        success: false,
        message: e.response?.data?['message'] ??
            'Gagal membuat kategori',
        categories: [],
      );
    } catch (e) {
      print('Error: $e');
      return CategoryResponse(
        success: false,
        message: 'Terjadi kesalahan pada sistem',
        categories: [],
      );
    }
  }

  Future<CategoryResponse> updateCategory({
    required int id,
    required String name,
  }) async {
    try {
      final token = await TokenService.getToken();

      if (token == null) {
        return CategoryResponse(
          success: false,
          message: 'Token tidak valid atau sudah expired',
          categories: [],
        );
      }

      final formData = FormData.fromMap({
        'id': id.toString(),
        'name': name,
      });

      final response = await _dio.put(
        '/v1/categories/update/$id',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Jangan set Content-Type manual
          },
        ),
      );

      final raw = response.data['data'];

      return CategoryResponse(
        success: response.data['status'] == 'success',
        message: response.data['message'] ?? '',
        categories:
        raw != null ? [CategoryData.fromJson(raw)] : [],
      );
    } on DioException catch (e) {
      print('STATUS  : ${e.response?.statusCode}');
      print('RESPONSE: ${e.response?.data}');

      return CategoryResponse(
        success: false,
        message: e.response?.data?['message'] ??
            'Gagal update kategori',
        categories: [],
      );
    } catch (e) {
      print('Error: $e');
      return CategoryResponse(
        success: false,
        message: 'Terjadi kesalahan pada sistem',
        categories: [],
      );
    }
  }

  Future<CategoryResponse> deleteCategory({
    required int id,
  }) async {
    try {
      final token = await TokenService.getToken();

      if (token == null) {
        return CategoryResponse(
          success: false,
          message: 'Token tidak valid atau sudah expired',
          categories: [],
        );
      }

      final formData = FormData.fromMap({
        'id': id.toString(),
      });

      final response = await _dio.delete(
        '/v1/categories/delete/$id',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Jangan set Content-Type manual
          },
        ),
      );

      // DELETE biasanya tidak mengembalikan object lengkap
      return CategoryResponse(
        success: response.data['status'] == 'success',
        message: response.data['message'] ?? '',
        categories: const [], // konsisten: DELETE tidak return list
      );
    } on DioException catch (e) {
      print('STATUS  : ${e.response?.statusCode}');
      print('RESPONSE: ${e.response?.data}');

      return CategoryResponse(
        success: false,
        message: e.response?.data?['message'] ??
            'Gagal menghapus kategori',
        categories: [],
      );
    } catch (e) {
      print('Error: $e');
      return CategoryResponse(
        success: false,
        message: 'Terjadi kesalahan pada sistem',
        categories: [],
      );
    }
  }

}
