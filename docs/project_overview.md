# Beat The Heat - Project Overview

## 📱 Application Overview
Beat The Heat is a Flutter-based mobile and web application that provides personalized heat risk assessment and safety recommendations. The app is designed with a privacy-first approach, processing all data locally without requiring a backend server.

## 🏗️ Architecture

### Data Layer
- **In-Memory Storage**
  - `MemoryStorageService`: Handles runtime data storage
  - `SessionData`: Manages user profile and session information
  - No persistent storage for privacy

- **Services**
  - `WeatherService`: Interfaces with weather APIs
  - `LocationService`: Handles geolocation
  - `ConnectivityService`: Manages online/offline states
  - `RiskCalculator`: Computes heat risk scores

### UI Layer
- **Screens**
  - `HomeScreen`: Main interface showing weather and risk information
  - Responsive design supporting mobile, tablet, and desktop layouts

- **Widgets**
  - `ConsentDialog`: User privacy management
  - `LocationIndicator`: Location display
  - `OfflineStatusIndicators`: Network status
  - Custom loading and skeleton screens

### Utils
- `ResponsiveUtils`: Screen size adaptation
- `SafetyRecommendationsEngine`: Generates contextual safety advice
- `RiskCalculator`: Heat index and risk score computation

## 🔑 Key Features

### 1. Privacy-First Design
- Local data processing
- Session-only storage
- Clear consent management
- No backend dependencies

### 2. Risk Assessment
- Real-time heat index calculation
- Personalized risk scoring (0-100)
- Health profile consideration
- Activity-level adjustments
- Location-specific risk comparison
- Advanced heat index computation using temperature and humidity

### 3. Weather Monitoring
- Current conditions
- Temperature and humidity tracking
- UV index monitoring
- Location-based updates
- Multi-location risk assessment
- Location search functionality

### 4. Health Profiling
- Age and gender considerations
- Medical condition tracking
- Activity level assessment
- Personalized recommendations

### 5. Responsive Design
- Mobile-first approach
- Tablet optimization
- Desktop support
- Adaptive layouts and typography

### 6. Offline Support
- Local data caching
- Offline functionality
- Sync status indicators
- Connection state management

## 🛠️ Technical Stack

### Framework & Language
- Flutter SDK 3.x
- Dart 3.9.2
- Material Design 3.0

### Core Dependencies
- `provider`: ^6.1.5+1 (State management)
- `geolocator`: ^9.0.2 (Location services)
- `http`: ^1.1.0 (API communication)
- `shared_preferences`: ^2.5.3 (Local storage)
- `connectivity_plus`: ^7.0.0 (Network state)
- `geocoding`: ^4.0.0 (Location data)

### Development Dependencies
- `mockito`: ^5.4.4 (Testing)
- `build_runner`: ^2.4.8 (Code generation)
- `flutter_lints`: ^5.0.0 (Static analysis)

## 📊 Data Sources
- Open-Meteo API (Weather data)
- Device GPS (Location)
- Local profile data
- CDC heat index algorithms

## 🔒 Security Features
- Privacy-by-design approach
- Local-only data processing
- Automatic data clearing
- Permission management

## 🎯 Future Enhancements
1. Push notifications
2. Enhanced offline capabilities
3. More weather data sources
4. Advanced risk modeling
5. Historical data analysis