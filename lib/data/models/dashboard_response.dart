class DashboardResponse {
  final bool success;
  final String message;
  final DashboardData? data;

  DashboardResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      success: json['status'] == 'success',
      message: json['message'] ?? '',
      data: json['data'] != null
          ? DashboardData.fromJson(json['data'])
          : null,
    );
  }
}

class DashboardData {
  final int productTotal;
  final int stockTotal;
  final int lowStock;
  final int noStock;
  final List<ChartActivityData> chartActivityData;

  DashboardData({
    required this.productTotal,
    required this.stockTotal,
    required this.lowStock,
    required this.noStock,
    required this.chartActivityData,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final List list = json['chart_activity_data'] ?? [];

    return DashboardData(
      productTotal: parseInt(json['product_total']),
      stockTotal: parseInt(json['stock_total']),
      lowStock: parseInt(json['low_stock']),
      noStock: parseInt(json['no_stock']),
      chartActivityData: list
          .map((e) => ChartActivityData.fromJson(e))
          .toList(),
    );
  }
}

class ChartActivityData {
  final DateTime date;
  final int total;

  ChartActivityData({
    required this.date,
    required this.total,
  });

  factory ChartActivityData.fromJson(Map<String, dynamic> json) {
    return ChartActivityData(
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      total: json['total'] ?? 0,
    );
  }
}
