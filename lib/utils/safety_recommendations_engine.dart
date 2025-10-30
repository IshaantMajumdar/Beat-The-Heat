import '../models/user_profile.dart';
import '../models/enhanced_weather_risk.dart';
import '../models/weather_data.dart';

class SafetyRecommendation {
  final String title;
  final String description;
  final Priority priority;
  final List<String> actionItems;
  final bool isEmergency;

  SafetyRecommendation({
    required this.title,
    required this.description,
    required this.priority,
    required this.actionItems,
    this.isEmergency = false,
  });
}

enum Priority {
  low,
  moderate,
  high,
  critical
}

class SafetyRecommendationsEngine {
  static List<SafetyRecommendation> generateRecommendations({
    required int riskScore,
    required UserProfile profile,
    required EnhancedWeatherRisk weatherRisk,
    required WeatherData currentWeather,
  }) {
    List<SafetyRecommendation> recommendations = [];
    
    // Add immediate emergency recommendations if needed
    _addEmergencyRecommendations(
      recommendations,
      riskScore,
      profile,
      weatherRisk,
    );

    // Add general safety recommendations
    _addGeneralSafetyRecommendations(
      recommendations,
      riskScore,
      weatherRisk,
    );

    // Add health condition specific recommendations
    _addHealthRecommendations(
      recommendations,
      profile,
      riskScore,
    );

    // Add activity-specific recommendations
    _addActivityRecommendations(
      recommendations,
      profile,
      weatherRisk,
      riskScore,
    );

    // Add time-specific recommendations
    _addTimeBasedRecommendations(
      recommendations,
      weatherRisk,
      riskScore,
    );

    // Add outdoor activity recommendations based on weather conditions
    _addWeatherBasedOutdoorRecommendations(
      recommendations,
      weatherRisk,
      currentWeather,
      riskScore,
    );

    return recommendations;
  }

  static void _addWeatherBasedOutdoorRecommendations(
    List<SafetyRecommendation> recommendations,
    EnhancedWeatherRisk weatherRisk,
    WeatherData currentWeather,
    int riskScore,
  ) {
    // Define comfortable temperature range (in Celsius)
    final tempC = currentWeather.temperature;
    final humidity = currentWeather.humidity;
    final hour = weatherRisk.timestamp.hour;
    final uvIndex = weatherRisk.uvIndex;

    // Check for ideal conditions
    bool isComfortableTemp = tempC >= 18 && tempC <= 27;
    bool isModerateHumidity = humidity >= 30 && humidity <= 60;
    bool isGoodTime = (hour >= 6 && hour <= 10) || (hour >= 16 && hour <= 20);
    bool isLowUV = uvIndex <= 5;

    if (riskScore <= 30 && isComfortableTemp && isModerateHumidity) {
      recommendations.add(SafetyRecommendation(
        title: '✨ Favorable Outdoor Conditions',
        description: 'Current weather is suitable for outdoor activities',
        priority: Priority.low,
        actionItems: [
          'Temperature is in a comfortable range',
          'Humidity levels are moderate',
          if (isGoodTime) 'Current time is ideal for outdoor activities',
          if (isLowUV) 'UV levels are safe for outdoor exposure',
          'Still remember to stay hydrated and use sun protection',
          if (!isLowUV) 'Consider UV protection as UV index is ${uvIndex.toStringAsFixed(1)}',
        ],
      ));
    } else if (riskScore <= 50) {
      String timeAdvice = '';
      if (hour < 6) {
        timeAdvice = 'Consider waiting until after 6 AM for outdoor activities';
      } else if (hour > 20) {
        timeAdvice = 'Early morning (after 6 AM) will be better for outdoor activities';
      } else if (hour >= 10 && hour <= 16) {
        timeAdvice = 'Activities will be more comfortable after 4 PM';
      }

      recommendations.add(SafetyRecommendation(
        title: '🌤️ Moderate Outdoor Conditions',
        description: 'Weather allows for outdoor activities with some precautions',
        priority: Priority.low,
        actionItems: [
          if (!isComfortableTemp) 
            'Temperature is ${tempC < 18 ? 'cool' : 'warm'} - dress appropriately',
          if (!isModerateHumidity)
            'Humidity is ${humidity < 30 ? 'low' : 'high'} - adjust activity intensity',
          timeAdvice,
          'Take regular breaks as needed',
          'Stay hydrated',
          if (uvIndex > 5) 'Use sun protection - UV index is ${uvIndex.toStringAsFixed(1)}',
        ],
      ));
    }
  }

