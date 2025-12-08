import 'package:flutter/material.dart';
import '../../shared/core/color_manager.dart';
import '../../screens/auth/login.dart';
import '../../screens/auth/register.dart';
import '../../shared/wrappers/mobile_wrapper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int index = 0;

  final List<_Page> pages = [
    _Page(
      icon: Icons.inventory_2_rounded,
      title: "Kelola Stok dengan Mudah",
      desc: "Pantau stok barang secara real-time dalam tampilan yang rapi, intuitif, dan efisien.",
    ),
    _Page(
      icon: Icons.analytics_rounded,
      title: "Analitik Cerdas",
      desc: "Dapatkan insight penting dari grafik, tren, dan laporan otomatis.",
    ),
    _Page(
      icon: Icons.lock_person_rounded,
      title: "Aman & Terproteksi",
      desc: "Sistem keamanan yang menjaga kerahasiaan dan integritas data Anda.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.cardBackground,
      body: Stack(
        children: [
          // ─────────────────────────────────────────────
          // Soft gradient ornaments (atas kiri + bawah kanan)
          // ─────────────────────────────────────────────
          Positioned(
            top: -130,
            left: -90,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    ColorManager.bgTop,
                    ColorManager.ornamentBlue1.withOpacity(0.45),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -160,
            right: -120,
            child: Container(
              width: 330,
              height: 330,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    ColorManager.bgBottom,
                    ColorManager.ornamentBlue2.withOpacity(0.40),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // ─────────────────────────────────────────────
          // MAIN CONTENT
          // ─────────────────────────────────────────────
          Column(
            children: [
              const SizedBox(height: 70),

              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (i) => setState(() => index = i),
                  itemBuilder: (context, i) {
                    final p = pages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Elevated soft card
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 38),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                  ColorManager.shadowLightBlue.withOpacity(0.35),
                                  blurRadius: 26,
                                  spreadRadius: 3,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  p.icon,
                                  size: 95,
                                  color: ColorManager.primary,
                                ),

                                const SizedBox(height: 30),

                                Text(
                                  p.title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                    color: ColorManager.textDark,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                Text(
                                  p.desc,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.4,
                                    color: ColorManager.textDark.withOpacity(0.67),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ─────────────────────────────────────────────
              // SLIDE INDICATOR
              // ─────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                      (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: index == i ? 24 : 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color:
                      index == i ? ColorManager.primary : ColorManager.border,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ─────────────────────────────────────────────
              // BUTTONS
              // ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: [
                    if (index != pages.length - 1)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorManager.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            shadowColor:
                            ColorManager.shadowLightBlue2.withOpacity(0.3),
                          ),
                          child: const Text(
                            "Continue",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                    if (index == pages.length - 1) ...[
                      // SIGN IN
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const MobileWrapper(child: LoginScreen()),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorManager.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            shadowColor: ColorManager.shadowPrimary,
                          ),
                          child: const Text(
                            "Sign In",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // SIGN UP
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const MobileWrapper(child: RegisterScreen()),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: ColorManager.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              color: ColorManager.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }
}

class _Page {
  final IconData icon;
  final String title;
  final String desc;

  _Page({
    required this.icon,
    required this.title,
    required this.desc,
  });
}
