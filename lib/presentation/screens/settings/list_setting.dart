import 'package:flutter/material.dart';
import '../../shared/core/color_manager.dart';
import '../../shared/wrappers/mobile_wrapper.dart';
import '../auth/login.dart';
import '../../../data/services/token_service.dart';
import 'editProfileUser.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> _logout() async {
    await TokenService.clear();
    _goToLogin();
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

  void _goToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MobileWrapper(child: EditProfilePage()), // placeholder
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.bgBottom,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 24),
              _sectionCard(
                children: [
                  _settingItem(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: _goToEditProfile,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _sectionCard(
                children: [
                  _settingItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    color: ColorManager.error,
                    onTap: _logout,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: ColorManager.textDark,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Kelola akun dan preferensi anda',
          style: TextStyle(
            fontSize: 14,
            color: ColorManager.textDark,
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorManager.shadowLightBlue,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _settingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final itemColor = color ?? ColorManager.textDark;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: itemColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: itemColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: itemColor,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: itemColor),
          ],
        ),
      ),
    );
  }
}

