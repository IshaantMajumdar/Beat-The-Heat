import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_data.dart';
import '../services/preferences_service.dart';

class WeatherDisplay extends StatelessWidget {
  final WeatherData weatherData;
  final bool showDetails;

  const WeatherDisplay({
    super.key,
    required this.weatherData,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Image.network(
                  'https://openweathermap.org/img/wn/${weatherData.icon}@2x.png',
                  width: 50,
                  height: 50,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.cloud, size: 50);
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (weatherData.locationName != null) ...[
                        Text(
                          weatherData.locationName!,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                      ],
                      Consumer<PreferencesService>(
                        builder: (context, prefs, _) => Text(
                          PreferencesService.formatTemperature(
                            weatherData.temperature,
                            prefs.temperatureUnit,
                          ),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Text(
                        weatherData.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        _formatDateTime(weatherData.timestamp),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (showDetails) ...[
              const Divider(),
              Consumer<PreferencesService>(
                builder: (context, prefs, _) => _buildDetailRow(
                  context,
                  'Feels Like',
                  PreferencesService.formatTemperature(
                    weatherData.feelsLike,
                    prefs.temperatureUnit,
                  ),
                ),
              ),
              _buildDetailRow(
                context,
                'Humidity',
                '${weatherData.humidity.toStringAsFixed(0)}%',
              ),
              _buildDetailRow(
                context,
                'UV Index',
                '${weatherData.uvIndex.toStringAsFixed(1)} (${weatherData.uvRiskLevel})',
              ),
              _buildDetailRow(
                context,
                'Wind Speed',
                '${weatherData.windSpeed.toStringAsFixed(1)} m/s',
              ),
              Consumer<PreferencesService>(
                builder: (context, prefs, _) => _buildDetailRow(
                  context,
                  'Heat Index',
                  PreferencesService.formatTemperature(
                    weatherData.heatIndex,
                    prefs.temperatureUnit,
                  ),
                  isHighlight: true,
                ),
              ),
              _buildDetailRow(
                context,
                'Heat Risk',
                weatherData.heatRiskLevel,
                isHighlight: true,
                color: _getHeatRiskColor(weatherData.heatRiskLevel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isHighlight = false,
    Color? color,
  }) {
    final textStyle = isHighlight
        ? Theme.of(context).textTheme.bodyLarge
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyle),
          Text(
            value,
            style: textStyle?.copyWith(
              color: color,
              fontWeight: isHighlight ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }

  Color _getHeatRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'moderate':
        return Colors.yellow.shade700;
      case 'high':
        return Colors.orange;
      case 'very high':
        return Colors.red;
      case 'extreme':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dayStr;
    if (date == today) {
      dayStr = 'Today';
    } else if (date == tomorrow) {
      dayStr = 'Tomorrow';
    } else {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      dayStr = '${days[dateTime.weekday - 1]}, ${dateTime.day}/${dateTime.month}';
    }

    return dayStr;
  }
}