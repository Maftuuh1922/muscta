import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.primaryBackground,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryPurple,
        secondary: AppColors.secondaryPurple,
        surface: AppColors.surfaceBackground,
        onPrimary: AppColors.primaryText,
        onSecondary: AppColors.primaryText,
        onSurface: AppColors.primaryText,
        error: AppColors.error,
      ),
      
      // Text Theme
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
          displaySmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
          headlineLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
          headlineMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryText,
          ),
          headlineSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryText,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: AppColors.primaryText,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: AppColors.secondaryText,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: AppColors.mutedText,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.mutedText,
          ),
        ),
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primaryText),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: AppColors.primaryText,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryText,
          side: const BorderSide(color: AppColors.borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.searchBarBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: const TextStyle(
          color: AppColors.mutedText,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: AppColors.secondaryText,
          fontSize: 14,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.primaryText,
        size: 24,
      ),
      
      primaryIconTheme: const IconThemeData(
        color: AppColors.primaryText,
        size: 24,
      ),
      
      // Chip Theme
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.cardBackground,
        selectedColor: AppColors.primaryPurple,
        disabledColor: AppColors.mutedText,
        labelStyle: TextStyle(color: AppColors.primaryText),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.secondaryText,
        ),
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cardBackground,
        modalBackgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
      ),
      
      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        textColor: AppColors.primaryText,
        iconColor: AppColors.primaryText,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerColor,
        thickness: 0.5,
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryPurple;
          }
          return AppColors.mutedText;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryPurple.withOpacity(0.3);
          }
          return AppColors.cardBackground;
        }),
      ),
      
      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryPurple,
        inactiveTrackColor: AppColors.cardBackground,
        thumbColor: AppColors.primaryPurple,
        overlayColor: AppColors.primaryPurple.withOpacity(0.2),
        valueIndicatorColor: AppColors.primaryPurple,
        valueIndicatorTextStyle: const TextStyle(
          color: AppColors.primaryText,
        ),
      ),
      
      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primaryPurple,
        unselectedLabelColor: AppColors.mutedText,
        indicatorColor: AppColors.primaryPurple,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}

// Custom Text Styles for specific use cases
class AppTextStyles {
  static const TextStyle username = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: AppColors.primaryText,
  );
  
  static const TextStyle timestamp = TextStyle(
    fontSize: 12,
    color: AppColors.mutedText,
  );
  
  static const TextStyle musicTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );
  
  static const TextStyle artistName = TextStyle(
    fontSize: 14,
    color: AppColors.secondaryText,
  );
  
  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );
  
  static const TextStyle smallButton = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );
  
  static const TextStyle tabText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );
  
  static const TextStyle hintText = TextStyle(
    fontSize: 14,
    color: AppColors.mutedText,
  );
}
