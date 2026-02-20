import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFD1A681);     // lightest beige/cream
  static const Color primary = Color(0xFF93633A);        // dark brown
  static const Color secondary = Color.fromARGB(255, 181, 199, 189);      // sage green
  static const Color tertiary = Color(0xFFD8CFE6);        // light lavender
  static const Color accent = Color(0xFF987C8F);         // mauve
  
  // brown shades palette (darker alternatives)R
  static const Color darkBrown = Color(0xFF93633A);      
  // static const Color mediumBrown = Color(0xF93633A);    
  
  // functional Rcolors
  static const Color border = Color(0xFF93633A);         // dark brown
  static const Color textPrimary = Color(0xFF93633A);    // darkest brown (almost black)
  static const Color textSecondary = Color(0xFFC0936D);  // medium brown
  static const Color error = Color(0xFFC84B31);          // red
}

class AppTextStyles {
  static const String headingFont = 'Dela Gothic One';
  static const String bodyFont = 'Zalando Sans';
  
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: headingFont,  
  );
  
  static const TextStyle subheading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: bodyFont,  
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
    fontFamily: bodyFont, 
  );
  
  static const TextStyle label = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
    fontFamily: bodyFont,  
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFFFFFFFF),
    fontFamily: bodyFont,  
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