import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/dashboard_response.dart';
import '../services/token_service.dart';

class DashboardRepository {
  final String baseUrl = dotenv.env['BASE_URL']!;
  final Dio _dio;

  DashboardRepository() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  Future<DashboardResponse> getDashboard() async {
    const endpoint = '/v1/dashboard';
    print('Calling: $baseUrl$endpoint');

    try {
      final token = await TokenService.getToken();

      if (token == null) {
        return DashboardResponse(
          success: false,
          message: 'Token tidak valid atau sudah expired',
          data: null,
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

      print('Status: ${response.statusCode}');
      print('Body: ${response.data}');

      return DashboardResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('STATUS  : ${e.response?.statusCode}');
      print('RESPONSE: ${e.response?.data}');

      return DashboardResponse(
        success: false,
        message:
        e.response?.data?['message'] ?? 'Gagal mengambil data dashboard',
        data: null,
      );
    } catch (e) {
      print('ERROR: $e');
      return DashboardResponse(
        success: false,
        message: 'Terjadi kesalahan pada sistem',
        data: null,
      );
    }
  }
}
