import 'package:flutter/material.dart';

class AppStyles {
  // Base Colors
  static const primaryColor = Color(0xFFFF5722); // Orange for heat theme
  static const secondaryColor = Color(0xFF2196F3); // Blue for coolness
  static const backgroundColor = Color(0xFFFAFAFA);
  static const darkBackgroundColor = Color(0xFF1A1A1A);
  
  // Risk Level Colors
  static const lowRiskColor = Color(0xFF4CAF50);
  static const moderateRiskColor = Color(0xFFFFA000);
  static const highRiskColor = Color(0xFFE64A19);
  static const extremeRiskColor = Color(0xFFD32F2F);
  
  // Text Styles
  static const headerStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.15,
  );
  
  static const subheaderStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );
  
  static const bodyStyle = TextStyle(
    fontSize: 16,
    letterSpacing: 0.5,
  );
  
  // Decorations
  static const cardDecoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(16)),
    color: Colors.white,
  );
  
  static const cardDecorationDark = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(16)),
    color: Color(0xFF2C2C2C),
  );
  
  // Animation Durations
  static const Duration quickAnimation = Duration(milliseconds: 200);
  static const Duration standardAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  
  // Padding and Spacing
  static const EdgeInsets standardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const double standardSpacing = 16.0;
  static const double smallSpacing = 8.0;
  
  // Risk Level Styles
  static Color getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return lowRiskColor;
      case 'moderate':
        return moderateRiskColor;
      case 'high':
        return highRiskColor;
      case 'extreme':
        return extremeRiskColor;
      default:
        return primaryColor;
    }
  }
  
  static String getRiskIcon(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return '🟢'; // Replace with actual icon codes
      case 'moderate':
        return '🟡';
      case 'high':
        return '🟠';
      case 'extreme':
        return '🔴';
      default:
        return '⚪';
    }
  }
}