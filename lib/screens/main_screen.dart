import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/memory_storage_service.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../widgets/location_search_dialog.dart';
import '../widgets/consent_dialog.dart';
import '../widgets/real_time_risk_monitor.dart';
import '../widgets/location_indicator.dart';
import '../models/user_profile.dart';
import '../models/weather_data.dart';
import '../screens/weather_screen.dart';
import '../screens/health_questionnaire/health_questionnaire_screen.dart';
import '../utils/risk_calculator.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _memoryStorage = MemoryStorageService();
  late final WeatherService _weatherService;
  bool _initialized = false;
  WeatherData? _currentWeather;
  LocationAddress? _currentLocation;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _weatherService = WeatherService(prefs: prefs);
      RiskCalculator.initializeRealTimeUpdates(_weatherService);
      _checkConsent();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize services: $e';
      });
    }
  }

  void _checkConsent() {
    if (!_memoryStorage.hasUserConsent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showConsentDialog();
      });
    } else {
      setState(() {
        _initialized = true;
      });
      _refreshWeatherData();
    }
  }

  Future<void> _showConsentDialog() async {
    final UserProfile? profile = await showDialog<UserProfile>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const ConsentDialog();
      },
    );
    
    if (profile != null && profile.consented) {
      _memoryStorage.sessionData.setUserProfile(profile);
      _memoryStorage.updateUserConsent(true);
      setState(() {
        _initialized = true;
      });
      _refreshWeatherData();
    } else {
      _memoryStorage.updateUserConsent(false);
      setState(() {
        _initialized = false;
      });
    }
  }

  Future<void> _refreshWeatherData([LocationAddress? searchedLocation]) async {
    try {
      final location = searchedLocation ?? await LocationService().getCurrentLocation();
      if (location != null) {
        print('Fetching weather for location: ${location.address}'); // Debug print
        final weather = await _weatherService.getCurrentWeather(
          location.position.latitude,
          location.position.longitude,
        );
        if (weather != null) {
          print('Received weather data: temp=${weather.temperature}°C, humidity=${weather.humidity}%'); // Debug print
          setState(() {
            _currentLocation = location;
            _currentWeather = weather;
            _errorMessage = null;
          });
          
          // Show a Snackbar to indicate we're using a searched location
          if (searchedLocation != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Showing heat risk for ${location.address ?? 'selected location'}'),
                action: SnackBarAction(
                  label: 'Use Current Location',
                  onPressed: () {
                    _refreshWeatherData(); // This will fetch the current location again
                  },
                ),
              ),
            );
          }
        } else {
          print('Weather fetch returned null'); // Debug print
          setState(() {
            _errorMessage = 'Unable to fetch weather data';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Unable to get location';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    }
  }

  @override
  void dispose() {
    RiskCalculator.stopRealTimeUpdates();
    _weatherService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _refreshWeatherData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Heat Risk Assessment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _showConsentDialog,
            tooltip: 'Update Profile',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshWeatherData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshWeatherData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (_currentLocation != null)
              LocationIndicator(locationData: _currentLocation!),
            const SizedBox(height: 16),
            if (_currentWeather != null) ...[
              RealTimeRiskMonitor(
                weatherData: _currentWeather!,
                profile: _memoryStorage.sessionData.userProfile,
              ),
              const SizedBox(height: 16),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () async {
                        final location = await showDialog<LocationAddress?>(
                          context: context,
                          builder: (_) => const LocationSearchDialog(),
                        );
                        if (location != null) {
                          await _refreshWeatherData(location);
                        }
                      },
                      icon: const Icon(Icons.search),
                      label: const Text('Check Other Locations'),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WeatherScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.wb_sunny),
                      label: const Text('Detailed Weather'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push<UserProfile>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HealthQuestionnaireScreen(
                              initialProfile: _memoryStorage.sessionData.userProfile,
                            ),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            _memoryStorage.sessionData.setUserProfile(result);
                            _memoryStorage.updateUserConsent(true);
                          });
                          _refreshWeatherData();
                        }
                      },
                      icon: const Icon(Icons.medical_information),
                      label: const Text('Update Health Profile'),
                    ),
                  ],
                ),
              ),
            ),
            if (_memoryStorage.sessionData.userProfile != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Profile',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('Age: ${_memoryStorage.sessionData.userProfile!.age}'),
                      Text('Gender: ${_memoryStorage.sessionData.userProfile!.gender.name}'),
                      Text('Activity Level: ${_memoryStorage.sessionData.userProfile!.activityLevel.name}'),
                      if (_memoryStorage.sessionData.userProfile!.hasCardio ||
                          _memoryStorage.sessionData.userProfile!.hasRespiratory ||
                          _memoryStorage.sessionData.userProfile!.hasDiabetes ||
                          _memoryStorage.sessionData.userProfile!.hasHypertension) ...[
                        const SizedBox(height: 8),
                        const Text('Medical Conditions:'),
                        if (_memoryStorage.sessionData.userProfile!.hasCardio)
                          const Text('• Cardiovascular condition'),
                        if (_memoryStorage.sessionData.userProfile!.hasRespiratory)
                          const Text('• Respiratory condition'),
                        if (_memoryStorage.sessionData.userProfile!.hasDiabetes)
                          const Text('• Diabetes'),
                        if (_memoryStorage.sessionData.userProfile!.hasHypertension)
                          const Text('• Hypertension'),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}