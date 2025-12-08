import 'package:flutter/material.dart';
import '../../../data/services/token_service.dart';
import 'app_bottom_nav.dart';
import 'menu_builder.dart';
import 'app_topbar.dart';
import '../wrappers/mobile_wrapper.dart';
import 'app_bottom_nav_more.dart';

import '../../screens/admin/home.dart' as admin;
import '../../screens/staff/home.dart' as staff;
import '../../screens/auth/login.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int index = 0;
  String role = '';

  List<BottomNavigationBarItem> menus = [];
  List<BottomNavigationBarItem> moreMenus = [];
  List<Widget> pages = [];

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    final token = await TokenService.getToken();
    if (token == null) {
      _goToLogin();
      return;
    }

    final r = await TokenService.getRole();
    role = r ?? 'guest';

    final allMenus = MenuBuilder.build(role);

    // Pisahkan bottom nav + more menu
    menus = [
      ...allMenus.take(MenuBuilder.maxBottomNav),
      const BottomNavigationBarItem(
        icon: Icon(Icons.more_horiz_rounded),
        label: "More",
      ),
    ];

    moreMenus = allMenus.skip(MenuBuilder.maxBottomNav).toList();

    pages = _buildPages(role);

    setState(() {});
  }

  void _goToLogin() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MobileWrapper(child: LoginScreen()),
      ),
    );
  }

  List<Widget> _buildPages(String role) {
    if (role == "admin") {
      return [
        const admin.HomePage(), // Dashboard
        const staff.HomePage(), // User
        const admin.HomePage(), // Produk
        const admin.HomePage(), // Kategori
        const admin.HomePage(), // Satuan
        const admin.HomePage(), // Stok
        const admin.HomePage(), // Laporan
        const admin.HomePage(), // Setting
      ];
    }

    return [const LoginScreen()];
  }

  void _openMoreMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: .85,
          child: AppBottomNavMore(
            menus: moreMenus,
            startIndex: MenuBuilder.maxBottomNav,
            onSelect: (realIndex) {
              Navigator.pop(context);
              setState(() => index = realIndex);
            },
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    if (menus.isEmpty || pages.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppTopBar(
        title: "${role.toUpperCase()} Dashboard",
        onSettingsTap: () {},
        onLogoutTap: () async {
          await TokenService.clear();
          _goToLogin();
        },
        onProfileTap: () {},
      ),
      body: pages[index],
      bottomNavigationBar: AppBottomNav(
        index: index < menus.length ? index : 0,
        items: menus,
        onTap: (i) {
          if (i == menus.length - 1) {
            _openMoreMenu();
          } else {
            setState(() => index = i);
          }
        },
      ),
    );
  }
}
