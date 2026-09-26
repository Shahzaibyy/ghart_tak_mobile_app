import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// App-wide Material theme.
abstract final class AppTheme {
  /// Light theme for customer and rider flows.
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      primary: AppColors.seed,
      secondary: AppColors.accent,
    );
    return ThemeData(colorScheme: scheme);
  }
}
