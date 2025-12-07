import 'package:flutter/material.dart';
import '../../../data/services/token_service.dart';
import 'app_bottom_nav.dart';
import 'menu_builder.dart';
import 'app_topbar.dart';

// Import halaman sesuai role
import '../../screens/admin/home.dart';
// import '../../screens/admin/user.dart';
// import '../../screens/admin/settings.dart';
//
// import '../../screens/staff/home.dart';
// import '../../screens/staff/tasks.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int index = 0;
  String role = '';
  List<BottomNavigationBarItem> menus = [];
  List<Widget> pages = [];

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    final token = await TokenService.getToken();

    if (token == null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final r = await TokenService.getRole();

    setState(() {
      role = r ?? 'guest';
      menus = MenuBuilder.build(role);
      pages = _buildPages(role);
    });
  }

  List<Widget> _buildPages(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return [
          const HomePage(),
          // const AdminUserPage(),
          // const AdminSettingsPage(),
        ];

      case 'staff':
        return [
          const HomePage()
          // const StaffHomePage(),
          // const StaffTaskPage(),
        ];

      default:
        return [
          const HomePage()
          // const StaffHomePage(), // atau user-home
        ];
    }
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
        title: role.toUpperCase() + " Dashboard",
        onSettingsTap: () {
          // Navigate ke settings
        },
        onLogoutTap: () async {
          await TokenService.clear();
          if (mounted) Navigator.pushReplacementNamed(context, '/login');
        },
        onProfileTap: () {
          // Navigate ke profile page
        },
      ),
      body: pages[index],
      bottomNavigationBar: AppBottomNav(
        index: index,
        items: menus,
        onTap: (i) => setState(() => index = i),
      ),
    );

  }
}
