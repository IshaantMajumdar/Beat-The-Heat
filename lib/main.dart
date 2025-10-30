import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/connectivity_service.dart';
import 'services/offline_storage_service.dart';
import 'services/weather_service.dart';
import 'services/preferences_service.dart';
import 'widgets/offline_status_indicators.dart';
import 'widgets/app_navigation.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final weatherService = WeatherService(prefs: prefs);
  final offlineStorage = OfflineStorageService(prefs);
  final connectivityService = ConnectivityService(
    offlineStorage: offlineStorage,
    weatherService: weatherService,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: connectivityService),
        Provider.value(value: weatherService),
        Provider.value(value: offlineStorage),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        Provider(create: (_) => PreferencesService(prefs)),
      ],
      child: const BeatTheHeatApp(),
    ),
  );
}

class BeatTheHeatApp extends StatelessWidget {
  const BeatTheHeatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Beat The Heat',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeProvider.themeMode,
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: OfflineStatusBanner(),
            ),
          ],
        );
      },
      home: const AppNavigation(),
    );
  }
}

// Compatibility alias for older tests
class MyApp extends BeatTheHeatApp {
  const MyApp({super.key});
}
