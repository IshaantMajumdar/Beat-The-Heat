import 'package:shared_preferences/shared_preferences.dart';

enum TemperatureUnit {
  celsius,
  fahrenheit
}

class PreferencesService {
  static const String _temperatureUnitKey = 'temperature_unit';
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  TemperatureUnit get temperatureUnit {
    final String? unit = _prefs.getString(_temperatureUnitKey);
    return unit == 'fahrenheit' ? TemperatureUnit.fahrenheit : TemperatureUnit.celsius;
  }

  Future<void> setTemperatureUnit(TemperatureUnit unit) async {
    await _prefs.setString(_temperatureUnitKey, unit.name);
  }

  static String formatTemperature(double celsius, TemperatureUnit unit) {
    if (unit == TemperatureUnit.fahrenheit) {
      final f = (celsius * 9/5) + 32;
      return '${f.toStringAsFixed(1)}°F';
    }
    return '${celsius.toStringAsFixed(1)}°C';
  }
}