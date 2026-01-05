import 'package:flutter/material.dart';
import '../core/color_manager.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onProfileTap;

  const AppTopBar({
    super.key,
    required this.title,
    this.onSettingsTap,
    this.onLogoutTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ColorManager.primary, ColorManager.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // TITLE
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: ColorManager.textWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),

              // ICONS
              Row(
                children: [
                  // Logout
                  _TopBarIcon(
                    icon: Icons.logout,
                    onTap: onLogoutTap,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(75);
}

// --- Small reusable topbar icon widget
class _TopBarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _TopBarIcon({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        splashColor: ColorManager.textWhite.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: ColorManager.textWhite,
            size: 24,
          ),
        ),
      ),
    );
  }
}
