import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:beat_the_heat/widgets/location_search_dialog.dart';
import 'package:beat_the_heat/services/location_service.dart';
import 'package:geolocator/geolocator.dart' show Position;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'location_search_dialog_test.mocks.dart';

@GenerateMocks([LocationService])
void main() {
  late MockLocationService mockLocationService;

  setUp(() {
    mockLocationService = MockLocationService();
  });

  testWidgets('LocationSearchDialog shows search field and buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Material(child: LocationSearchDialog()),
    ));

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
  });

  testWidgets('LocationSearchDialog shows error for empty input', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Material(child: LocationSearchDialog()),
    ));

    // Try to search with empty text
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('Please enter a location'), findsOneWidget);
  });

  testWidgets('LocationSearchDialog shows loading indicator during search', (WidgetTester tester) async {
    bool onLocationSelectedCalled = false;
    
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: LocationSearchDialog(
          locationService: mockLocationService,
          onLocationSelected: (_) {
            onLocationSelectedCalled = true;
          },
        ),
      ),
    ));

    // Mock a delayed search response
    when(mockLocationService.getLocationFromSearch('London')).thenAnswer(
      (_) => Future.delayed(const Duration(milliseconds: 100), () {
        return LocationAddress(
          position: Position(
            latitude: 51.5074,
            longitude: -0.1278,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          ),
          address: 'London, UK',
        );
      }),
    );

    // Enter valid text and start search
    await tester.enterText(find.byType(TextField), 'London');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    // Verify loading indicator appears
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for search to complete
    await tester.pumpAndSettle();
    expect(onLocationSelectedCalled, isTrue);
  });

  testWidgets('LocationSearchDialog handles search error', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: LocationSearchDialog(
          locationService: mockLocationService,
        ),
      ),
    ));

    // Mock an error response
    when(mockLocationService.getLocationFromSearch('InvalidLocation'))
        .thenAnswer((_) async => throw Exception('Search failed'));

    // Enter text and search
    await tester.enterText(find.byType(TextField), 'InvalidLocation');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Error searching location'), findsOneWidget);
  });

  testWidgets('LocationSearchDialog handles not found response', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: LocationSearchDialog(
          locationService: mockLocationService,
        ),
      ),
    ));

    // Mock a not found response
    when(mockLocationService.getLocationFromSearch('NonExistentCity'))
        .thenAnswer((_) async => null);

    // Enter text and search
    await tester.enterText(find.byType(TextField), 'NonExistentCity');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Location not found'), findsOneWidget);
  });

  testWidgets('LocationSearchDialog closes on cancel', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Material(child: LocationSearchDialog()),
    ));

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(LocationSearchDialog), findsNothing);
  });
}