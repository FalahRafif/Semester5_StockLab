import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../shared/core/color_manager.dart';
import '../../shared/widgets/home_tabbar.dart';


import '../../../application/dashboard_manager.dart';
import '../../../data/models/dashboard_response.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController tabController;
  final DashboardManager _dashboardManager = DashboardManager();

  bool _loading = true;
  String _error = '';
  DashboardData? _dashboard;

  double _roundUp(double value) {
    if (value <= 5) return 5;
    if (value <= 10) return 10;
    if (value <= 20) return 20;
    if (value <= 50) return 50;
    return (value / 10).ceil() * 10;
  }

  String _formatNumber(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString(); // 10.0 → 10
    }
    return value.toStringAsFixed(1); // kalau suatu saat decimal
  }

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    _fetchDashboard();
    super.initState();
  }

  Future<void> _fetchDashboard() async {
    final res = await _dashboardManager.getDashboard();

    if (!mounted) return;

    setState(() {
      _loading = false;

      if (res.success && res.data != null) {
        _dashboard = res.data;
      } else {
        _error = res.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.bgBottom,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(
        child: Text(
          _error,
          style: const TextStyle(color: Colors.red),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title("Statistik Utama"),
            const SizedBox(height: 12),
            _statisticCards(),

            const SizedBox(height: 28),
            _title("Banyak Aktivitas Stok Dalam 7 Hari Terakhir"),
            const SizedBox(height: 12),
            _modernStockChart(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TITLE SECTION
  // ─────────────────────────────────────────────────────────────
  Widget _title(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: ColorManager.textDark,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STAT CARDS — MODERN DESIGN
  // ─────────────────────────────────────────────────────────────
  Widget _statisticCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _statItem(
          "Total Produk",
          _dashboard?.productTotal.toString() ?? '0',
          Icons.inventory_2_rounded,
        ),
        _statItem(
          "Total Stock",
          _dashboard?.stockTotal.toString() ?? '0',
          Icons.store_mall_directory_rounded,
        ),
        _statItem(
          "Low Stock",
          _dashboard?.lowStock.toString() ?? '0',
          Icons.warning_amber_rounded,
        ),
        _statItem(
          "No Stock",
          _dashboard?.noStock.toString() ?? '0',
          Icons.block,
        ),
      ],
    );
  }


  Widget _statItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ColorManager.cardBackground,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: ColorManager.shadowLightBlue,
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorManager.primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 26, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: ColorManager.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                    color: ColorManager.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // MODERN STOCK CHART (PERBAIKAN TOTAL)
  // ─────────────────────────────────────────────────────────────
  Widget _modernStockChart() {
    final inData = _dashboard?.chartActivityIn ?? [];
    final outData = _dashboard?.chartActivityOut ?? [];

    if (inData.isEmpty && outData.isEmpty) {
      return const Center(child: Text("Tidak ada data grafik"));
    }

    final labels = inData.map((e) {
      return "${e.date.day} ${_monthShort(e.date.month)}";
    }).toList();

    final inSpots = List.generate(
      inData.length,
          (i) => FlSpot(i.toDouble(), inData[i].total.toDouble()),
    );

    final outSpots = List.generate(
      outData.length,
          (i) => FlSpot(i.toDouble(), outData[i].total.toDouble()),
    );

    final maxRaw = [
      ...inData.map((e) => e.total),
      ...outData.map((e) => e.total),
    ].fold<int>(0, (a, b) => a > b ? a : b);

    int step;
    if (maxRaw <= 5) {
      step = 1;
    } else if (maxRaw <= 10) {
      step = 2;
    } else if (maxRaw <= 20) {
      step = 5;
    } else if (maxRaw <= 50) {
      step = 10;
    } else {
      step = 20;
    }

    final maxY = ((maxRaw / step).ceil() * step).toDouble();
    final interval = step.toDouble();


    return Container(
      padding: const EdgeInsets.all(18),
      height: 300,
      decoration: BoxDecoration(
        color: ColorManager.cardBackground,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: ColorManager.shadowLightBlue,
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(ColorManager.primary, "Stock In"),
              const SizedBox(width: 16),
              _legendDot(Colors.redAccent, "Stock Out"),
            ],
          ),
          const SizedBox(height: 12),

          Expanded(
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (labels.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,

                lineTouchData: LineTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 12,
                    tooltipPadding: const EdgeInsets.all(10),
                    tooltipMargin: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final isIn = spot.bar.color == ColorManager.primary;
                        return LineTooltipItem(
                          '${isIn ? "Stock In" : "Stock Out"}\n',
                          const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          children: [
                            TextSpan(
                              text: _formatNumber(spot.y),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  horizontalInterval: interval,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: ColorManager.shadowLightBlue2,
                    strokeWidth: 0.7,
                  ),
                ),

                titlesData: FlTitlesData(
                  topTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 28,
                      getTitlesWidget: (value, _) {
                        final i = value.toInt();
                        if (value != i.toDouble()) {
                          return const SizedBox();
                        }
                        if (i < 0 || i >= labels.length) {
                          return const SizedBox();
                        }
                        return Text(
                          labels[i],
                          style: const TextStyle(fontSize: 11),
                        );
                      },
                    ),
                  ),

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: interval,
                      reservedSize: 36,
                      getTitlesWidget: (value, _) {
                        if (value % interval != 0) {
                          return const SizedBox();
                        }
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 11),
                        );
                      },
                    ),
                  ),
                ),

                borderData: FlBorderData(show: false),

                lineBarsData: [
                  LineChartBarData(
                    spots: inSpots,
                    isCurved: true,
                    color: ColorManager.primary,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: outSpots,
                    isCurved: true,
                    color: Colors.redAccent,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }






  String _monthShort(int m) {
    const list = [
      "", "Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
      "Jul", "Agu", "Sep", "Okt", "Nov", "Des"
    ];
    return list[m];
  }

  // ─────────────────────────────────────────────────────────────
  // TAB HEADER — Modern soft UI
  // ─────────────────────────────────────────────────────────────
  Widget _tabHeader() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: ColorManager.cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: ColorManager.shadowLightBlue,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ModernTabBar(controller: tabController),
    );
  }


  // ─────────────────────────────────────────────────────────────
  // TAB CONTENT — clean table
  // ─────────────────────────────────────────────────────────────
  Widget _tabContent() {
    return Container(
      height: 330,
      decoration: BoxDecoration(
        color: ColorManager.cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: ColorManager.shadowLightBlue,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TabBarView(
        controller: tabController,
        children: [
          _modernTable([
            ["Beras Premium 10kg", "241", "Karung"],
            ["Minyak Goreng 1L", "188", "Botol"],
            ["Gula Putih 1kg", "162", "Pack"],
            ["Tepung 1kg", "99", "Pack"],
            ["Susu Bubuk", "77", "Box"],
          ]),
          _modernTable([
            ["Beras Medium 5kg", "4", "Karung"],
            ["Mie Instan", "6", "Bks"],
            ["Kecap Manis", "2", "Botol"],
            ["Garam", "5", "Pack"],
            ["Sirup", "1", "Botol"],
          ]),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // MODERN TABLE COMPONENT
  // ─────────────────────────────────────────────────────────────
  Widget _modernTable(List<List<String>> rows) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: rows.length,
      separatorBuilder: (_, __) => Divider(
        color: ColorManager.shadowLightBlue2,
        height: 1,
      ),
      itemBuilder: (_, i) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Text(
                "${i + 1}.",
                style: const TextStyle(
                  color: ColorManager.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  rows[i][0],
                  style: const TextStyle(
                    fontSize: 14,
                    color: ColorManager.textDark,
                  ),
                ),
              ),
              Text(
                "${rows[i][1]} ${rows[i][2]}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ColorManager.primary,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _legendDot(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

}
