import 'package:flutter/material.dart';

/// Bhook Lagi color tokens. Terracotta is the only brand color.
abstract final class AppColors {
  static const background = Color(0xFFFAF8F5);
  static const surface = Color(0xFFFFFFFF);
  static const primary = Color(0xFFD96B41);
  static const primaryPressed = Color(0xFFC25A32);
  static const text = Color(0xFF1C1917);
  static const textMuted = Color(0xFF78716C);
  static const line = Color(0xFFEDE7E0);
  static const success = Color(0xFF2F9E5B);
  static const error = Color(0xFFB8452B);
  static const gold = Color(0xFFC9A063);
  static const peach = Color(0xFFF6D2C4);
  static const tint = Color(0xFFF6E7DF);

  static const darkBackground = Color(0xFF17140F);
  static const darkSurface = Color(0xFF211D17);
  static const darkPrimary = Color(0xFFE37A52);
  static const darkText = Color(0xFFF5F1EB);
  static const darkTextMuted = Color(0xFFA39A8E);
  static const darkLine = Color(0xFF332C22);
  static const darkPeach = Color(0xFF3A2A22);
}

/// Corner radii from the design system.
abstract final class AppRadius {
  static const card = 16.0;
  static const control = 12.0;
  static const chip = 8.0;
}

/// The one shadow used for floating elements.
abstract final class AppShadow {
  static const floating = BoxShadow(
    color: Color(0x141C1917),
    blurRadius: 24,
    offset: Offset(0, 8),
  );
}
