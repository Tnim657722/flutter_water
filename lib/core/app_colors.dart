import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0A2463);
  static const Color primaryLight = Color(0xFF1B4AB8);
  static const Color accent = Color(0xFF00B4D8);
  static const Color accentLight = Color(0xFF90E0EF);
  static const Color success = Color(0xFF06D6A0);
  static const Color warning = Color(0xFFFFB703);
  static const Color danger = Color(0xFFEF233C);
  static const Color background = Color(0xFFF0F4FF);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color navyDark = Color(0xFF060F2E);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A2463), Color(0xFF1B4AB8)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00B4D8), Color(0xFF0096C7)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF060F2E), Color(0xFF0A2463), Color(0xFF0D3B8C)],
  );
}
