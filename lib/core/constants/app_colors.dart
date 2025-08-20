import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Dark Theme dengan Teal/Orange/Purple Accents
  static const Color primaryBackground = Color(0xFF0D0D0D); // Hitam pekat
  static const Color secondaryBackground = Color(0xFF1A1A1A); // Abu gelap
  static const Color surfaceBackground = Color(0xFF1A1A1A);

  // Main Brand Colors
  static const Color primary = Color(0xFF00D4AA); // Teal/hijau tosca
  static const Color secondary = Color(0xFFFF8C42); // Orange
  static const Color accent = Color(0xFF8B5CF6); // Purple
  
  // Legacy purple support (untuk kompatibilitas)
  static const Color primaryPurple = primary; // Gunakan teal sebagai primary
  static const Color secondaryPurple = accent; // Purple sebagai accent
  static const Color lightPurple = Color(0xFFDDD6FE);

  // Text Colors
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFB0B0B0);
  static const Color mutedText = Color(0xFF262626); // Abu sedang

  // Status Colors
  static const Color success = Color(0xFF00D4AA); // Sama dengan primary
  static const Color error = Color(0xFFFF4757); // Merah destructive
  static const Color warning = Color(0xFFFF8C42); // Sama dengan secondary
  static const Color info = Color(0xFF8B5CF6); // Purple accent

  // Additional Colors
  static const Color cardBackground = Color(0xFF1A1A1A); // Abu gelap
  static const Color borderColor = Color(0xFF262626); // Abu sedang
  static const Color dividerColor = Color(0xFF262626);

  // Chart Colors
  static const Color chart1 = Color(0xFF00D4AA); // Teal
  static const Color chart2 = Color(0xFFFF8C42); // Orange
  static const Color chart3 = Color(0xFF8B5CF6); // Purple
  static const Color chart4 = Color(0xFFFF4757); // Merah
  static const Color chart5 = Color(0xFFFFC107); // Kuning

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Music-specific colors
  static const Color musicPlayerBackground = Color(0xFF0D0D0D);
  static const Color waveformColor = primary;
  static const Color albumCoverOverlay = Color(0x40000000);

  // Social colors
  static const Color likeColor = Color(0xFFFF4757); // Merah
  static const Color followButtonColor = primary; // Teal
  static const Color followingButtonColor = Color(0xFF262626);

  // Bottom navigation
  static const Color navBarBackground = Color(0xFF1A1A1A);
  static const Color navBarActive = primary; // Teal
  static const Color navBarInactive = Color(0xFF262626);

  // Search bar
  static const Color searchBarBackground = Color(0xFF262626);

  // Online status
  static const Color onlineIndicator = success; // Teal
}
