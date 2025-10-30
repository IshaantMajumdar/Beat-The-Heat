import 'package:flutter/material.dart';

// A vibrant, modern color scheme for the app
class BTHColors {
  // Primary brand colors
  static const primaryBlue = Color(0xFF2196F3);      // Vibrant blue for main UI
  static const primaryOrange = Color(0xFFFF9800);     // Energetic orange for accents
  
  // Risk level colors - Vibrant yet clear indicators
  static const lowRisk = Color(0xFF4CD964);          // Fresh, positive green
  static const moderateRisk = Color(0xFFFFB340);     // Warm, attention-grabbing amber
  static const highRisk = Color(0xFFFF3B30);         // Strong, warning red
  static const extremeRisk = Color(0xFFD90429);      // Deep, urgent red
  
  // Temperature based colors
  static const coolTemp = Color(0xFF48CAE4);         // Cool, refreshing blue
  static const mildTemp = Color(0xFFADE8F4);         // Soft, comfortable blue
  static const warmTemp = Color(0xFFFFB4A2);         // Warm peach
  static const hotTemp = Color(0xFFFF6B6B);          // Hot, energetic red

  // Background gradients
  static const backgroundLight = [
    Color(0xFFE3F2FD),                              // Light blue tint
    Color(0xFFFFFFFF),                              // Pure white
  ];
  
  static const backgroundDark = [
    Color(0xFF1A1A1A),                              // Soft black
    Color(0xFF2C2C2C),                              // Dark gray
  ];

  // Accent colors for UI elements
  static const accentYellow = Color(0xFFFFD60A);    // Vibrant yellow for highlights
  static const accentPurple = Color(0xFF9D4EDD);    // Rich purple for special elements
  static const accentTeal = Color(0xFF2EC4B6);      // Fresh teal for success states
  
  // Text colors
  static const textDark = Color(0xFF2B2D42);        // Rich dark blue for text
  static const textLight = Color(0xFFF8F9FA);       // Soft white for dark mode
  static const textMuted = Color(0xFF6C757D);       // Muted gray for secondary text

  // Semantic colors
  static const success = Color(0xFF28A745);         // Success green
  static const info = Color(0xFF17A2B8);           // Info blue
  static const warning = Color(0xFFFFC107);         // Warning yellow
  static const error = Color(0xFFDC3545);          // Error red

  // Color scheme for light mode
  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryBlue,
    onPrimary: Colors.white,
    secondary: primaryOrange,
    onSecondary: Colors.white,
    error: error,
    onError: Colors.white,
    background: Color(0xFFF8F9FA),
    onBackground: textDark,
    surface: Colors.white,
    onSurface: textDark,
  );

  // Color scheme for dark mode
  static const darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryBlue,
    onPrimary: Colors.white,
    secondary: primaryOrange,
    onSecondary: Colors.white,
    error: error,
    onError: Colors.white,
    background: Color(0xFF1A1A1A),
    onBackground: textLight,
    surface: Color(0xFF2C2C2C),
    onSurface: textLight,
  );

  // Get temperature color based on value
  static Color getTemperatureColor(double temperature) {
    if (temperature < 20) return coolTemp;
    if (temperature < 25) return mildTemp;
    if (temperature < 30) return warmTemp;
    return hotTemp;
  }

  // Get risk color based on level
  static Color getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':
        return lowRisk;
      case 'moderate':
        return moderateRisk;
      case 'high':
        return highRisk;
      case 'extreme':
        return extremeRisk;
      default:
        return moderateRisk;
    }
  }

  // Get a gradient based on risk level
  static List<Color> getRiskGradient(String risk) {
    final baseColor = getRiskColor(risk);
    return [
      baseColor.withOpacity(0.8),
      baseColor,
    ];
  }
}