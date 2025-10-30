import 'package:flutter/material.dart';
import '../utils/risk_calculator.dart';
import '../models/user_profile.dart';
import '../models/weather_data.dart';
import '../models/enhanced_weather_risk.dart';

class RealTimeRiskMonitor extends StatefulWidget {
  final UserProfile? profile;
  final WeatherData weatherData;

  const RealTimeRiskMonitor({
    super.key,
    required this.weatherData,
    this.profile,
  });

  @override
  State<RealTimeRiskMonitor> createState() => _RealTimeRiskMonitorState();
}

class _RealTimeRiskMonitorState extends State<RealTimeRiskMonitor> {
  int _currentRisk = 0;
  List<String> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _updateRiskAndRecommendations();
    // Listen to risk updates
    RiskCalculator.riskUpdates.listen((risk) {
      if (mounted) {
        setState(() {
          _currentRisk = risk;
          _updateRecommendations();
        });
      }
    });
  }

  @override
  void didUpdateWidget(RealTimeRiskMonitor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weatherData != widget.weatherData) {
      _updateRiskAndRecommendations();
    }
  }

  void _updateRiskAndRecommendations() {
    final enhancedRisk = EnhancedWeatherRisk.fromWeatherData(widget.weatherData);
    if (widget.profile != null) {
      _currentRisk = RiskCalculator.calculateEnhancedRisk(widget.weatherData, widget.profile!);
      _recommendations = RiskCalculator.getEnhancedRecommendations(
        _currentRisk,
        widget.profile!,
        enhancedRisk,
      );
    } else {
      _currentRisk = RiskCalculator.heatRiskScore(widget.weatherData.feelsLike);
      _recommendations = RiskCalculator.getEnhancedRecommendations(
        _currentRisk,
        UserProfile(
          age: 30,
          gender: Gender.other,
          hasCardio: false,
          hasRespiratory: false,
          hasDiabetes: false,
          hasHypertension: false,
          activityLevel: ActivityLevel.moderate,
          consented: false,
        ),
        enhancedRisk,
      );
    }
  }

  void _updateRecommendations() {
    final enhancedRisk = EnhancedWeatherRisk.fromWeatherData(widget.weatherData);
    _recommendations = RiskCalculator.getEnhancedRecommendations(
      _currentRisk,
      widget.profile ?? UserProfile(
        age: 30,
        gender: Gender.other,
        hasCardio: false,
        hasRespiratory: false,
        hasDiabetes: false,
        hasHypertension: false,
        activityLevel: ActivityLevel.moderate,
        consented: false,
      ),
      enhancedRisk,
    );
  }

  Color _getRiskColor(int risk) {
    if (risk < 20) return Colors.green.shade300;
    if (risk < 40) return Colors.yellow.shade300;
    if (risk < 70) return Colors.orange.shade300;
    return Colors.red.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getRiskColor(_currentRisk),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Risk Level: $_currentRisk/100',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  _currentRisk >= 70 ? Icons.warning : Icons.info_outline,
                  color: _currentRisk >= 70 ? Colors.red.shade700 : Colors.black87,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(RiskCalculator.getRiskDescription(_currentRisk)),
            const Divider(),
            const Text(
              'Recommendations:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...(_recommendations.map((rec) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(child: Text(rec)),
                ],
              ),
            ))),
          ],
        ),
      ),
    );
  }
}