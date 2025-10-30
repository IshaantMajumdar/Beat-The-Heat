# Beat The Heat - Setup Guide

## 🚀 Quick Start

### Prerequisites
1. **Flutter SDK**
   ```bash
   # Check if Flutter is installed
   flutter --version
   
   # Required: Flutter 3.x, Dart 3.9.2 or higher
   ```

2. **Development Environment**
   - VS Code with Flutter extension
   - Android Studio for Android development
   - Xcode for iOS development (Mac only)

3. **Device Setup**
   - Physical device or emulator for mobile
   - Chrome/Edge for web development

### 📦 Installation Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/publishingdomain01-pixel/beat_the_heat.git
   cd beat_the_heat
   ```

2. **Get Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   # Debug mode
   flutter run

   # Release mode
   flutter run --release
   ```

## 🛠️ Detailed Setup

### 1. Environment Setup

#### Flutter Installation
1. Download Flutter SDK from [flutter.dev](https://flutter.dev)
2. Add Flutter to your PATH
3. Run `flutter doctor` to verify installation

#### IDE Setup
1. **VS Code**
   - Install Flutter extension
   - Install Dart extension
   - Configure Flutter SDK path

2. **Android Studio**
   - Install Flutter plugin
   - Configure Android SDK
   - Setup Android emulator

### 2. Project Configuration

#### API Keys
1. Create `lib/config/keys.dart` (not in version control)
   ```dart
   class ApiKeys {
     static const String weatherApi = 'your_api_key';
   }
   ```

2. Create `lib/config/tomtom_config.dart` (not in version control)
   ```dart
   class TomTomConfig {
     static const String apiKey = 'your_tomtom_api_key';
     static const String baseUrl = 'https://api.tomtom.com';
     static const String apiVersion = '2';
     static const int maxResults = 5;
     static const String language = 'en-US';
     static const Duration timeout = Duration(seconds: 10);
   }
   ```

3. Getting a TomTom API Key:
   - Visit [TomTom Developer Portal](https://developer.tomtom.com/)
   - Create a free account
   - Create a new project
   - Generate an API key with the following permissions:
     - Search API
     - Reverse Geocoding
   - Copy the API key to your `tomtom_config.dart`

#### Platform Setup

1. **Android**
   - Minimum SDK version: 21
   - Target SDK version: 34
   - Required permissions in `android/app/src/main/AndroidManifest.xml`:
     ```xml
     <uses-permission android:name="android.permission.INTERNET"/>
     <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
     <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
     ```
   
   - Add TomTom repository to `android/build.gradle.kts`:
     ```kotlin
     allprojects {
         repositories {
             google()
             mavenCentral()
             maven {
                 url = uri("https://repositories.tomtom.com/repository/maven-releases")
             }
         }
     }
     ```

   - Add TomTom dependencies to `android/app/build.gradle.kts`:
     ```kotlin
     dependencies {
         implementation("com.tomtom.sdk.search:search:0.33.1")
         implementation("com.tomtom.sdk.common:common:0.33.1")
     }
     ```

2. **iOS** (Mac only)
   - Minimum iOS version: 12.0
   - Add to `ios/Runner/Info.plist`:
     ```xml
     <key>NSLocationWhenInUseUsageDescription</key>
     <string>This app needs access to location for heat risk assessment.</string>
     ```

### 3. Development Workflow

1. **Run Tests**
   ```bash
   # Unit tests
   flutter test

   # Integration tests
   flutter test integration_test

   # TomTom Service Tests
   flutter test test/tomtom_location_service_test.dart
   flutter test test/tomtom_integration_test.dart
   ```

2. **Verify TomTom Integration**
   - Check location search functionality:
     ```dart
     final service = TomTomLocationService();
     final result = await service.getLocationFromSearch("London");
     print(result?.address);
     ```
   - Test reverse geocoding:
     ```dart
     final service = TomTomLocationService();
     final address = await service.getAddressFromCoordinates(51.5074, -0.1278);
     print(address);
     ```
   - Common issues:
     - Invalid API key error (HTTP 403)
     - Network timeout
     - Rate limiting
     - Invalid coordinates

2. **Code Generation** (if needed)
   ```bash
   flutter pub run build_runner build
   ```

3. **Analyze Code**
   ```bash
   flutter analyze
   ```

### 4. Building for Release

1. **Android**
   ```bash
   flutter build apk --release
   # or
   flutter build appbundle --release
   ```

2. **iOS** (Mac only)
   ```bash
   flutter build ios --release
   ```

3. **Web**
   ```bash
   flutter build web --release
   ```

## 🔧 Troubleshooting

### Common Issues

1. **Build Failures**
   - Clean the project:
     ```bash
     flutter clean
     flutter pub get
     ```

2. **Location Services**
   - Enable location services on device
   - Grant permissions in app settings

3. **API Connection Issues**
   - Verify internet connection
   - Check API keys configuration
   - Verify SSL certificates

4. **TomTom Service Issues**
   - Verify TomTom API key is valid and not expired
   - Check rate limits in TomTom Developer Dashboard
   - Ensure search queries are properly encoded
   - Verify coordinates are within valid ranges:
     - Latitude: -90 to 90
     - Longitude: -180 to 180
   - Test API key using curl:
     ```bash
     curl "https://api.tomtom.com/search/2/search/London.json?key=YOUR_API_KEY"
     ```
   - Common error codes:
     - 403: Invalid API key
     - 429: Rate limit exceeded
     - 500: TomTom service error

### Development Tips

1. **Hot Reload**
   - Use `r` in terminal for hot reload
   - Use `R` for hot restart

2. **Performance Profile**
   ```bash
   flutter run --profile
   ```

3. **Debug Mode**
   - Enable debugging in IDE
   - Use Flutter DevTools

## 📱 Testing Devices

### Recommended Test Devices

1. **Mobile**
   - Android phone (multiple screen sizes)
   - iPhone (if developing for iOS)
   - Tablets (7" and 10")

2. **Emulators/Simulators**
   - Android emulator with different configurations
   - iOS simulator (Mac only)

3. **Web Browsers**
   - Chrome
   - Firefox
   - Safari
   - Edge

## 🆘 Support

### Getting Help
- Check [Flutter documentation](https://flutter.dev/docs)
- Visit [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- Review project issues on GitHub

### Reporting Issues
1. Check existing issues
2. Provide clear reproduction steps
3. Include device/OS information
4. Add relevant logs or screenshots