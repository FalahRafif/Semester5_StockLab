import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/transaction_response.dart';
import '../services/token_service.dart';

class TransactionRepository {
  final String baseUrl = dotenv.env['BASE_URL']!;
  final Dio _dio;

  TransactionRepository() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
  }

  Future<TransactionResponse> getTransactions({
    String? startDate,
    String? endDate,
  }) async {
    const endpoint = '/v1/transactions';
    print("Calling: $baseUrl$endpoint");

    try {
      final token = await TokenService.getToken();

      if (token == null) {
        return TransactionResponse(
          success: false,
          message: 'Token tidak valid atau sudah expired',
          transactions: [],
        );
      }

      final response = await _dio.get(
        endpoint,
        queryParameters: {
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print("Status: ${response.statusCode}");
      print("Body: ${response.data}");

      return TransactionResponse.fromJson(response.data);
    } catch (e) {
      print("Error: $e");
      return TransactionResponse(
        success: false,
        message: 'Gagal mengambil data transaksi',
        transactions: [],
      );
    }
  }


  Future<TransactionResponse> createTransaction({
    required int productId,
    required int userId,
    required int quantity,
    required String moveType, // IN | OUT
  }) async {
    try {
      final token = await TokenService.getToken();

      if (token == null) {
        return TransactionResponse(
          success: false,
          message: 'Token tidak valid',
          transactions: [],
        );
      }

      final formData = FormData.fromMap({
        'product_id': productId.toString(),
        'user_id': userId.toString(),
        'quantity': quantity.toString(),
        'move_type': moveType,
      });

      final response = await _dio.post(
        '/v1/transactions/create',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Jangan set Content-Type manual (multipart boundary)
          },
        ),
      );

      final raw = response.data['data'];

      return TransactionResponse(
        success: response.data['status'] == 'success',
        message: response.data['message'] ?? '',
        transactions:
        raw != null ? [TransactionData.fromJson(raw)] : [],
      );
    } on DioException catch (e) {
      print('STATUS  : ${e.response?.statusCode}');
      print('RESPONSE: ${e.response?.data}');

      return TransactionResponse(
        success: false,
        message:
        e.response?.data?['message'] ??
            'Gagal membuat transaksi',
        transactions: [],
      );
    }
  }

}
