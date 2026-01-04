class ProductResponse {
  final bool success;
  final String message;
  final List<ProductData> products;

  ProductResponse({
    required this.success,
    required this.message,
    required this.products,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    final List list = json['data'] ?? [];

    return ProductResponse(
      success: json['status'] == 'success',
      message: json['message'] ?? '',
      products: list.map((e) => ProductData.fromJson(e)).toList(),
    );
  }
}

class ProductData {
  final int id;
  final String name;
  final String category;
  final String sku;
  final String brand;
  final String? image;

  ProductData({
    required this.id,
    required this.name,
    required this.category,
    required this.sku,
    required this.brand,
    this.image,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return ProductData(
      id: parseInt(json['id']),
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      sku: json['sku'] ?? '',
      brand: json['brand'] ?? '',
      image: json['image'],
    );
  }
}
