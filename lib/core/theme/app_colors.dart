import 'package:flutter/material.dart';

/// Premium color palette for BCHMS.
/// Medical teal + warm gold — trust, authority, warmth.
class AppColors {
  AppColors._();

  // ── Primary Palette ──────────────────────────────────────────────
  static const Color primary = Color(0xFF0D7377);
  static const Color primaryLight = Color(0xFF14A3A8);
  static const Color primaryDark = Color(0xFF095456);
  static const Color primarySurface = Color(0xFFE8F6F6);

  // ── Accent / Gold ────────────────────────────────────────────────
  static const Color accent = Color(0xFFD4A843);
  static const Color accentLight = Color(0xFFF5E6C0);
  static const Color accentDark = Color(0xFFB08A2E);

  // ── Neutral Surfaces ─────────────────────────────────────────────
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF1F3F7);
  static const Color border = Color(0xFFE2E6EC);
  static const Color borderLight = Color(0xFFF0F1F4);
  static const Color divider = Color(0xFFEEF0F4);

  // ── Text ──────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1D21);
  static const Color textSecondary = Color(0xFF5A6170);
  static const Color textTertiary = Color(0xFF9098A8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFF1A1D21);

  // ── Semantic ──────────────────────────────────────────────────────
  static const Color success = Color(0xFF1B9E5A);
  static const Color successLight = Color(0xFFE6F7EE);
  static const Color warning = Color(0xFFE5A100);
  static const Color warningLight = Color(0xFFFFF8E6);
  static const Color error = Color(0xFFDC3545);
  static const Color errorLight = Color(0xFFFDE8EA);
  static const Color info = Color(0xFF2D8CF0);
  static const Color infoLight = Color(0xFFE8F2FE);

  // ── Sidebar / Navigation ─────────────────────────────────────────
  static const Color sidebarBg = Color(0xFF0C2D30);
  static const Color sidebarText = Color(0xFFB0C7C8);
  static const Color sidebarActive = Color(0xFF14A3A8);
  static const Color sidebarHover = Color(0xFF0F3D41);

  // ── Chart Colors ──────────────────────────────────────────────────
  static const List<Color> chartPalette = [
    Color(0xFF0D7377),
    Color(0xFFD4A843),
    Color(0xFF1B9E5A),
    Color(0xFF2D8CF0),
    Color(0xFFE5A100),
    Color(0xFF9B59B6),
    Color(0xFFE74C3C),
    Color(0xFF1ABC9C),
  ];

  // ── Glassmorphism ─────────────────────────────────────────────────
  static Color glassWhite = Colors.white.withValues(alpha: 0.72);
  static Color glassBorder = Colors.white.withValues(alpha: 0.25);
  static Color glassShadow = const Color(0xFF0D7377).withValues(alpha: 0.06);
}
