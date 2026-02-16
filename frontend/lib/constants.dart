import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF2E0D3);     // lightest beige/cream
  static const Color primary = Color(0xFF6F4E37);        // dark brown
  static const Color secondary = Color.fromARGB(255, 181, 199, 189);      // sage green
  static const Color tertiary = Color(0xFFD8CFE6);        // light lavender
  static const Color accent = Color(0xFF987C8F);         // mauve/purple
  
  // brown shades palette (darker alternatives)
  static const Color darkBrown = Color(0xFF6F4E37);      // main brown
  static const Color mediumBrown = Color(0xFF634631);    // medium brown
  // static const Color slate = Color(0xFF583E2C);          // darker brown/slate
  
  // Functional colors
  static const Color border = Color.fromARGB(255, 71, 50, 35);         // soft pink-beige
  static const Color textPrimary = Color(0xFF3A302D);    // darkest brown (almost black)
  static const Color textSecondary = Color.fromARGB(255, 86, 61, 43);  // medium brown
  static const Color error = Color(0xFFC84B31);          // dark brown (placeholder)
}

class AppTextStyles {
  // Default font family - using system default for now
  // To use a custom font, add it to pubspec.yaml first
  static const String fontFamily = 'Josefin Sans'; // or 'Arial', or leave blank for system default
  
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle subheading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle label = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFFFFFFFF), // white text on dark buttons
    fontFamily: fontFamily,
  );
}

class AppSpacing {
  static const double sm = 10.0;
  static const double md = 20.0;
  static const double lg = 40.0;
  static const double xl = 200.0;
}

class AppBorderRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
}