import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get electronicTheme {
    final base = ThemeData.dark();
    
    return base.copyWith(
      scaffoldBackgroundColor: AppConstants.bgBlack,
      primaryColor: AppConstants.primaryViolet,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppConstants.primaryViolet,
        secondary: AppConstants.accentCyan,
        surface: AppConstants.cardGrey,
        error: AppConstants.errorRed,
      ),

      // Typography (Orbitron for headers, Roboto for body)
      textTheme: GoogleFonts.orbitronTextTheme(base.textTheme).copyWith(
        bodyMedium: GoogleFonts.roboto(color: Colors.white70),
        bodyLarge: GoogleFonts.roboto(color: Colors.white),
      ),

      // Input Fields (Glowing Borders)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.cardGrey,
        hintStyle: const TextStyle(color: Colors.white30),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.accentCyan, width: 2),
        ),
      ),
      
      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Orbitron', 
          fontSize: 20, 
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: Colors.white
        ),
      ),
    );
  }
}