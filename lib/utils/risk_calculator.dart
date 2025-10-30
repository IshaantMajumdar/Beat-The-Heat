import 'dart:math';
import 'dart:async';
import '../models/user_profile.dart';
import '../models/enhanced_weather_risk.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';
import 'safety_recommendations_engine.dart';

class RiskCalculator {
  static final StreamController<int> _riskUpdates = StreamController<int>.broadcast();
  static Timer? _updateTimer;
  static WeatherService? _weatherService;

  // Stream of risk updates that UI can listen to
  static Stream<int> get riskUpdates => _riskUpdates.stream;

  // Initialize real-time updates
  static void initializeRealTimeUpdates(WeatherService weatherService, {Duration updateInterval = const Duration(minutes: 15)}) {
    _weatherService = weatherService;
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(updateInterval, (timer) => _updateRisk());
  }

  // Stop real-time updates
  static void stopRealTimeUpdates() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  // Update risk and notify listeners
  static Future<void> _updateRisk() async {
    if (_weatherService == null) return;
    
    try {
      final weather = await _weatherService!.getCurrentWeather(0, 0); // Replace with actual coordinates
      if (weather != null) {
        final enhancedRisk = EnhancedWeatherRisk.fromWeatherData(weather);
        final baseRisk = heatRiskScore(enhancedRisk.heatIndex);
        _riskUpdates.add(baseRisk);
      }
    } catch (e) {
      print('Error updating risk: $e');
    }
  }
  // Compute approximate heat index given temperature in Celsius and relative humidity (%)
  static double heatIndexC(double tempC, double rh) {
    final tF = tempC * 9 / 5 + 32;
    final r = rh;
    // Rothfusz regression (valid for T >= 80F and RH >= 40%) but we will apply a softened version
    double hiF = -42.379 + 2.04901523 * tF + 10.14333127 * r - 0.22475541 * tF * r - 6.83783e-3 * tF * tF - 5.481717e-2 * r * r + 1.22874e-3 * tF * tF * r + 8.5282e-4 * tF * r * r - 1.99e-6 * tF * tF * r * r;

    // Adjustment for low humidity or low temperature
    if (r < 13 && tF >= 80 && tF <= 112) {
      hiF -= ((13 - r) / 4) * sqrt((17 - (tF - 95).abs()) / 17);
    } else if (r > 85 && tF >= 80 && tF <= 87) {
      hiF += ((r - 85) / 10) * ((87 - tF) / 5);
    }

    // For temperatures below ~80F, heat index is close to temp; provide gentle uplift for humidity
    if (tF < 80) {
      hiF = tF + (r / 100) * (tF - 50) * 0.1;
    }

    return (hiF - 32) * 5 / 9;
  }

  // Map heat index (C) to a 0-100 risk score
  static int heatRiskScore(double heatIndexC) {
    final hi = heatIndexC;
    if (hi <= 26) return 5 + (hi / 26 * 10).round(); // 5-15
    if (hi <= 32) return 15 + ((hi - 26) / (32 - 26) * 25).round(); // 15-40
    if (hi <= 38) return 40 + ((hi - 32) / (38 - 32) * 30).round(); // 40-70
    final extra = min(30, ((hi - 38) * 3).round());
    return 70 + extra; // up to 100
  }

  // Calculate vulnerability multiplier based on user profile
  static double calculateVulnerabilityMultiplier(UserProfile profile) {
    double multiplier = 1.0;

    // Age-based risk
    if (profile.age >= 65) {
      multiplier += 0.3;
    } else if (profile.age >= 55) {
      multiplier += 0.2;
    } else if (profile.age <= 12) {
      multiplier += 0.2;
    }

    // Medical conditions
    if (profile.hasCardio) multiplier += 0.25;
    if (profile.hasRespiratory) multiplier += 0.2;
    if (profile.hasDiabetes) multiplier += 0.15;
    if (profile.hasHypertension) multiplier += 0.15;

    // Activity level adjustment
    switch (profile.activityLevel) {
      case ActivityLevel.sedentary:
        multiplier += 0.1; // Less heat-adapted
      case ActivityLevel.light:
        multiplier += 0.05;
      case ActivityLevel.moderate:
        break; // No adjustment
      case ActivityLevel.active:
        multiplier -= 0.05; // Better heat-adapted
      case ActivityLevel.veryActive:
        multiplier -= 0.1; // Best heat-adapted
    }

    // Gender-based adjustments
    if (profile.gender == Gender.female) {
      multiplier += 0.05;
    }

    return multiplier.clamp(0.5, 2.0); // Ensure multiplier stays within reasonable bounds
  }

