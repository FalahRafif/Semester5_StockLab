import '../data/repositories/transaction_repository.dart';
import '../data/models/transaction_response.dart';
import '../data/services/token_service.dart';

class TransactionManager {
  final TransactionRepository _repo = TransactionRepository();

  /// startDate & endDate optional (YYYY-MM-DD)
  Future<TransactionResponse> getTransactions({
    String? startDate,
    String? endDate,
  }) async {
    if (!_isValidDate(startDate) || !_isValidDate(endDate)) {
      return TransactionResponse(
        success: false,
        message: 'Format tanggal harus YYYY-MM-DD',
        transactions: [],
      );
    }

    return await _repo.getTransactions(
      startDate: startDate,
      endDate: endDate,
    );
  }

  bool _isValidDate(String? value) {
    if (value == null || value.isEmpty) return true;

    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    return regex.hasMatch(value);
  }

  Future<TransactionResponse> createTransaction({
    required int productId,
    required int quantity,
    required String moveType,
  }) async {

    final userId = await TokenService.getUserId();

    if (userId == null) {
      return TransactionResponse(
        success: false,
        message: 'Session habis, silakan login ulang',
        transactions: [],
      );
    }

    if (quantity <= 0) {
      return TransactionResponse(
        success: false,
        message: 'Quantity tidak valid',
        transactions: [],
      );
    }

    return await _repo.createTransaction(
      productId: productId,
      userId: int.parse(userId), // 🔥 otomatis
      quantity: quantity,
      moveType: moveType,
    );
  }

}
