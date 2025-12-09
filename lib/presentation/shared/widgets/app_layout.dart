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
import '../../screens/admin/user/list_user.dart';
import '../../screens/admin/product/list_product.dart';

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
  List<Widget> get pages {
    return _buildPages(role);
  }

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
        const admin.HomePage(),      // 0 Dashboard
        const ListUserPage(),        // 1 User
        const ListProductPage(),     // 2 Stok
        const PlaceholderPage(title: "Laporan"),   // 3 Laporan
        const ListProductPage(),     // 4 Produk
        const PlaceholderPage(title: "Kategori"),  // 5 Kategori
        const PlaceholderPage(title: "Satuan"),    // 6 Satuan
        const PlaceholderPage(title: "Setting"),   // 7 Setting
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
              // HAPUS Navigator.pop(context) di sini — AppBottomNavMore sudah mem-popol sendiri.
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

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

