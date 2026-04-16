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
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: ColorManager.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorManager.shadowLightBlue.withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 3,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: onTap,
          items: items,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,

          // Modern icon style
          selectedIconTheme: const IconThemeData(size: 26),
          unselectedIconTheme: const IconThemeData(size: 22),

          selectedItemColor: ColorManager.primary,
          unselectedItemColor: ColorManager.textDark.withOpacity(0.55),

          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
          ),

          // New modern indicator
          landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        ),
      ),
    );
  }
}
