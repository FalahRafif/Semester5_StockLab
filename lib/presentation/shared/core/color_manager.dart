import 'package:flutter/material.dart';

class ColorManager {
  // ─────────────────────────────────────────────
  //  MAIN BRAND COLORS
  // ─────────────────────────────────────────────
  static const Color primary = Color(0xFF4D9DE0);
  static const Color primaryLight = Color(0xFF6FB6FF);
  static const Color primarySoft = Color(0xFF89C2FF);

  // ─────────────────────────────────────────────
  //  BACKGROUND COLORS (gradient + ornaments)
  // ─────────────────────────────────────────────
  static const Color bgTop = Color(0xFFE8F3FF);
  static const Color bgBottom = Color(0xFFF5FAFF);

  static const Color ornamentBlue1 = Color(0xFFB7DBFF);
  static const Color ornamentBlue2 = Color(0xFF80C8FF);

  // ─────────────────────────────────────────────
  //  CARD & INPUT
  // ─────────────────────────────────────────────
  static const Color cardBackground = Colors.white;
  static const Color cardBorderSoft = Color(0xFFFFFFFF);

  static const Color inputFill = Color(0xFFF0F5FF);
  static const Color border = Color(0xFFE3E8F1); // border modern clean
  static const Color borderSoft = Color(0xFFF2F4F8); // untuk subtle cases

  // ─────────────────────────────────────────────
  //  TEXT COLORS
  // ─────────────────────────────────────────────
  static const Color textDark = Color(0xFF4D5C73);
  static const Color textPrimary = Color(0xFF4D9DE0);
  static const Color textWhite = Colors.white;
  static const Color textWhiteMuted = Colors.white70;

  // ─────────────────────────────────────────────
  //  FEEDBACK
  // ─────────────────────────────────────────────
  static const Color error = Colors.redAccent;

  // SHADOWS
  static Color shadowPrimary = const Color(0xFF89C2FF).withOpacity(0.4);
  static Color shadowLightBlue = const Color(0xFFB7DBFF).withOpacity(0.25);
  static Color shadowLightBlue2 = const Color(0xFF80C8FF).withOpacity(0.22);
}
