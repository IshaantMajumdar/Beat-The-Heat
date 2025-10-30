import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../services/preferences_service.dart';
import '../models/weather_data.dart';
import '../widgets/weather_display.dart';
import '../widgets/loading_state.dart';
import '../widgets/location_search_dialog.dart';
import '../widgets/location_indicator.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final LocationService _locationService = LocationService();
  late final WeatherService _weatherService;
  WeatherData? _currentWeather;
  List<WeatherData> _forecast = [];
  LocationAddress? _currentLocation;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _weatherService = WeatherService(prefs: prefs);
      await _refreshWeather();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize weather services';
        _isLoading = false;
      });
    }
  }

  Future<void> _openLocationSearch() async {
    final location = await showDialog<LocationAddress?>(
      context: context,
      builder: (_) => const LocationSearchDialog(),
    );

    if (location != null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentLocation = location;
      });

      try {
        final weatherData = await _weatherService.getCurrentWeather(
          location.position.latitude,
          location.position.longitude,
        );

        if (weatherData == null) {
          setState(() {
            _errorMessage = 'Unable to fetch weather data.';
            _isLoading = false;
          });
          return;
        }

        final forecast = await _weatherService.getForecast(
          location.position.latitude,
          location.position.longitude,
        );

        setState(() {
          _currentWeather = weatherData;
          _forecast = forecast;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final location = await _locationService.getCurrentLocation();
      if (location == null) {
        setState(() {
          _errorMessage = 'Unable to get location. Please check your settings.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _currentLocation = location;
      });

      final weatherData = await _weatherService.getCurrentWeather(
        location.position.latitude,
        location.position.longitude,
      );

      if (weatherData == null) {
        setState(() {
          _errorMessage = 'Unable to fetch weather data.';
          _isLoading = false;
        });
        return;
      }

      final forecast = await _weatherService.getForecast(
        location.position.latitude,
        location.position.longitude,
      );

      setState(() {
        _currentWeather = weatherData;
        _forecast = forecast;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        actions: [
          // Temperature unit toggle
          Consumer<PreferencesService>(
            builder: (context, prefs, _) => IconButton(
              icon: Icon(
                prefs.temperatureUnit == TemperatureUnit.celsius 
                  ? Icons.thermostat
                  : Icons.thermostat_auto
              ),
              tooltip: 'Toggle temperature unit',
              onPressed: () {
                final newUnit = prefs.temperatureUnit == TemperatureUnit.celsius
                    ? TemperatureUnit.fahrenheit
                    : TemperatureUnit.celsius;
                prefs.setTemperatureUnit(newUnit);
              },
            ),
          ),
          // Location search button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: FilledButton.tonal(
              onPressed: _openLocationSearch,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search),
                  SizedBox(width: 8),
                  Text('Search Location'),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshWeather,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingState(
        message: 'Fetching weather information...',
      );
    }

    if (_errorMessage != null) {
      return LoadingState(
        message: _errorMessage!,
        isError: true,
        onRetry: _refreshWeather,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshWeather,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_currentWeather != null) ...[
            LocationIndicator(locationData: _currentLocation!),
            const SizedBox(height: 16),
            const Text(
              'Current Weather',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            WeatherDisplay(weatherData: _currentWeather!),
          ],
          if (_forecast.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Forecast',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._forecast.map((weather) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: WeatherDisplay(
                weatherData: weather,
                showDetails: false,
              ),
            )),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _weatherService.dispose();
    super.dispose();
  }
}