  static void _addEmergencyRecommendations(
    List<SafetyRecommendation> recommendations,
    int riskScore,
    UserProfile profile,
    EnhancedWeatherRisk weatherRisk,
  ) {
    if (riskScore >= 80) {
      recommendations.add(SafetyRecommendation(
        title: '⚠️ EXTREME HEAT DANGER - TAKE ACTION NOW',
        description: 'Current conditions are extremely dangerous and require immediate action.',
        priority: Priority.critical,
        actionItems: [
          'Move to an air-conditioned environment immediately',
          'Stop all outdoor activities',
          'Contact emergency services if experiencing heat-related symptoms',
          'Stay hydrated with cool water',
        ],
        isEmergency: true,
      ));
    }

    // Add emergency recommendations for vulnerable individuals
    if (riskScore >= 70 && (profile.age >= 65 || profile.hasCardio || profile.hasRespiratory)) {
      recommendations.add(SafetyRecommendation(
        title: '⚠️ HIGH RISK FOR VULNERABLE INDIVIDUALS',
        description: 'Your health profile indicates increased risk in current conditions.',
        priority: Priority.critical,
        actionItems: [
          'Move to a cool environment immediately',
          'Have someone check on you regularly',
          'Keep emergency contact numbers handy',
          'Monitor for signs of heat exhaustion',
        ],
        isEmergency: true,
      ));
    }
  }

  static void _addGeneralSafetyRecommendations(
    List<SafetyRecommendation> recommendations,
    int riskScore,
    EnhancedWeatherRisk weatherRisk,
  ) {
    // Hydration recommendations
    recommendations.add(SafetyRecommendation(
      title: 'Hydration Guidelines',
      description: 'Stay properly hydrated based on current conditions',
      priority: riskScore >= 60 ? Priority.high : Priority.moderate,
      actionItems: [
        if (riskScore >= 60) 'Drink water every 15-20 minutes when outdoors',
        if (riskScore >= 40) 'Consume 8-10 glasses of water throughout the day',
        'Avoid alcoholic and caffeinated beverages',
        'Monitor urine color (should be light yellow)',
      ],
    ));

    // UV protection recommendations
    if (weatherRisk.uvIndex > 5) {
      recommendations.add(SafetyRecommendation(
        title: 'UV Protection Required',
        description: 'High UV levels require additional protection',
        priority: weatherRisk.uvIndex > 8 ? Priority.high : Priority.moderate,
        actionItems: [
          'Apply broad-spectrum sunscreen (SPF 30+)',
          'Wear protective clothing and a wide-brimmed hat',
          'Seek shade whenever possible',
          if (weatherRisk.uvIndex > 8) 'Avoid sun exposure between 10 AM and 4 PM',
        ],
      ));
    }
  }

  static void _addHealthRecommendations(
    List<SafetyRecommendation> recommendations,
    UserProfile profile,
    int riskScore,
  ) {
    if (profile.hasCardio) {
      recommendations.add(SafetyRecommendation(
        title: 'Cardiovascular Health Precautions',
        description: 'Take extra care to protect your heart in hot conditions',
        priority: riskScore >= 60 ? Priority.high : Priority.moderate,
        actionItems: [
          'Monitor heart rate frequently',
          'Take regular breaks in cool areas',
          'Keep heart medication easily accessible',
          'Know the signs of heart strain in heat',
        ],
      ));
    }

    if (profile.hasRespiratory) {
      recommendations.add(SafetyRecommendation(
        title: 'Respiratory Health Guidelines',
        description: 'Protect your respiratory health in current conditions',
        priority: riskScore >= 60 ? Priority.high : Priority.moderate,
        actionItems: [
          'Stay in air-conditioned environments',
          'Keep rescue medications nearby',
          'Avoid outdoor activity during peak heat',
          'Monitor breathing difficulties',
        ],
      ));
    }

    if (profile.hasDiabetes) {
      recommendations.add(SafetyRecommendation(
        title: 'Diabetes Management in Heat',
        description: 'Special considerations for managing diabetes in hot weather',
        priority: Priority.high,
        actionItems: [
          'Check blood sugar levels more frequently',
          'Store insulin and supplies properly',
          'Adjust medication timing if needed (consult doctor)',
          'Watch for signs of dehydration',
        ],
      ));
    }

    if (profile.hasHypertension) {
      recommendations.add(SafetyRecommendation(
        title: 'Blood Pressure Management',
        description: 'Special precautions for managing blood pressure in hot weather',
        priority: riskScore >= 60 ? Priority.high : Priority.moderate,
        actionItems: [
          'Monitor blood pressure more frequently',
          'Take medications as prescribed',
          'Stay in cool environments',
          'Avoid sudden temperature changes',
          if (riskScore >= 60) 'Contact healthcare provider if pressure varies significantly',
        ],
      ));
    }

    // Age-specific health recommendations
    if (profile.age >= 65) {
      recommendations.add(SafetyRecommendation(
        title: 'Senior Health Precautions',
        description: 'Additional precautions for older adults',
        priority: riskScore >= 60 ? Priority.high : Priority.moderate,
        actionItems: [
          'Arrange for regular check-ins with family or friends',
          'Keep emergency contacts easily accessible',
          'Stay in air-conditioned environments',
          'Take extra time to cool down after any activity',
          if (riskScore >= 70) 'Consider staying with family/friends during extreme heat',
        ],
      ));
    }
  }

