import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_data.dart';
import '../utils/risk_calculator.dart';
import 'offline_storage_service.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1';
  static const String _geoUrl = 'https://geocoding-api.open-meteo.com/v1';
  final SharedPreferences _prefs;
  final http.Client _client;
  late final OfflineStorageService _offlineStorage;

  WeatherService({
    required SharedPreferences prefs,
    http.Client? client,
  }) : _prefs = prefs,
       _client = client ?? http.Client() {
    _offlineStorage = OfflineStorageService(_prefs);
  }

  /// Get location name from coordinates
  Future<String?> _getLocationName(double latitude, double longitude) async {
    try {
      final url = Uri.parse(
        '$_geoUrl/reverse?latitude=$latitude&longitude=$longitude'
      );
      
      final response = await _client.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;
      
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>?;
      
      if (results == null || results.isEmpty) return null;
      
      final location = results.first as Map<String, dynamic>;
      final city = location['city'] ?? location['name'];
      final admin = location['admin1'] ?? location['country'];
      
      if (city != null) {
        return admin != null ? '$city, $admin' : city;
      }
      return admin;
    } catch (_) {
      return null;
    }
  }

  /// Get current weather data
  Future<WeatherData?> getCurrentWeather(double latitude, double longitude) async {
    // If we're in offline mode, return the last known weather data
    if (_offlineStorage.isOffline) {
      return _offlineStorage.getLastWeatherData();
    }

    // Check cache first
    final cacheKey = _getCacheKey(latitude, longitude);
    final cachedData = _prefs.getString(cacheKey);
    
    if (cachedData != null) {
      final cached = WeatherData.fromJson(jsonDecode(cachedData));
      // Return cached data if it's less than 30 minutes old
      if (DateTime.now().difference(cached.timestamp) < const Duration(minutes: 30)) {
        return cached;
      }
    }

    try {
      final url = Uri.parse(
        '$_baseUrl/forecast?latitude=$latitude&longitude=$longitude&current_weather=true'
        '&hourly=temperature_2m,relativehumidity_2m,windspeed_10m,weathercode,uv_index'
        '&timezone=auto'
      );
      
      final res = await _client.get(url).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      
      final data = json.decode(res.body) as Map<String, dynamic>;
      final current = data['current_weather'] as Map<String, dynamic>?;
      final hourly = data['hourly'] as Map<String, dynamic>?;
      
      if (current == null || hourly == null) return null;

      // Get the current hour's index
      final now = DateTime.now();
      final times = List<String>.from(hourly['time']);
      final currentIndex = times.indexWhere((time) {
        final dateTime = DateTime.parse(time);
        return dateTime.year == now.year && 
               dateTime.month == now.month && 
               dateTime.day == now.day &&
               dateTime.hour == now.hour;
      });

      if (currentIndex == -1) return null;

      // Get location name
      final locationName = await _getLocationName(latitude, longitude);

      // Build weather data from current and hourly data
      final temp = (current['temperature'] as num).toDouble();
      final humidity = (hourly['relativehumidity_2m'][currentIndex] as num).toDouble();
      
      // Calculate heat index for feels-like temperature
      final feelsLike = RiskCalculator.heatIndexC(temp, humidity);
      
      final weatherData = WeatherData(
        temperature: temp,
        feelsLike: feelsLike, // Using calculated heat index
        humidity: humidity,
        uvIndex: (hourly['uv_index'][currentIndex] as num).toDouble(),
        windSpeed: (current['windspeed'] as num).toDouble(),
        timestamp: DateTime.now(),
        description: _getWeatherDescription(current['weathercode'] as int),
        icon: _getWeatherIcon(current['weathercode'] as int),
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
      );

      // Cache the result both in shared preferences and offline storage
      await _prefs.setString(cacheKey, jsonEncode(weatherData.toJson()));
      await _offlineStorage.saveWeatherData(weatherData);
      return weatherData;

    } catch (_) {
      return null;
    }
  }

  /// Get forecast for the next few days
  Future<List<WeatherData>> getForecast(
    double latitude,
    double longitude, {
    int days = 7,  // Increased to 7 days
  }) async {
    // If we're in offline mode, return at least the current weather
    if (_offlineStorage.isOffline) {
      final lastWeather = _offlineStorage.getLastWeatherData();
      return lastWeather != null ? [lastWeather] : [];
    }
    try {
      final url = Uri.parse(
        '$_baseUrl/forecast?latitude=$latitude&longitude=$longitude'
        '&daily=weathercode,temperature_2m_max,temperature_2m_min,windspeed_10m_max,uv_index_max'
        '&timezone=auto'
      );
      
      final response = await _client.get(url);
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final daily = data['daily'] as Map<String, dynamic>;
      final forecasts = <WeatherData>[];

      for (var i = 0; i < days && i < (daily['time'] as List).length; i++) {
        forecasts.add(WeatherData(
          temperature: (daily['temperature_2m_max'][i] as num).toDouble(),
          feelsLike: (daily['temperature_2m_max'][i] as num).toDouble(),
          humidity: 50, // Daily forecast doesn't include humidity
          uvIndex: (daily['uv_index_max'][i] as num).toDouble(),
          windSpeed: (daily['windspeed_10m_max'][i] as num).toDouble(),
          timestamp: DateTime.parse(daily['time'][i]),
          description: _getWeatherDescription(daily['weathercode'][i] as int),
          icon: _getWeatherIcon(daily['weathercode'][i] as int),
        ));
      }

      return forecasts;
    } catch (_) {
      return [];
    }
  }

  /// Get cache key for a location
  String _getCacheKey(double latitude, double longitude) {
    return 'weather_${latitude.toStringAsFixed(4)}_${longitude.toStringAsFixed(4)}';
  }

  /// Convert WMO weather code to description
  String _getWeatherDescription(int code) {
    switch (code) {
      case 0: return 'Clear sky';
      case 1: return 'Mainly clear';
      case 2: return 'Partly cloudy';
      case 3: return 'Overcast';
      case 45: return 'Foggy';
      case 48: return 'Depositing rime fog';
      case 51: return 'Light drizzle';
      case 53: return 'Moderate drizzle';
      case 55: return 'Dense drizzle';
      case 61: return 'Slight rain';
      case 63: return 'Moderate rain';
      case 65: return 'Heavy rain';
      case 71: return 'Slight snow';
      case 73: return 'Moderate snow';
      case 75: return 'Heavy snow';
      case 77: return 'Snow grains';
      case 80: return 'Slight rain showers';
      case 81: return 'Moderate rain showers';
      case 82: return 'Violent rain showers';
      case 85: return 'Slight snow showers';
      case 86: return 'Heavy snow showers';
      case 95: return 'Thunderstorm';
      case 96: return 'Thunderstorm with slight hail';
      case 99: return 'Thunderstorm with heavy hail';
      default: return 'Unknown';
    }
  }

  /// Convert WMO weather code to icon name
  String _getWeatherIcon(int code) {
    if (code == 0) return '01d'; // clear sky
    if (code == 1) return '02d'; // mainly clear
    if (code == 2) return '03d'; // partly cloudy
    if (code == 3) return '04d'; // overcast
    if (code <= 48) return '50d'; // fog
    if (code <= 55) return '09d'; // drizzle
    if (code <= 65) return '10d'; // rain
    if (code <= 77) return '13d'; // snow
    if (code <= 82) return '09d'; // rain showers
    if (code <= 86) return '13d'; // snow showers
    return '11d'; // thunderstorm
  }

  /// Clean up resources
  void dispose() {
    _client.close();
  }
}
