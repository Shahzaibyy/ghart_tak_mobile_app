import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Light and dark themes. One typeface, weight does the rest.
abstract final class AppTheme {
  static ThemeData get light => _theme(Brightness.light);

  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final background = dark ? AppColors.darkBackground : AppColors.background;
    final surface = dark ? AppColors.darkSurface : AppColors.surface;
    final text = dark ? AppColors.darkText : AppColors.text;
    final muted = dark ? AppColors.darkTextMuted : AppColors.textMuted;
    final line = dark ? AppColors.darkLine : AppColors.line;
    final primary = dark ? AppColors.darkPrimary : AppColors.primary;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: dark ? AppColors.darkBackground : AppColors.surface,
      secondary: line,
      onSecondary: text,
      error: AppColors.error,
      onError: AppColors.surface,
      surface: surface,
      onSurface: text,
    );
    final radius = BorderRadius.circular(AppRadius.control);
    final outline = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: line),
    );
    return ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: _text(text, muted),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: _face(24, 32, FontWeight.w600, text),
      ),
      dividerColor: line,
      splashColor: primary.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: _face(16, 24, FontWeight.w400, muted),
        labelStyle: _face(14, 20, FontWeight.w500, muted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: outline,
        enabledBorder: outline,
        focusedBorder: outline.copyWith(
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        height: 68,
        indicatorColor: primary.withValues(alpha: 0.14),
        labelTextStyle: WidgetStatePropertyAll(
          _face(13, 18, FontWeight.w500, text),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? primary : muted);
        }),
      ),
    );
  }

  static TextTheme _text(Color text, Color muted) {
    return TextTheme(
      displaySmall: _face(32, 40, FontWeight.w600, text),
      headlineMedium: _face(24, 32, FontWeight.w600, text),
      titleLarge: _face(20, 28, FontWeight.w600, text),
      bodyLarge: _face(16, 24, FontWeight.w400, text),
      labelLarge: _face(14, 20, FontWeight.w500, text),
      bodySmall: _face(13, 18, FontWeight.w400, muted),
    );
  }

  static TextStyle _face(
    double size,
    double lineHeight,
    FontWeight weight,
    Color color,
  ) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      color: color,
      letterSpacing: -0.2,
    );
  }
}
