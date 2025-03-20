import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF9370DB);     // Main purple color from your design
  static const Color accent = Color(0xFFBEBEF4);      // Lighter purple for accents
  static const Color background = Color(0xFFF9F0FF);  // Very light purple for backgrounds
  
  // Text colors
  static const Color textPrimary = Color(0xFF333333); // Dark text
  static const Color textSecondary = Color(0xFF666666); // Medium gray text
  static const Color textLight = Color(0xFF999999);   // Light gray text
  
  // UI element colors
  static const Color inactive = Color(0xFFBBBBBB);    // Inactive elements
  static const Color divider = Color(0xFFEEEEEE);     // Dividers and borders
  static const Color cardBackground = Colors.white;   // Card backgrounds
  
  // Feedback colors
  static const Color success = Color(0xFF4CAF50);     // Success messages
  static const Color error = Color(0xFFE53935);       // Error messages
  static const Color warning = Color(0xFFFFC107);     // Warning messages
  static const Color info = Color(0xFF2196F3);        // Information messages
  
  // Chart colors (for fitness progress charts)
  static const List<Color> chartColors = [
    Color(0xFF9370DB), // Main purple
    Color(0xFF64B5F6), // Blue
    Color(0xFF81C784), // Green
    Color(0xFFFFB74D), // Orange
    Color(0xFFE57373), // Red
  ];
}