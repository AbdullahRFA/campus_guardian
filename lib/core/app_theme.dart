import 'package:flutter/material.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    // 1. Color Scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0D47A1), // A deep blue, inspired by your university logo
      primary: const Color(0xFF1976D2),
      secondary: const Color(0xFF42A5F5),
      background: const Color(0xFFF5F5F5), // A light grey background
      error: Colors.redAccent,
    ),

    // 2. AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1976D2),
      foregroundColor: Colors.white, // Text and icon color
      elevation: 2.0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),

    // 3. Text Theme
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black87),
    ),

    // 4. ElevatedButton Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1976D2), // Button color
        foregroundColor: Colors.white, // Text color on button
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    useMaterial3: true,
  );
}