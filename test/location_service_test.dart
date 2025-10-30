import 'package:flutter_test/flutter_test.dart';
import 'package:beat_the_heat/services/location_service.dart';

void main() {
  late LocationService locationService;

  setUp(() {
    locationService = LocationService();
  });

  group('LocationService - getLocationFromSearch', () {
    test('should return null for empty search query', () async {
      final result = await locationService.getLocationFromSearch('');
      expect(result, isNull);
    });

    test('should return null for whitespace-only search query', () async {
      final result = await locationService.getLocationFromSearch('   ');
      expect(result, isNull);
    });

    test('integration test - should handle valid city name', () async {
      final result = await locationService.getLocationFromSearch('London');
      
      expect(result, isNotNull);
      expect(result?.position, isNotNull);
      expect(result?.address, isNotNull);
      expect(result?.position.latitude, isNotNull);
      expect(result?.position.longitude, isNotNull);
    }, timeout: const Timeout(Duration(seconds: 30)));  // Increased timeout for real API call

    test('should handle non-existent location gracefully', () async {
      final result = await locationService.getLocationFromSearch('NonExistentCity12345ABCDEF');
      expect(result, isNull);
    });

    test('should handle special characters gracefully', () async {
      final result = await locationService.getLocationFromSearch('London!@#\$%');
      // Should either return null or a valid result, but not crash
      if (result != null) {
        expect(result.position, isNotNull);
        expect(result.address, isNotNull);
      }
    });
  });
}