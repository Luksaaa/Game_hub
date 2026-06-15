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
        background: Color(0xFF0A0D0C),
        surface: Color(0xFF121816),
        surfaceMuted: Color(0xFF18221E),
        primary: Color(0xFF00B074),
        primarySoft: Color(0xFF0F3227),
        accent: Color(0xFFFFD369),
        text: Color(0xFFF5F7F6),
        textMuted: Color(0xFF8FA09A),
        border: Color(0xFF22302A),
        dartboardDark: Color(0xFF1C1D1C),
        dartboardLight: Color(0xFFFAF0DD),
      );
    }

    return const AppPalette(
      background: Color(0xFFF7F9F8),
      surface: Colors.white,
      surfaceMuted: Color(0xFFEDF1EF),
      primary: Color(0xFF0E533F),
      primarySoft: Color(0xFFE2F0EC),
      accent: Color(0xFFE89A1A),
      text: Color(0xFF1A2622),
      textMuted: Color(0xFF6A7F78),
      border: Color(0xFFD2DDD9),
      dartboardDark: Color(0xFF232524),
      dartboardLight: Color(0xFFFBF4E6),
    );
  }
}
