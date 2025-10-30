import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'offline_storage_service.dart';
import 'weather_service.dart';

class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity;
  final OfflineStorageService _offlineStorage;
  final WeatherService _weatherService;
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityService({
    required OfflineStorageService offlineStorage,
    required WeatherService weatherService,
    Connectivity? connectivity,
  }) : _offlineStorage = offlineStorage,
       _weatherService = weatherService,
       _connectivity = connectivity ?? Connectivity() {
    _init();
  }

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  // Initialize the connectivity service
  Future<void> _init() async {
    try {
      // Check initial connectivity
      final results = await _connectivity.checkConnectivity();
      _checkConnectivity(results.first);

      // Listen for connectivity changes
      _subscription = _connectivity.onConnectivityChanged.listen(
        (results) => _checkConnectivity(results.first),
        onError: (error) {
          debugPrint('Connectivity monitoring error: $error');
          // Assume offline if we can't check connectivity
          _checkConnectivity(ConnectivityResult.none);
        },
      );
    } catch (e) {
      debugPrint('Error initializing connectivity service: $e');
      // Assume offline if initialization fails
      _checkConnectivity(ConnectivityResult.none);
    }
  }

  // Helper method to handle sync status
  final StreamController<bool> _syncingController = StreamController<bool>.broadcast();
  Stream<bool> get isSyncing => _syncingController.stream;

  void _checkConnectivity(ConnectivityResult result) async {
    final wasOnline = _isOnline;
    // Consider online if any connection type is available
    _isOnline = result != ConnectivityResult.none;

    // Only proceed if there's an actual change in connectivity status
    if (wasOnline != _isOnline) {
      // Update offline storage mode
      await _offlineStorage.setOfflineMode(!_isOnline);

      // If we just came back online, trigger a sync
      if (!wasOnline && _isOnline) {
        await syncOfflineData();
      }

      notifyListeners();
    }
  }

  /// Synchronize offline data when coming back online
  Future<void> syncOfflineData() async {
    if (!_isOnline) return;

    try {
      _syncingController.add(true);
      // Get the last known location from offline storage
      final lastWeather = _offlineStorage.getLastWeatherData();
      if (lastWeather != null) {
        // Fetch fresh weather data for the last known location
        final freshWeather = await _weatherService.getCurrentWeather(
          lastWeather.latitude,
          lastWeather.longitude,
        );
        
        if (freshWeather != null) {
          // Update offline storage with fresh data
          await _offlineStorage.saveWeatherData(freshWeather);
        }
      }
    } catch (e) {
      debugPrint('Error syncing offline data: $e');
    } finally {
      _syncingController.add(false);
    }
  }

  /// Manually check connectivity and update status
  Future<void> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _checkConnectivity(result.first);
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      _checkConnectivity(ConnectivityResult.none);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _syncingController.close();
    super.dispose();
  }
}