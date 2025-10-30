import 'package:flutter/foundation.dart';
import 'user_profile.dart';

/// Manages all session-related data that exists only during app runtime
class SessionData extends ChangeNotifier {
  bool _hasUserConsent = false;
  UserProfile? _userProfile;
  Map<String, dynamic> _weatherData = {};
  
  // Consent Management
  bool get hasUserConsent => _hasUserConsent;
  void setUserConsent(bool consent) {
    _hasUserConsent = consent;
    notifyListeners();
  }

  // User Profile Management
  UserProfile? get userProfile => _userProfile;
  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
    notifyListeners();
  }

  // Weather Data Management
  Map<String, dynamic> get weatherData => _weatherData;
  void updateWeatherData(Map<String, dynamic> data) {
    _weatherData = data;
    notifyListeners();
  }

  // Clear all session data
  void clearSession() {
    _hasUserConsent = false;
    _userProfile = null;
    _weatherData = {};
    notifyListeners();
  }
}