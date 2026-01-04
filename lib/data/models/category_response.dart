class CategoryResponse {
  final bool success;
  final String message;
  final List<CategoryData> categories;

  CategoryResponse({
    required this.success,
    required this.message,
    required this.categories,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    final List data = json['data'] ?? [];

    return CategoryResponse(
      success: json['status'] == 'success',
      message: json['message'] ?? '',
      categories: data.map((e) => CategoryData.fromJson(e)).toList(),
    );
  }
}

class CategoryData {
  final int id;
  final String name;

  CategoryData({
    required this.id,
    required this.name,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return CategoryData(
      id: parseInt(json['id']),
      name: json['name'] ?? '',
    );
  }
}
