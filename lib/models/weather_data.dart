import 'package:flutter/foundation.dart';
import 'dart:math' show pow;

@immutable
class WeatherData {
  final double temperature; // in Celsius
  final double feelsLike; // in Celsius
  final double humidity; // percentage
  final double uvIndex;
  final double windSpeed; // in meters per second
  final DateTime timestamp;
  final String description;
  final String icon;
  final double latitude;
  final double longitude;
  final String? locationName;

  const WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.uvIndex,
    required this.windSpeed,
    required this.timestamp,
    required this.description,
    required this.icon,
    this.latitude = 0,
    this.longitude = 0,
    this.locationName,
  });

  /// Calculate the heat index using temperature and humidity
  double get heatIndex {
    // Convert to Fahrenheit for the calculation
    final tempF = (temperature * 9/5) + 32;
    
    // If the temperature is less than 80°F, return the actual temperature
    if (tempF < 80) {
      return temperature;
    }

    // Rothfusz regression formula
    double hi = -42.379 +
        2.04901523 * tempF +
        10.14333127 * humidity -
        0.22475541 * tempF * humidity -
        6.83783 * pow(10, -3) * tempF * tempF -
        5.481717 * pow(10, -2) * humidity * humidity +
        1.22874 * pow(10, -3) * tempF * tempF * humidity +
        8.5282 * pow(10, -4) * tempF * humidity * humidity -
        1.99 * pow(10, -6) * tempF * tempF * humidity * humidity;

    // Convert back to Celsius
    return (hi - 32) * 5/9;
  }

  /// Get the heat risk level based on the heat index
  String get heatRiskLevel {
    final hiC = heatIndex;
    
    if (hiC < 27) return 'Low';
    if (hiC < 32) return 'Moderate';
    if (hiC < 39) return 'High';
    if (hiC < 51) return 'Very High';
    return 'Extreme';
  }

  /// Get the UV risk level
  String get uvRiskLevel {
    if (uvIndex <= 2) return 'Low';
    if (uvIndex <= 5) return 'Moderate';
    if (uvIndex <= 7) return 'High';
    if (uvIndex <= 10) return 'Very High';
    return 'Extreme';
  }

  /// Create WeatherData from OpenWeatherMap API response
  factory WeatherData.fromOpenWeatherMap(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      humidity: (json['main']['humidity'] as num).toDouble(),
      uvIndex: (json['uvi'] as num?)?.toDouble() ?? 0,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      description: json['weather'][0]['description'] as String,
      icon: json['weather'][0]['icon'] as String,
    );
  }

  /// Create WeatherData from cache
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: json['temperature'] as double,
      feelsLike: json['feelsLike'] as double,
      humidity: json['humidity'] as double,
      uvIndex: json['uvIndex'] as double,
      windSpeed: json['windSpeed'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
      description: json['description'] as String,
      icon: json['icon'] as String,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'feelsLike': feelsLike,
      'humidity': humidity,
      'uvIndex': uvIndex,
      'windSpeed': windSpeed,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'icon': icon,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Create a copy of this WeatherData with some updated values
  WeatherData copyWith({
    double? temperature,
    double? feelsLike,
    double? humidity,
    double? uvIndex,
    double? windSpeed,
    DateTime? timestamp,
    String? description,
    String? icon,
  }) {
    return WeatherData(
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike ?? this.feelsLike,
      humidity: humidity ?? this.humidity,
      uvIndex: uvIndex ?? this.uvIndex,
      windSpeed: windSpeed ?? this.windSpeed,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
      icon: icon ?? this.icon,
    );
  }
}