  // Calculate final risk score with enhanced weather data
  static int calculateEnhancedRisk(WeatherData weather, UserProfile profile) {
    final enhancedRisk = EnhancedWeatherRisk.fromWeatherData(weather);
    int baseScore = heatRiskScore(enhancedRisk.heatIndex);
    
    // Apply environmental factors
    double timeRiskFactor = enhancedRisk.getTimeRiskFactor();
    double uvRiskFactor = enhancedRisk.getUVRiskFactor();
    double vulnerabilityMultiplier = calculateVulnerabilityMultiplier(profile);
    
    // Combine all risk factors
    return combinedRisk(baseScore, vulnerabilityMultiplier * timeRiskFactor * uvRiskFactor);
  }

  // Calculate final risk score (legacy method for compatibility)
  static int calculateFinalRisk(double heatIndexC, UserProfile profile) {
    int baseScore = heatRiskScore(heatIndexC);
    double vulnerabilityMultiplier = calculateVulnerabilityMultiplier(profile);
    return combinedRisk(baseScore, vulnerabilityMultiplier);
  }

  // Combine heat risk with vulnerability multiplier
  static int combinedRisk(int heatScore, double riskMultiplier) {
    final r = (heatScore * riskMultiplier).round();
    return r.clamp(0, 100);
  }

  // Get risk level description
  static String getRiskDescription(int riskScore) {
    if (riskScore < 20) {
      return 'Low Risk - Normal activities can be maintained.';
    } else if (riskScore < 40) {
      return 'Moderate Risk - Take precautions during outdoor activities.';
    } else if (riskScore < 60) {
      return 'High Risk - Limit outdoor activities and stay hydrated.';
    } else if (riskScore < 80) {
      return 'Very High Risk - Avoid prolonged outdoor activities.';
    } else {
      return 'Extreme Risk - Stay indoors if possible. Seek immediate cooling if outdoors.';
    }
  }

  // Get enhanced personalized recommendations using the new engine
  static List<String> getEnhancedRecommendations(
    int riskScore,
    UserProfile profile,
    EnhancedWeatherRisk weatherRisk,
  ) {
                final recommendations = SafetyRecommendationsEngine.generateRecommendations(
      riskScore: riskScore,
      profile: profile,
      weatherRisk: weatherRisk,
      currentWeather: WeatherData(
        temperature: weatherRisk.temperature,
        humidity: weatherRisk.humidity,
        uvIndex: weatherRisk.uvIndex,
        timestamp: weatherRisk.timestamp,
        feelsLike: weatherRisk.temperature, // Use actual temperature instead of 0
        windSpeed: 0, // Default value since it's not stored in EnhancedWeatherRisk
        description: 'Not available', // Default value
        icon: '01d', // Default sunny icon
      ),
    );

    // Convert SafetyRecommendation objects to strings for backwards compatibility
    List<String> legacyFormat = [];
    
    // Add emergency recommendations first
    recommendations.where((r) => r.isEmergency).forEach((r) {
      legacyFormat.add(r.title);
      legacyFormat.addAll(r.actionItems);
    });

    // Add other recommendations sorted by priority
    recommendations.where((r) => !r.isEmergency).forEach((r) {
      legacyFormat.add(r.title);
      legacyFormat.addAll(r.actionItems);
    });

    return legacyFormat;
  }

  // Legacy method for backward compatibility
  static List<String> getRecommendations(int riskScore, UserProfile profile) {
    // Create a basic EnhancedWeatherRisk for legacy support
    final enhancedRisk = EnhancedWeatherRisk(
      temperature: 0,
      humidity: 0,
      uvIndex: 0,
      timestamp: DateTime.now(),
      heatIndex: 0,
      baseRiskScore: riskScore,
    );
    return getEnhancedRecommendations(riskScore, profile, enhancedRisk);
  }
}
