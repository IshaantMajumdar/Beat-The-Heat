import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beat_the_heat/services/offline_storage_service.dart';
import 'package:beat_the_heat/models/weather_data.dart';
import 'package:beat_the_heat/models/enhanced_weather_risk.dart';
import 'package:beat_the_heat/models/user_profile.dart';

void main() {
  late SharedPreferences preferences;
  late OfflineStorageService offlineStorage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    offlineStorage = OfflineStorageService(preferences);
  });

  group('OfflineStorageService Tests', () {
    test('Should save and retrieve offline mode state', () async {
      expect(offlineStorage.isOffline, false);
      
      await offlineStorage.setOfflineMode(true);
      expect(offlineStorage.isOffline, true);
      
      // Create new instance to verify persistence
      final newStorage = OfflineStorageService(preferences);
      expect(newStorage.isOffline, true);
    });

    test('Should save and retrieve weather data', () async {
      final testWeather = WeatherData(
        temperature: 25.0,
        feelsLike: 27.0,
        humidity: 60.0,
        uvIndex: 5.0,
        windSpeed: 10.0,
        timestamp: DateTime.now(),
        description: 'Sunny',
        icon: '01d',
      );

      await offlineStorage.saveWeatherData(testWeather);
      final retrieved = offlineStorage.getLastWeatherData();

      expect(retrieved, isNotNull);
      expect(retrieved!.temperature, testWeather.temperature);
      expect(retrieved.humidity, testWeather.humidity);
      expect(retrieved.uvIndex, testWeather.uvIndex);
    });

    test('Should save and retrieve risk assessment', () async {
      final testRisk = EnhancedWeatherRisk(
        temperature: 30.0,
        humidity: 65.0,
        uvIndex: 7.0,
        timestamp: DateTime.now(),
        heatIndex: 32.0,
        baseRiskScore: 75,
      );

      await offlineStorage.saveRiskAssessment(testRisk);
      final retrieved = offlineStorage.getLastRiskAssessment();

      expect(retrieved, isNotNull);
      expect(retrieved!.temperature, testRisk.temperature);
      expect(retrieved.humidity, testRisk.humidity);
      expect(retrieved.uvIndex, testRisk.uvIndex);
      expect(retrieved.baseRiskScore, testRisk.baseRiskScore);
    });

    test('Should save and retrieve user profile', () async {
      final testProfile = UserProfile(
        age: 35,
        gender: Gender.female,
        hasCardio: false,
        hasRespiratory: true,
        hasDiabetes: false,
        hasHypertension: true,
        activityLevel: ActivityLevel.moderate,
        consented: true,
      );

      await offlineStorage.saveUserProfile(testProfile);
      final retrieved = offlineStorage.getUserProfile();

      expect(retrieved, isNotNull);
      expect(retrieved!.age, testProfile.age);
      expect(retrieved.gender, testProfile.gender);
      expect(retrieved.hasRespiratory, testProfile.hasRespiratory);
      expect(retrieved.hasHypertension, testProfile.hasHypertension);
      expect(retrieved.activityLevel, testProfile.activityLevel);
    });

    test('Should validate cache correctly', () async {
      expect(offlineStorage.isCacheValid(), false);

      final testWeather = WeatherData(
        temperature: 25.0,
        feelsLike: 27.0,
        humidity: 60.0,
        uvIndex: 5.0,
        windSpeed: 10.0,
        timestamp: DateTime.now(),
        description: 'Sunny',
        icon: '01d',
      );

      await offlineStorage.saveWeatherData(testWeather);
      expect(offlineStorage.isCacheValid(), true);
    });

    test('Should clear cache correctly', () async {
      // Save some test data
      final testWeather = WeatherData(
        temperature: 25.0,
        feelsLike: 27.0,
        humidity: 60.0,
        uvIndex: 5.0,
        windSpeed: 10.0,
        timestamp: DateTime.now(),
        description: 'Sunny',
        icon: '01d',
      );

      final testProfile = UserProfile(
        age: 35,
        gender: Gender.female,
        hasCardio: false,
        hasRespiratory: true,
        hasDiabetes: false,
        hasHypertension: true,
        activityLevel: ActivityLevel.moderate,
        consented: true,
      );

      await offlineStorage.saveWeatherData(testWeather);
      await offlineStorage.saveUserProfile(testProfile);

      // Clear cache
      await offlineStorage.clearCache();

      // Weather data should be cleared
      expect(offlineStorage.getLastWeatherData(), isNull);
      expect(offlineStorage.isCacheValid(), false);

      // User profile should persist
      expect(offlineStorage.getUserProfile(), isNotNull);
    });

    test('Should check required offline data correctly', () async {
      expect(offlineStorage.hasRequiredOfflineData(), false);

      // Add weather data
      final testWeather = WeatherData(
        temperature: 25.0,
        feelsLike: 27.0,
        humidity: 60.0,
        uvIndex: 5.0,
        windSpeed: 10.0,
        timestamp: DateTime.now(),
        description: 'Sunny',
        icon: '01d',
      );
      await offlineStorage.saveWeatherData(testWeather);
      expect(offlineStorage.hasRequiredOfflineData(), false);

      // Add user profile
      final testProfile = UserProfile(
        age: 35,
        gender: Gender.female,
        hasCardio: false,
        hasRespiratory: true,
        hasDiabetes: false,
        hasHypertension: true,
        activityLevel: ActivityLevel.moderate,
        consented: true,
      );
      await offlineStorage.saveUserProfile(testProfile);
      expect(offlineStorage.hasRequiredOfflineData(), false);

      // Add risk assessment
      final testRisk = EnhancedWeatherRisk(
        temperature: 30.0,
        humidity: 65.0,
        uvIndex: 7.0,
        timestamp: DateTime.now(),
        heatIndex: 32.0,
        baseRiskScore: 75,
      );
      await offlineStorage.saveRiskAssessment(testRisk);
      
      // Now we should have all required data
      expect(offlineStorage.hasRequiredOfflineData(), true);
    });
  });
}