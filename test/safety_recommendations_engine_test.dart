import 'package:flutter_test/flutter_test.dart';
import 'package:beat_the_heat/models/user_profile.dart';
import 'package:beat_the_heat/models/enhanced_weather_risk.dart';
import 'package:beat_the_heat/models/weather_data.dart';
import 'package:beat_the_heat/utils/safety_recommendations_engine.dart';

void main() {
  late WeatherData testWeather;
  late UserProfile healthyAdult;
  late UserProfile elderlyWithConditions;
  late UserProfile activeYoungPerson;
  late EnhancedWeatherRisk normalRisk;
  late EnhancedWeatherRisk highRisk;

  setUp(() {
    // Set up test weather data
    testWeather = WeatherData(
      temperature: 30, // 30°C
      humidity: 60, // 60%
      uvIndex: 6, // High UV
      timestamp: DateTime(2025, 7, 15, 14, 0), // 2 PM on a summer day
      feelsLike: 32, // 32°C
      windSpeed: 2.0,
      description: 'Sunny',
      icon: '01d',
    );

    // Set up different user profiles for testing
    healthyAdult = UserProfile(
      age: 35,
      gender: Gender.male,
      hasCardio: false,
      hasRespiratory: false,
      hasDiabetes: false,
      hasHypertension: false,
      activityLevel: ActivityLevel.moderate,
      consented: true,
    );

    elderlyWithConditions = UserProfile(
      age: 70,
      gender: Gender.female,
      hasCardio: true,
      hasRespiratory: true,
      hasDiabetes: false,
      hasHypertension: true,
      activityLevel: ActivityLevel.light,
      consented: true,
    );

    activeYoungPerson = UserProfile(
      age: 25,
      gender: Gender.female,
      hasCardio: false,
      hasRespiratory: false,
      hasDiabetes: false,
      hasHypertension: false,
      activityLevel: ActivityLevel.veryActive,
      consented: true,
    );

    // Set up different risk scenarios
    normalRisk = EnhancedWeatherRisk(
      temperature: 28,
      humidity: 50,
      uvIndex: 4,
      timestamp: DateTime(2025, 7, 15, 9, 0), // 9 AM
      heatIndex: 29,
      baseRiskScore: 40,
    );

    highRisk = EnhancedWeatherRisk(
      temperature: 35,
      humidity: 70,
      uvIndex: 9,
      timestamp: DateTime(2025, 7, 15, 14, 0), // 2 PM
      heatIndex: 42,
      baseRiskScore: 85,
    );
  });

  group('SafetyRecommendationsEngine Tests', () {
    test('Should generate emergency recommendations for extreme conditions', () {
      final recommendations = SafetyRecommendationsEngine.generateRecommendations(
        riskScore: 85,
        profile: elderlyWithConditions,
        weatherRisk: highRisk,
        currentWeather: testWeather,
      );

      // Find emergency recommendations
      final emergencyRecs = recommendations.where((r) => r.isEmergency).toList();

      expect(emergencyRecs, isNotEmpty);
      expect(emergencyRecs.length, 2); // Should have both general and vulnerable-specific emergency recs
      expect(
        emergencyRecs.any((r) => r.title.contains('EXTREME HEAT DANGER')),
        isTrue,
      );
      expect(
        emergencyRecs.any((r) => r.title.contains('HIGH RISK FOR VULNERABLE')),
        isTrue,
      );
    });

    test('Should provide appropriate recommendations for healthy adults in moderate conditions', () {
      final recommendations = SafetyRecommendationsEngine.generateRecommendations(
        riskScore: 45,
        profile: healthyAdult,
        weatherRisk: normalRisk,
        currentWeather: testWeather,
      );

      // Should not have emergency recommendations
      expect(
        recommendations.where((r) => r.isEmergency).isEmpty,
        isTrue,
      );

      // Should have hydration guidance
      expect(
        recommendations.any((r) => r.title.contains('Hydration')),
        isTrue,
      );

      // Should have activity recommendations
      expect(
        recommendations.any((r) => r.title.toLowerCase().contains('activity')),
        isTrue,
      );
    });

    test('Should provide UV-specific recommendations when UV index is high', () {
      final recommendations = SafetyRecommendationsEngine.generateRecommendations(
        riskScore: 60,
        profile: activeYoungPerson,
        weatherRisk: highRisk,
        currentWeather: testWeather,
      );

      final uvRecs = recommendations.where((r) => r.title.contains('UV Protection')).toList();
      
      expect(uvRecs, isNotEmpty);
      expect(
        uvRecs.first.actionItems.any((item) => item.contains('sunscreen')),
        isTrue,
      );
    });

    test('Should provide specific recommendations for very active individuals', () {
      final recommendations = SafetyRecommendationsEngine.generateRecommendations(
        riskScore: 70,
        profile: activeYoungPerson,
        weatherRisk: highRisk,
        currentWeather: testWeather,
      );

      final activityRecs = recommendations.where(
        (r) => r.title.contains('High-Intensity Activity'),
      ).toList();

      expect(activityRecs, isNotEmpty);
      expect(
        activityRecs.first.actionItems.any((item) => item.contains('exercise intensity')),
        isTrue,
      );
    });

    test('Should provide medical-specific recommendations for elderly with conditions', () {
      final recommendations = SafetyRecommendationsEngine.generateRecommendations(
        riskScore: 65,
        profile: elderlyWithConditions,
        weatherRisk: normalRisk,
        currentWeather: testWeather,
      );

      // Should have cardiovascular recommendations
      expect(
        recommendations.any((r) => r.title.contains('Cardiovascular')),
        isTrue,
      );

      // Should have respiratory recommendations
      expect(
        recommendations.any((r) => r.title.contains('Respiratory')),
        isTrue,
      );

      // Should mention emergency contacts for vulnerable individuals
      expect(
        recommendations.any((r) => 
          r.actionItems.any((item) => item.toLowerCase().contains('emergency'))),
        isTrue,
      );
    });

    test('Should provide time-appropriate recommendations during peak hours', () {
      final recommendations = SafetyRecommendationsEngine.generateRecommendations(
        riskScore: 55,
        profile: healthyAdult,
        weatherRisk: highRisk, // Set at 2 PM
        currentWeather: testWeather,
      );

      final timeRecs = recommendations.where(
        (r) => r.title.contains('Peak Heat Hours'),
      ).toList();

      expect(timeRecs, isNotEmpty);
      expect(
        timeRecs.first.actionItems.any((item) => item.contains('Minimize outdoor exposure')),
        isTrue,
      );
    });

    test('Should adjust recommendation priorities based on risk score', () {
      final lowRiskRecs = SafetyRecommendationsEngine.generateRecommendations(
        riskScore: 30,
        profile: healthyAdult,
        weatherRisk: normalRisk,
        currentWeather: testWeather,
      );

      final highRiskRecs = SafetyRecommendationsEngine.generateRecommendations(
        riskScore: 75,
        profile: healthyAdult,
        weatherRisk: highRisk,
        currentWeather: testWeather,
      );

      expect(
        lowRiskRecs.where((r) => r.priority == Priority.critical).isEmpty,
        isTrue,
      );

      expect(
        highRiskRecs.where((r) => r.priority == Priority.high).isNotEmpty,
        isTrue,
      );
    });
  });
}