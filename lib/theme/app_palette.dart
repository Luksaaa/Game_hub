import 'package:flutter/material.dart';

class AppPalette {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.primary,
    required this.primarySoft,
    required this.accent,
    required this.text,
    required this.textMuted,
    required this.border,
    required this.dartboardDark,
    required this.dartboardLight,
  });

  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color primary;
  final Color primarySoft;
  final Color accent;
  final Color text;
  final Color textMuted;
  final Color border;
  final Color dartboardDark;
  final Color dartboardLight;

  static AppPalette of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return const AppPalette(
        background: Color(0xFF121212),
        surface: Color(0xFF1E1E1E),
        surfaceMuted: Color(0xFF2C2C2C),
        primary: Color(0xFF2196F3),
        primarySoft: Color(0xFF174A78),
        accent: Color(0xFFFF9800),
        text: Color(0xFFFFFFFF),
        textMuted: Color(0xFFB3B3B3),
        border: Color(0xFF333333),
        dartboardDark: Color(0xFF222222),
        dartboardLight: Color(0xFFF5F5DC),
      );
    }

    return const AppPalette(
      background: Color(0xFFF5F5F5),
      surface: Color(0xFFFFFFFF),
      surfaceMuted: Color(0xFFEEEEEE),
      primary: Color(0xFF1976D2),
      primarySoft: Color(0xFFBBDEFB),
      accent: Color(0xFFFF9800),
      text: Color(0xFF212121),
      textMuted: Color(0xFF757575),
      border: Color(0xFFE0E0E0),
      dartboardDark: Color(0xFF222222),
      dartboardLight: Color(0xFFF5F5DC),
    );
  }
}