  static void _addActivityRecommendations(
    List<SafetyRecommendation> recommendations,
    UserProfile profile,
    EnhancedWeatherRisk weatherRisk,
    int riskScore,
  ) {
    final timeRiskFactor = weatherRisk.getTimeRiskFactor();
    final isHighRiskTime = timeRiskFactor > 1.1;

    switch (profile.activityLevel) {
      case ActivityLevel.veryActive:
        recommendations.add(SafetyRecommendation(
          title: 'High-Intensity Activity Modifications',
          description: 'Adjust your intense physical activities for safety',
          priority: isHighRiskTime ? Priority.high : Priority.moderate,
          actionItems: [
            'Reduce exercise intensity by 25-50%',
            'Take breaks every 15-20 minutes',
            'Pre-hydrate 30 minutes before activity',
            if (riskScore >= 60) 'Consider indoor alternatives',
            'Monitor heart rate and breathing',
          ],
        ));
      case ActivityLevel.active:
        recommendations.add(SafetyRecommendation(
          title: 'Active Lifestyle Adjustments',
          description: 'Modify your active routine for current conditions',
          priority: isHighRiskTime ? Priority.high : Priority.moderate,
          actionItems: [
            'Schedule activities during cooler hours',
            'Take frequent water breaks',
            'Wear light, breathable clothing',
            'Reduce activity duration if needed',
          ],
        ));
      case ActivityLevel.moderate:
        if (riskScore >= 40) {
          recommendations.add(SafetyRecommendation(
            title: 'Moderate Activity Guidelines',
            description: 'Adjust moderate activities for safety',
            priority: Priority.moderate,
            actionItems: [
              'Consider lighter alternatives',
              'Take regular breaks in shade',
              'Maintain steady hydration',
              'Watch for signs of fatigue',
            ],
          ));
        }
      default:
        if (riskScore >= 60) {
          recommendations.add(SafetyRecommendation(
            title: 'General Activity Precautions',
            description: 'Basic safety measures for any outdoor activity',
            priority: Priority.moderate,
            actionItems: [
              'Limit time outdoors',
              'Stay in shade when possible',
              'Maintain regular hydration',
              'Watch for heat-related symptoms',
            ],
          ));
        }
    }
  }

  static void _addTimeBasedRecommendations(
    List<SafetyRecommendation> recommendations,
    EnhancedWeatherRisk weatherRisk,
    int riskScore,
  ) {
    final hour = weatherRisk.timestamp.hour;
    
    if (hour >= 10 && hour <= 16) {
      recommendations.add(SafetyRecommendation(
        title: 'Peak Heat Hours',
        description: 'Current time is during peak heat hours',
        priority: riskScore >= 60 ? Priority.high : Priority.moderate,
        actionItems: [
          'Minimize outdoor exposure',
          'Use sun protection',
          'Schedule activities for cooler hours',
          'Stay in air-conditioned spaces when possible',
        ],
      ));
    } else if (hour < 10) {
      recommendations.add(SafetyRecommendation(
        title: 'Morning Activity Window',
        description: 'Take advantage of cooler morning hours',
        priority: Priority.low,
        actionItems: [
          'Good time for outdoor activities',
          'Prepare for increasing temperatures',
          'Plan indoor alternatives for later',
          'Pre-hydrate for the day',
        ],
      ));
    } else {
      recommendations.add(SafetyRecommendation(
        title: 'Evening Precautions',
        description: 'Evening safety guidelines',
        priority: Priority.moderate,
        actionItems: [
          'Monitor lingering heat effects',
          'Continue hydration',
          'Allow body temperature normalization',
          'Prepare for tomorrow\'s conditions',
        ],
      ));
    }
  }
}