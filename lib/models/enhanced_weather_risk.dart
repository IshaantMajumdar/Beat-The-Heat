import '../models/weather_data.dart';

class EnhancedWeatherRisk {
  final double temperature;
  final double humidity;
  final double uvIndex;
  final DateTime timestamp;
  final double heatIndex;
  final int baseRiskScore;

  EnhancedWeatherRisk({
    required this.temperature,
    required this.humidity,
    required this.uvIndex,
    required this.timestamp,
    required this.heatIndex,
    required this.baseRiskScore,
  });

  factory EnhancedWeatherRisk.fromWeatherData(WeatherData data) {
    return EnhancedWeatherRisk(
      temperature: data.temperature,
      humidity: data.humidity,
      uvIndex: data.uvIndex,
      timestamp: data.timestamp,
      heatIndex: data.feelsLike,
      baseRiskScore: 0, // Will be calculated later
    );
  }

  /// Get the time-of-day risk factor (1.0 = normal, >1.0 = increased risk)
  double getTimeRiskFactor() {
    final hour = timestamp.hour;
    
    // Peak heat hours (10 AM - 4 PM) have higher risk
    if (hour >= 10 && hour <= 16) {
      return 1.2; // 20% increase in risk during peak hours
    }
    // Early morning and evening have lower risk
    if (hour < 6 || hour > 20) {
      return 0.8; // 20% decrease in risk during cooler hours
    }
    // Gradual increase/decrease during transition hours
    if (hour < 10) {
      return 0.8 + (hour - 6) * 0.1; // Gradual increase from 6 AM to 10 AM
    }
    // Gradual decrease from 4 PM to 8 PM
    return 1.2 - (hour - 16) * 0.1;
  }

  /// Get UV index risk factor
  double getUVRiskFactor() {
    if (uvIndex <= 2) return 1.0; // Low UV
    if (uvIndex <= 5) return 1.1; // Moderate UV
    if (uvIndex <= 7) return 1.2; // High UV
    if (uvIndex <= 10) return 1.3; // Very High UV
    return 1.4; // Extreme UV
  }
}