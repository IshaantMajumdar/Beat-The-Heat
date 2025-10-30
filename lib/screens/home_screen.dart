import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/connectivity_service.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../widgets/location_indicator.dart';
import '../widgets/location_search_dialog.dart';
import '../services/memory_storage_service.dart';
import '../utils/risk_calculator.dart';
import '../models/user_profile.dart';
import '../widgets/consent_dialog.dart';
import '../widgets/offline_status_indicators.dart';
import '../widgets/loading_state.dart';
import '../widgets/skeleton_loading.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/responsive_container.dart';
import '../utils/responsive_utils.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String status = 'Idle';
  double? tempC;
  double? humidity;
  int? riskScore;
  UserProfile? profile;
  LocationAddress? locationData;
  late final WeatherService ws;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _initWeatherService();
  }

  Future<void> _initWeatherService() async {
    final prefs = await SharedPreferences.getInstance();
    ws = WeatherService(prefs: prefs);
    _init();
  }

  Future<void> _openLocationSearch() async {
    final location = await showDialog<LocationAddress?>(
      context: context,
      builder: (_) => const LocationSearchDialog(),
    );

    if (location != null) {
      setState(() {
        locationData = location;
        status = 'Fetching weather';
      });
      await _updateWeatherData(location);
      
      // Show a Snackbar to indicate we're using a searched location
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Showing heat risk for ${location.address ?? 'selected location'}'),
          action: SnackBarAction(
            label: 'Use Current Location',
            onPressed: () {
              _init(); // This will fetch the current location again
            },
          ),
        ),
      );
    }
  }

  Future<void> _updateWeatherData(LocationAddress location) async {
    try {
      final weather = await ws.getCurrentWeather(
        location.position.latitude,
        location.position.longitude
      );
      if (weather == null) {
        setState(() => status = 'Weather fetch failed');
        return;
      }
      tempC = weather.temperature;
      humidity = weather.humidity;

      final hi = RiskCalculator.heatIndexC(tempC ?? 0, humidity ?? 0);
      final memoryStorage = MemoryStorageService();
      profile = memoryStorage.sessionData.userProfile;

      setState(() {
        if (profile != null && memoryStorage.hasUserConsent) {
          riskScore = RiskCalculator.calculateFinalRisk(hi, profile!);
        } else {
          riskScore = RiskCalculator.heatRiskScore(hi);
        }
        status = 'Ready';
      });
    } catch (e) {
      setState(() => status = 'Error: ${e.toString()}');
    }
  }

  Future<void> _init() async {
    setState(() => status = 'Getting location');
    try {
      final location = await _locationService.getCurrentLocation();
      if (location == null) {
        setState(() => status = 'Location permission denied');
        return;
      }
      setState(() {
        locationData = location;
        status = 'Fetching weather';
      });
      await _updateWeatherData(location);
    } catch (e) {
      setState(() => status = 'Error: ${e.toString()}');
    }
  }

  Future<void> _openConsent() async {
    final res = await showDialog<UserProfile?>(
      context: context, 
      builder: (_) => ConsentDialog(initial: profile)
    );
    if (res != null) {
      final memoryStorage = MemoryStorageService();
      memoryStorage.sessionData.setUserProfile(res);
      memoryStorage.updateUserConsent(res.consented);
      setState(() => profile = res);
      await _init();
    }
  }

  Color _colorForRisk(int risk) {
    if (risk >= 80) return Colors.red[100]!;
    if (risk >= 60) return Colors.orange[100]!;
    if (risk >= 40) return Colors.yellow[100]!;
    return Colors.green[100]!;
  }

  Widget _buildWeatherSection() {
    return Card(
      child: Padding(
        padding: ResponsiveUtils.getAdaptivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Weather',
              style: TextStyle(
                fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 20),
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 24),
            if (locationData != null) 
              LocationIndicator(locationData: locationData!),
            if (tempC != null && humidity != null) ...[
              SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),
              Text(
                'Temperature: ${tempC!.toStringAsFixed(1)} °C',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 16),
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              SizedBox(height: ResponsiveUtils.isMobile(context) ? 4 : 8),
              Text(
                'Humidity: ${humidity!.toStringAsFixed(0)} %',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 16),
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    final textStyle = TextStyle(
      fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 14),
      color: Theme.of(context).textTheme.bodyMedium?.color,
    );
    
    return Card(
      child: Padding(
        padding: ResponsiveUtils.getAdaptivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: TextStyle(
                fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 20),
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            SizedBox(height: ResponsiveUtils.isMobile(context) ? 8 : 12),
            Text('Age: ${profile!.age}', style: textStyle),
            Text('Gender: ${profile!.gender.name}', style: textStyle),
            Text('Activity Level: ${profile!.activityLevel.name}', style: textStyle),
            if (profile!.hasCardio || profile!.hasRespiratory || 
                profile!.hasDiabetes || profile!.hasHypertension) ...[
              SizedBox(height: ResponsiveUtils.isMobile(context) ? 8 : 12),
              Text('Medical Conditions:', style: textStyle),
              if (profile!.hasCardio)
                Text('• Cardiovascular condition', style: textStyle),
              if (profile!.hasRespiratory)
                Text('• Respiratory condition', style: textStyle),
              if (profile!.hasDiabetes)
                Text('• Diabetes', style: textStyle),
              if (profile!.hasHypertension)
                Text('• Hypertension', style: textStyle),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRiskSection() {
    final textStyle = TextStyle(
      fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 14),
      color: Theme.of(context).textTheme.bodyMedium?.color,
    );
    
    return OfflineIndicator(
      child: Card(
        color: _colorForRisk(riskScore!),
        child: Padding(
          padding: ResponsiveUtils.getAdaptivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Heat Risk: $riskScore / 100',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveUtils.isMobile(context) ? 6 : 8),
              Text(
                RiskCalculator.getRiskDescription(riskScore!),
                style: textStyle,
              ),
              SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),
              Text(
                'Recommendations:',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveUtils.isMobile(context) ? 4 : 6),
              ...RiskCalculator.getRecommendations(
                riskScore!,
                profile ?? UserProfile(
                  age: 30,
                  gender: Gender.other,
                  hasCardio: false,
                  hasRespiratory: false,
                  hasDiabetes: false,
                  hasHypertension: false,
                  activityLevel: ActivityLevel.moderate,
                  consented: false,
                ),
              ).map((rec) => Padding(
                padding: EdgeInsets.only(
                  top: ResponsiveUtils.isMobile(context) ? 4 : 6
                ),
                child: Text('• $rec', style: textStyle),
              )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Beat The Heat',
          style: TextStyle(
            fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 20),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openLocationSearch,
            tooltip: 'Search Location',
            icon: const Icon(Icons.search_outlined),
          ),
          IconButton(
            onPressed: _openConsent,
            tooltip: 'Profile',
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: FilledButton.icon(
                onPressed: _openLocationSearch,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.search_outlined),
                label: const Text(
                  'Check Heat Risk at Another Location',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            Expanded(
              child: Consumer<ConnectivityService>(
                builder: (context, connectivityService, child) {
                  if (status == 'Getting location') {
                    return const LoadingState(
                      message: 'Getting your location...',
                    );
                  }

                  if (status == 'Fetching weather') {
                    return ResponsiveContainer(
                      child: ListView(
                        children: const [
                          WeatherSkeletonLoading(),
                          SizedBox(height: 16),
                          WeatherSkeletonLoading(),
                        ],
                      ),
                    );
                  }

                  if (status.startsWith('Error')) {
                    return LoadingState(
                      message: status,
                      isError: true,
                      onRetry: _init,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _init,
                    child: ResponsiveLayout(
                      mobile: ListView(
                        padding: ResponsiveUtils.getAdaptivePadding(context),
                        children: _buildContent(context, connectivityService),
                      ),
                      tablet: ListView(
                        padding: ResponsiveUtils.getAdaptivePadding(context),
                        children: _buildContent(context, connectivityService),
                      ),
                      desktop: Center(
                        child: SizedBox(
                          width: ResponsiveUtils.getAdaptiveWidth(context),
                          child: ListView(
                            padding: ResponsiveUtils.getAdaptivePadding(context),
                            children: _buildContent(context, connectivityService),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context, ConnectivityService connectivityService) {
    return [

      if (!connectivityService.isOffline)
        StreamBuilder<bool>(
          stream: connectivityService.isSyncing,
          builder: (context, snapshot) {
            if (snapshot.data == true) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SyncStatusIndicator(
                  isSyncing: Stream.value(true),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),

      _buildWeatherSection(),
      const SizedBox(height: 16),

      if (profile != null) ...[
        _buildProfileSection(),
        const SizedBox(height: 16),
      ],

      if (riskScore != null)
        _buildRiskSection()
      else
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No risk assessment available yet'),
          ),
        ),

      const SizedBox(height: 16),
      ElevatedButton.icon(
        onPressed: connectivityService.isOffline ? null : _init,
        icon: const Icon(Icons.refresh),
        label: Text(
          connectivityService.isOffline ? 'Offline' : 'Refresh Data'
        ),
      ),
    ];
  }
}