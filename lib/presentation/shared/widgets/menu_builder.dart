import 'package:flutter/material.dart';

class MenuBuilder {
  static const int maxBottomNav = 4; // 4 menu tampil di bottom nav, lainnya masuk More

  static List<BottomNavigationBarItem> build(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.space_dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'User',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_rounded),
            label: 'Stok',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_rounded),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_rounded),
            label: 'Kategori',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.straighten_rounded),
            label: 'Satuan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Setting',
          ),
        ];

      default:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
        ];
    }
  }
}
