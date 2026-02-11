import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const deepPurple = Color(0xFF6C3FC5);
  static const purple = Color(0xFF7B42F6);
  static const lightPurple = Color(0xFF9B6DFF);
  static const gold = Color(0xFFFFB800);
  static const correctGreen = Color(0xFF4CAF50);
  static const wrongRed = Color(0xFFE53935);
  static const cardBg = Colors.white;
  static const lightGrey = Color(0xFFF5F5F5);

  static const purpleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7B42F6), Color(0xFF6C3FC5)],
  );

  static const List<Color> levelAccents = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFBE0B),
    Color(0xFF45B7D1),
    Color(0xFF96CEB4),
    Color(0xFFDDA0DD),
  ];
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: AppColors.deepPurple,
      scaffoldBackgroundColor: AppColors.lightGrey,
      textTheme: GoogleFonts.nunitoTextTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.deepPurple,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
