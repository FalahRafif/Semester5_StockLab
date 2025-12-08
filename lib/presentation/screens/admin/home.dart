import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../shared/core/color_manager.dart';
import '../../shared/widgets/home_tabbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.bgBottom,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title("Statistik Utama"),
            const SizedBox(height: 12),
            _statisticCards(),

            const SizedBox(height: 28),
            _title("Aktivitas Stok 7 Hari Terakhir"),
            const SizedBox(height: 12),
            _modernStockChart(),

            const SizedBox(height: 28),
            _title("Data Produk"),
            const SizedBox(height: 12),

            _tabHeader(),
            const SizedBox(height: 14),
            _tabContent(),
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
        _statItem("Total Produk", "120", Icons.inventory_2_rounded),
        _statItem("Total Stock", "3.421", Icons.store_mall_directory_rounded),
        _statItem("Low Stock", "8", Icons.warning_amber_rounded),
        _statItem("No Stock", "4", Icons.block),
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
    final now = DateTime.now();
    final labels = List.generate(
      7,
          (i) {
        final d = now.subtract(Duration(days: 6 - i));
        return "${d.day} ${_monthShort(d.month)}";
      },
    );

    return Container(
      padding: const EdgeInsets.all(18),
      height: 280,
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
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 20,
          lineTouchData: LineTouchData(enabled: true),

          // GRID — lembut & modern
          gridData: FlGridData(
            drawVerticalLine: true,
            verticalInterval: 1,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (_) => FlLine(
              color: ColorManager.shadowLightBlue2,
              strokeWidth: 0.7,
            ),
            getDrawingVerticalLine: (_) => FlLine(
              color: ColorManager.shadowLightBlue2,
              strokeWidth: 0.7,
            ),
          ),

          // AXIS — kiri & bawah saja
          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

            // bawah = tanggal + bulan
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 28,
                getTitlesWidget: (v, _) {
                  int idx = v.toInt();
                  if (idx < 0 || idx > 6) return const SizedBox();
                  return Text(
                    labels[idx],
                    style: const TextStyle(
                        fontSize: 11, color: ColorManager.textDark),
                  );
                },
              ),
            ),

            // kiri = jumlah stok
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: 5,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                      fontSize: 11, color: ColorManager.textDark),
                ),
              ),
            ),
          ),

          borderData: FlBorderData(show: false),

          // Data garis
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 12),
                FlSpot(1, 9),
                FlSpot(2, 17),
                FlSpot(3, 11),
                FlSpot(4, 16),
                FlSpot(5, 10),
                FlSpot(6, 14),
              ],
              isCurved: true,
              color: ColorManager.primary,
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              spots: const [
                FlSpot(0, 7),
                FlSpot(1, 5),
                FlSpot(2, 8),
                FlSpot(3, 6),
                FlSpot(4, 12),
                FlSpot(5, 4),
                FlSpot(6, 9),
              ],
              isCurved: true,
              color: ColorManager.primarySoft,
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
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
}
