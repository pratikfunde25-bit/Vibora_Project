import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  COLOR PALETTE
// ─────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42D8);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentSecondary = Color(0xFFFFBE0B);
  static const Color success = Color(0xFF06D6A0);
  static const Color warning = Color(0xFFFFBE0B);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF4ECDC4);

  // Light Mode
  static const Color bgLight = Color(0xFFF8F9FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF0F0FF);
  static const Color onSurfaceLight = Color(0xFF1A1A2E);
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textTertiaryLight = Color(0xFF9CA3AF);
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Dark Mode
  static const Color bgDark = Color(0xFF0A0A1A);
  static const Color surfaceDark = Color(0xFF13132B);
  static const Color surfaceVariantDark = Color(0xFF1E1E3A);
  static const Color onSurfaceDark = Color(0xFFF1F1F5);
  static const Color textPrimaryDark = Color(0xFFF1F1F5);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textTertiaryDark = Color(0xFF6B7280);
  static const Color dividerDark = Color(0xFF2D2D4A);
  static const Color cardDark = Color(0xFF1A1A35);

  // Gradient Presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9D97FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFFBE0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0A0A1A), Color(0xFF1A1A35)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Category Colors
  static const Map<String, Color> categoryColors = {
    'Hackathon': Color(0xFF6C63FF),
    'Workshop': Color(0xFF4ECDC4),
    'Conference': Color(0xFFFF6B6B),
    'Cultural': Color(0xFFFFBE0B),
    'Sports': Color(0xFF06D6A0),
    'Tech Talk': Color(0xFF9D97FF),
    'Corporate': Color(0xFF3D5AFE),
    'Networking': Color(0xFFFF6584),
    'Webinar': Color(0xFF00BFA5),
  };
}
