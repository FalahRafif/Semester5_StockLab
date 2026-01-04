class TransactionResponse {
  final bool success;
  final String message;
  final List<TransactionData> transactions;

  TransactionResponse({
    required this.success,
    required this.message,
    required this.transactions,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    final List data = json['data'] ?? [];

    return TransactionResponse(
      success: json['status'] == 'success',
      message: json['message'] ?? '',
      transactions:
      data.map((e) => TransactionData.fromJson(e)).toList(),
    );
  }
}

class TransactionData {
  final int id;
  final String productName;
  final String productSku;
  final String productBrand;
  final int productPrice;
  final String picName;
  final int quantity;
  final String moveType;
  final DateTime createdAt;

  TransactionData({
    required this.id,
    required this.productName,
    required this.productSku,
    required this.productBrand,
    required this.productPrice,
    required this.picName,
    required this.quantity,
    required this.moveType,
    required this.createdAt,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return TransactionData(
      id: parseInt(json['id']),
      productName: json['product_name'] ?? '',
      productSku: json['product_sku'] ?? '',
      productBrand: json['product_brand'] ?? '',
      productPrice: parseInt(json['product_price']),
      picName: json['pic_name'] ?? '',
      quantity: parseInt(json['quantity']),
      moveType: json['move_type'] ?? '',
      createdAt:
      DateTime.tryParse(json['created_at'] ?? '') ??
          DateTime.now(),
    );
  }
}
