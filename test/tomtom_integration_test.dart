import 'package:flutter_test/flutter_test.dart';
import 'package:beat_the_heat/services/tomtom_location_service.dart';

void main() {
  test('TomTom API Integration Test', () async {
    final service = TomTomLocationService();
    
    // Test with a well-known location
    final result = await service.getLocationFromSearch('London, UK');
    
    expect(result, isNotNull);
    expect(result?.position, isNotNull);
    expect(result?.address, isNotNull);
    
    // Verify the coordinates are roughly in London
    expect(result?.position.latitude, closeTo(51.5074, 1.0));
    expect(result?.position.longitude, closeTo(-0.1278, 1.0));
    
    // Verify address contains key components
    expect(result?.address?.toLowerCase(), contains('london'));
    
    print('Successfully found location: ${result?.address}');
    print('Coordinates: (${result?.position.latitude}, ${result?.position.longitude})');
  }, timeout: Timeout(Duration(seconds: 30))); // Increased timeout for API call
}