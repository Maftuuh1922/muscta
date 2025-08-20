import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Dark Theme dengan Purple Accents
  static const Color primaryBackground = Color(0xFF1A1A1A);
  static const Color secondaryBackground = Color(0xFF2A2A2A);
  static const Color surfaceBackground = Color(0xFF1E1E1E);

  // Purple Accent Colors
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color secondaryPurple = Color(0xFFA78BFA);
  static const Color lightPurple = Color(0xFFDDD6FE);

  // Text Colors
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFB0B0B0);
  static const Color mutedText = Color(0xFF6B7280);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Additional Colors
  static const Color cardBackground = Color(0xFF2A2A2A);
  static const Color borderColor = Color(0xFF374151);
  static const Color dividerColor = Color(0xFF1F2937);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, secondaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF2A2A2A), Color(0xFF1E1E1E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Music-specific colors
  static const Color musicPlayerBackground = Color(0xFF1A1A1A);
  static const Color waveformColor = primaryPurple;
  static const Color albumCoverOverlay = Color(0x40000000);

  // Social colors
  static const Color likeColor = Color(0xFFEF4444);
  static const Color followButtonColor = primaryPurple;
  static const Color followingButtonColor = Color(0xFF374151);

  // Bottom navigation
  static const Color navBarBackground = Color(0xFF1A1A1A);
  static const Color navBarActive = primaryPurple;
  static const Color navBarInactive = Color(0xFF6B7280);

  // Search bar
  static const Color searchBarBackground = Color(0xFF374151);

  // Online status
  static const Color onlineIndicator = success;
}
