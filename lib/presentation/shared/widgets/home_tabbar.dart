import 'package:flutter/material.dart';
import '../core/color_manager.dart';

class ModernTabBar extends StatelessWidget {
  final TabController controller;
  const ModernTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      splashBorderRadius: BorderRadius.circular(14),
      dividerColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.tab,

      // ─────────── INDICATOR — Segmented Modern ───────────
      indicator: BoxDecoration(
        color: ColorManager.primary,          // Warna aktif
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: ColorManager.shadowLightBlue2,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      labelColor: Colors.white,
      unselectedLabelColor: ColorManager.textDark,

      // Buat tab lebih lebar (biar tidak mepet-mepet)
      labelPadding: const EdgeInsets.symmetric(vertical: 8),
      tabs: const [
        Tab(child: Text("Top Outgoing", style: TextStyle(fontSize: 14))),
        Tab(child: Text("Low Stock", style: TextStyle(fontSize: 14))),
      ],
    );
  }
}

