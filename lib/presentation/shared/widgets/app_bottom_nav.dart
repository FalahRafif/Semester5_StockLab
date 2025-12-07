import 'package:flutter/material.dart';
import '../core/color_manager.dart';

class AppBottomNav extends StatelessWidget {
  final int index;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> items;

  const AppBottomNav({
    super.key,
    required this.index,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorManager.shadowLightBlue,
            blurRadius: 18,
            spreadRadius: 2,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: onTap,
          items: items,
          backgroundColor: ColorManager.cardBackground,
          selectedItemColor: ColorManager.primary,
          unselectedItemColor: ColorManager.textDark.withOpacity(0.6),
          type: BottomNavigationBarType.fixed,
          elevation: 0,

          // modern style
          selectedIconTheme: const IconThemeData(size: 28),
          unselectedIconTheme: const IconThemeData(size: 22),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
