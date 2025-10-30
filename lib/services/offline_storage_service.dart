import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_data.dart';
import '../models/enhanced_weather_risk.dart';
import '../models/user_profile.dart';

class OfflineStorageService {
  static const String _lastWeatherKey = 'last_weather_data';
  static const String _lastRiskKey = 'last_risk_assessment';
  static const String _lastUpdateKey = 'last_update_timestamp';
  static const String _userProfileKey = 'user_profile';
  static const String _offlineModeKey = 'offline_mode_enabled';
  
  final SharedPreferences _prefs;
  bool _isOffline = false;

  OfflineStorageService(this._prefs) {
    _isOffline = _prefs.getBool(_offlineModeKey) ?? false;
  }

  /// Check if the app is in offline mode
  bool get isOffline => _isOffline;

  /// Set offline mode
  Future<void> setOfflineMode(bool enabled) async {
    _isOffline = enabled;
    await _prefs.setBool(_offlineModeKey, enabled);
  }

  /// Save weather data for offline use
  Future<void> saveWeatherData(WeatherData data) async {
    await _prefs.setString(_lastWeatherKey, jsonEncode(data.toJson()));
    await _prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get the last saved weather data
  WeatherData? getLastWeatherData() {
    final data = _prefs.getString(_lastWeatherKey);
    if (data == null) return null;
    
    try {
      return WeatherData.fromJson(jsonDecode(data));
    } catch (e) {
      return null;
    }
  }

  /// Save risk assessment for offline use
  Future<void> saveRiskAssessment(EnhancedWeatherRisk risk) async {
    await _prefs.setString(_lastRiskKey, jsonEncode({
      'temperature': risk.temperature,
      'humidity': risk.humidity,
      'uvIndex': risk.uvIndex,
      'timestamp': risk.timestamp.toIso8601String(),
      'heatIndex': risk.heatIndex,
      'baseRiskScore': risk.baseRiskScore,
    }));
  }

  /// Get the last saved risk assessment
  EnhancedWeatherRisk? getLastRiskAssessment() {
    final data = _prefs.getString(_lastRiskKey);
    if (data == null) return null;
    
    try {
      final json = jsonDecode(data);
      return EnhancedWeatherRisk(
        temperature: json['temperature'],
        humidity: json['humidity'],
        uvIndex: json['uvIndex'],
        timestamp: DateTime.parse(json['timestamp']),
        heatIndex: json['heatIndex'],
        baseRiskScore: json['baseRiskScore'],
      );
    } catch (e) {
      return null;
    }
  }

  /// Save user profile for offline use
  Future<void> saveUserProfile(UserProfile profile) async {
    await _prefs.setString(_userProfileKey, jsonEncode({
      'age': profile.age,
      'gender': profile.gender.toString(),
      'hasCardio': profile.hasCardio,
      'hasRespiratory': profile.hasRespiratory,
      'hasDiabetes': profile.hasDiabetes,
      'hasHypertension': profile.hasHypertension,
      'activityLevel': profile.activityLevel.toString(),
      'consented': profile.consented,
    }));
  }

  /// Get the saved user profile
  UserProfile? getUserProfile() {
    final data = _prefs.getString(_userProfileKey);
    if (data == null) return null;
    
    try {
      final json = jsonDecode(data);
      return UserProfile(
        age: json['age'],
        gender: Gender.values.firstWhere(
          (g) => g.toString() == json['gender'],
          orElse: () => Gender.other,
        ),
        hasCardio: json['hasCardio'],
        hasRespiratory: json['hasRespiratory'],
        hasDiabetes: json['hasDiabetes'],
        hasHypertension: json['hasHypertension'],
        activityLevel: ActivityLevel.values.firstWhere(
          (a) => a.toString() == json['activityLevel'],
          orElse: () => ActivityLevel.moderate,
        ),
        consented: json['consented'],
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if the cached data is still valid
  bool isCacheValid() {
    final lastUpdate = _prefs.getInt(_lastUpdateKey);
    if (lastUpdate == null) return false;

    final lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
    return DateTime.now().difference(lastUpdateTime) < const Duration(hours: 1);
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    await _prefs.remove(_lastWeatherKey);
    await _prefs.remove(_lastRiskKey);
    await _prefs.remove(_lastUpdateKey);
    // Don't clear user profile as it should persist
  }

  /// Check if we have all necessary data for offline functionality
  bool hasRequiredOfflineData() {
    return getLastWeatherData() != null && 
           getUserProfile() != null &&
           getLastRiskAssessment() != null;
  }
}