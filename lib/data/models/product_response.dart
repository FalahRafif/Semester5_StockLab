class ProductData {
  final int id;
  final String name;
  final String category;
  final String sku;
  final String brand;
  final int price;
  final String? image;

  ProductData({
    required this.id,
    required this.name,
    required this.category,
    required this.sku,
    required this.brand,
    required this.price,
    this.image,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      sku: json['sku'] ?? '',
      brand: json['brand'] ?? '',
      price: json['price'] ?? 0,
      image: json['image'],
    );
  }
}

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
    return ProductResponse(
      success: json['status'] == 'success',
      message: json['message'] ?? '',
      products: json['data'] != null
          ? List<ProductData>.from(
        json['data'].map((x) => ProductData.fromJson(x)),
      )
          : [],
    );
  }
}
