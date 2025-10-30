import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/annotations.dart';
import '../lib/screens/home_screen.dart';
import '../lib/services/weather_service.dart';
import '../lib/services/memory_storage_service.dart';
import '../lib/models/user_profile.dart';

// Generate mock classes
@GenerateMocks([WeatherService, Geolocator])
void main() {
  late MemoryStorageService memoryStorage;

  setUp(() {
    memoryStorage = MemoryStorageService();
    memoryStorage.initializeSession();
  });

  testWidgets('HomeScreen shows initial state correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    // Check initial UI elements
    expect(find.text('Beat The Heat'), findsOneWidget);
    expect(find.text('Status: Idle'), findsOneWidget);
    expect(find.text('No risk computed yet'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('HomeScreen shows consent dialog when profile icon is tapped', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    // Tap the profile icon
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();

    // Verify consent dialog is shown
    expect(find.text('Personalize and consent'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget); // Age field
    expect(find.byType(CheckboxListTile), findsNWidgets(2)); // Health conditions
    expect(find.byType(SwitchListTile), findsOneWidget); // Consent switch
  });

  testWidgets('HomeScreen updates profile when consent is given', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    // Open consent dialog
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();

    // Fill in the form
    await tester.enterText(find.byType(TextFormField), '65');
    await tester.pumpAndSettle();

    // Toggle health conditions
    await tester.tap(find.text('Heart / cardiovascular condition'));
    await tester.pumpAndSettle();

    // Give consent
    await tester.tap(find.text('I consent to local processing of my data'));
    await tester.pumpAndSettle();

    // Save the profile
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify profile is saved in memory
    final profile = memoryStorage.sessionData.userProfile;
    expect(profile, isNotNull);
    expect(profile?.age, equals(65));
    expect(profile?.hasCardio, isTrue);
    expect(profile?.consented, isTrue);
  });

  testWidgets('HomeScreen shows weather and risk information when available', (WidgetTester tester) async {
    // Set up a test profile
    final testProfile = UserProfile(
      age: 65,
      gender: Gender.other,
      hasCardio: true,
      hasRespiratory: false,
      hasDiabetes: false,
      hasHypertension: false,
      activityLevel: ActivityLevel.moderate,
      consented: true,
    );
    memoryStorage.sessionData.setUserProfile(testProfile);
    memoryStorage.updateUserConsent(true);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump();

    // Initially should show loading state
    expect(find.text('Status: Checking permissions'), findsOneWidget);

    // Note: In a real test, you would need to mock the WeatherService and Geolocator
    // to provide test data and avoid actual API calls and location services
  });

  // Add more test cases as needed
}