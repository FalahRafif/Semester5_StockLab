import 'package:flutter/material.dart';
import '../../shared/core/color_manager.dart';

class HomeStaffPage extends StatelessWidget {
  const HomeStaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.bgBottom,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _welcomeSection(),
              const SizedBox(height: 28),
              _sopSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // WELCOME
  // ─────────────────────────────────────────────
  Widget _welcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primary,
            ColorManager.primary.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Selamat Datang 👋",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Semoga harimu menyenangkan dan produktif. "
                "Pastikan setiap pekerjaan dilakukan sesuai SOP yang berlaku.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SOP SECTION
  // ─────────────────────────────────────────────
  Widget _sopSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Standar Operasional Prosedur",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColorManager.textDark,
          ),
        ),
        const SizedBox(height: 16),

        _sopItem(
          icon: Icons.assignment_outlined,
          title: "Pelaksanaan Tugas",
          desc:
          "Kerjakan tugas sesuai jobdesk masing-masing dan ikuti instruksi dari atasan atau sistem.",
        ),
        _sopItem(
          icon: Icons.security_outlined,
          title: "Keamanan Data",
          desc:
          "Jaga kerahasiaan data perusahaan dan tidak membagikan akses atau informasi kepada pihak luar.",
        ),
        _sopItem(
          icon: Icons.support_agent,
          title: "Pelayanan & Koordinasi",
          desc:
          "Berikan pelayanan terbaik dan lakukan koordinasi yang baik dengan tim maupun atasan.",
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // SOP ITEM CARD
  // ─────────────────────────────────────────────
  Widget _sopItem({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorManager.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorManager.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: ColorManager.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ColorManager.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13,
                    color: ColorManager.textDark.withOpacity(0.7),
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
