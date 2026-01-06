import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/product_response.dart';
import '../services/token_service.dart';
import 'dart:io';

class ProductRepository {
  final String baseUrl = dotenv.env['BASE_URL']!;
  final Dio _dio;

  ProductRepository() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  Future<ProductResponse> getProducts() async {
    const endpoint = '/v1/products';
    print("Calling: $endpoint");

    try {
      final token = await TokenService.getToken();

      if (token == null) {
        return ProductResponse(
          success: false,
          message: 'Token tidak valid atau sudah expired',
          products: [],
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

      print("STATUS : ${response.statusCode}");
      print("BODY   : ${response.data}");

      return ProductResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('STATUS  : ${e.response?.statusCode}');
      print('RESPONSE: ${e.response?.data}');

      return ProductResponse(
        success: false,
        message: e.response?.data?['message'] ??
            'Gagal mengambil data produk',
        products: [],
      );
    } catch (e) {
      print('Error: $e');
      return ProductResponse(
        success: false,
        message: 'Terjadi kesalahan pada sistem',
        products: [],
      );
    }
  }

  Future<ProductResponse> createProduct({
    required String name,
    required int categoryId,
    required String brand,
    required int price, // ✅ NEW
    File? imageFile,
  }) async {
    final token = await TokenService.getToken();

    final formData = FormData.fromMap({
      'name': name,
      'category_id': categoryId.toString(),
      'brand': brand,
      'price': price.toString(), // ✅ NEW
      if (imageFile != null)
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
    });

    final response = await _dio.post(
      '/v1/products/create',
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    final raw = response.data['data'];

    return ProductResponse(
      success: response.data['status'] == 'success',
      message: response.data['message'] ?? '',
      products: raw != null ? [ProductData.fromJson(raw)] : [],
    );
  }


  Future<ProductResponse> updateProduct({
    required int id,
    required String name,
    required int categoryId,
    required String brand,
    required int price, // ✅ NEW
    File? imageFile,
  }) async {
    final token = await TokenService.getToken();

    final formData = FormData.fromMap({
      'id': id.toString(),
      'name': name,
      'category_id': categoryId.toString(),
      'brand': brand,
      'price': price.toString(), // ✅ NEW
      if (imageFile != null)
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
    });

    final response = await _dio.patch(
      '/v1/products/update/$id',
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    final raw = response.data['data'];

    return ProductResponse(
      success: response.data['status'] == 'success',
      message: response.data['message'] ?? '',
      products: raw != null ? [ProductData.fromJson(raw)] : [],
    );
  }


  Future<ProductResponse> deleteProduct(int id) async {
    try {
      final token = await TokenService.getToken();

      if (token == null) {
        return ProductResponse(
          success: false,
          message: 'Token tidak valid',
          products: [],
        );
      }

      final formData = FormData.fromMap({
        'id': id.toString(),
      });

      final response = await _dio.delete(
        '/v1/products/delete/$id',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // jangan set Content-Type manual
          },
        ),
      );

      final raw = response.data['data'];

      /// API hanya mengembalikan { id: 1 }
      /// Kita bungkus agar tetap konsisten dengan ProductResponse
      return ProductResponse(
        success: response.data['status'] == 'success',
        message: response.data['message'] ?? '',
        products: raw != null
            ? [
          ProductData(
            id: raw['id'],
            name: '',
            category: '',
            sku: '',
            brand: '',
            price: 0,
            image: null,
            quantity: 0
          ),
        ]
            : [],
      );
    } on DioException catch (e) {
      return ProductResponse(
        success: false,
        message:
        e.response?.data?['message'] ?? 'Gagal menghapus produk',
        products: [],
      );
    } catch (e) {
      return ProductResponse(
        success: false,
        message: 'Terjadi kesalahan pada sistem',
        products: [],
      );
    }
  }

}
