import 'package:flutter/material.dart';
import '../../../application/login_manager.dart';
import '../../shared/wrappers/mobile_wrapper.dart';
import '../admin/home.dart' as admin;
import '../staff/home.dart' as staff;
import '../../shared/core/color_manager.dart';
import 'register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final loginManager = LoginManager();

  bool isLoading = false;

  Future<void> handleLogin() async {
    setState(() => isLoading = true);

    final result = await loginManager.login(
      email: emailC.text.trim(),
      password: passC.text.trim(),
    );

    setState(() => isLoading = false);

    if (!mounted) return;

    if (result.success) {
      // Role Admin
      if (result.roleId == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MobileWrapper(child: admin.HomePage()),
          ),
        );
      }
      // Role Staff
      else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MobileWrapper(child: staff.HomePage()),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: ColorManager.error,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorManager.bgTop, ColorManager.bgBottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: size.height),
          child: Stack(
            children: [
              // ORNAMENT 1
              Positioned(
                top: -50,
                left: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: ColorManager.ornamentBlue1.withOpacity(0.35),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ColorManager.ornamentBlue1.withOpacity(0.25),
                        blurRadius: 40,
                        spreadRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                ),
              ),

              // ORNAMENT 2
              Positioned(
                bottom: -60,
                right: -30,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: ColorManager.ornamentBlue2.withOpacity(0.30),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ColorManager.ornamentBlue2.withOpacity(0.22),
                        blurRadius: 30,
                        spreadRadius: 6,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                ),
              ),

              Column(
                children: [
                  // HEADER CLIPPED GRADIENT
                  ClipPath(
                    clipper: _HeaderClipper(),
                    child: Container(
                      width: size.width,
                      padding: const EdgeInsets.only(top: 120, bottom: 50),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [ColorManager.primary, ColorManager.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.inventory_2_rounded, size: 85, color: ColorManager.textWhite),
                          SizedBox(height: 14),
                          Text(
                            "Stock Management",
                            style: TextStyle(
                              color: ColorManager.textWhite,
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Manage your warehouse easily",
                            style: TextStyle(
                              color: ColorManager.textWhiteMuted,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
                      decoration: BoxDecoration(
                        color: ColorManager.cardBackground.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 25,
                            offset: const Offset(0, 12),
                          ),
                        ],
                        border: Border.all(color: ColorManager.cardBorderSoft.withOpacity(0.6)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: ColorManager.textDark,
                            ),
                          ),

                          const SizedBox(height: 25),

                          // EMAIL
                          _StyledInput(
                            controller: emailC,
                            label: "Email",
                            icon: Icons.email_rounded,
                          ),

                          const SizedBox(height: 15),

                          // PASSWORD
                          _StyledInput(
                            controller: passC,
                            label: "Password",
                            icon: Icons.lock_rounded,
                            obscure: true,
                          ),

                          const SizedBox(height: 30),

                          // BUTTON LOGIN
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: isLoading ? null : handleLogin,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    colors: [ColorManager.primary, ColorManager.primaryLight],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: ColorManager.shadowPrimary,
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  isLoading ? "Loading..." : "Login",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: ColorManager.textWhite,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const MobileWrapper(child: RegisterScreen())),
                              );
                            },
                            child: const Text(
                              "Belum punya akun? Daftar",
                              style: TextStyle(
                                color: ColorManager.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// INPUT FIELD
class _StyledInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;

  const _StyledInput({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: ColorManager.textDark),
        prefixIcon: Icon(icon, color: ColorManager.primary),
        filled: true,
        fillColor: ColorManager.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// HEADER CLIPPER
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(size.width * 0.5, size.height, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
