import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors - Teal
  static const Color primaryTeal = Color(0xFF009688);
  static const Color primaryTealLight = Color(0xFF4DB6AC);
  static const Color primaryTealDark = Color(0xFF00796B);

  // Secondary/Accent Colors - Deep Orange
  static const Color accentOrange = Color(0xFFFF5722);
  static const Color accentOrangeLight = Color(0xFFFF8A65);

  // Status Colors
  static const Color statusOpen = Color(0xFFF44336);
  static const Color statusInProgress = Color(0xFFFFC107);
  static const Color statusResolved = Color(0xFF4CAF50);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundTeal = Color(0xFFE0F2F1);
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textHint = Color(0xFFBDBDBD);

  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderMedium = Color(0xFFBDBDBD);

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);

  // Error Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFFFEBEE);

  // Success Colors
  static const Color success = Color(0xFF388E3C);
  static const Color successLight = Color(0xFFE8F5E9);

  // Get status color based on status string
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return statusOpen;
      case 'in progress':
        return statusInProgress;
      case 'resolved':
        return statusResolved;
      default:
        return textSecondary;
    }
  }

  // Get priority color
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return statusOpen;
      case 'medium':
        return statusInProgress;
      case 'low':
        return primaryTeal;
      default:
        return textSecondary;
    }
  }
}

