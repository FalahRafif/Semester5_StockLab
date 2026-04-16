import 'package:flutter/material.dart';
import '../../shared/wrappers/mobile_wrapper.dart';
import '../../shared/core/color_manager.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MobileWrapper(child: OnboardingScreen())),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.cardBackground,
      body: Stack(
        children: [
          // Soft upper gradient background
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    ColorManager.bgTop,
                    ColorManager.ornamentBlue1.withOpacity(0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Soft lower ornament
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    ColorManager.bgBottom,
                    ColorManager.ornamentBlue2.withOpacity(0.35),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inventory_2_rounded,
                  size: 80,
                  color: ColorManager.primary,
                ),
                const SizedBox(height: 20),

                Text(
                  "StockLab",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.textDark,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Smart Inventory Companion",
                  style: TextStyle(
                    fontSize: 14,
                    color: ColorManager.textDark.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
