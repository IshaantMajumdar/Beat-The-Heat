import 'dart:io' show SocketException;
import 'package:geolocator/geolocator.dart' show Position;
import '../services/location_service_exception.dart';
import '../services/location_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/tomtom_config.dart';

/// TomTom-based implementation of location search service
class TomTomLocationService implements LocationService {
  final http.Client _client;

  TomTomLocationService({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<LocationAddress?> getLocationFromSearch(String searchQuery) async {
    if (searchQuery.trim().isEmpty) {
      throw LocationServiceException(
        'Search query cannot be empty',
        LocationErrorType.invalidQuery
      );
    }

    try {
      final uri = Uri.parse(
        '${TomTomConfig.baseUrl}/search/${TomTomConfig.apiVersion}/search/${Uri.encodeComponent(searchQuery)}.json'
        '?key=${TomTomConfig.apiKey}'
        '&limit=${TomTomConfig.maxResults}'
        '&language=${TomTomConfig.language}'
      );

      final response = await _client
          .get(uri)
          .timeout(TomTomConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>;

        if (results.isEmpty) {
          throw LocationServiceException(
            'No locations found for "$searchQuery"',
            LocationErrorType.noResults
          );
        }

        final location = results.first;
        final position = Position(
          latitude: location['position']['lat'],
          longitude: location['position']['lon'],
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );

        // Build address from TomTom response
        final address = _buildAddressFromTomTomResponse(location);

        return LocationAddress(position: position, address: address);
      } else if (response.statusCode == 403) {
        throw LocationServiceException(
          'Invalid or expired API key',
          LocationErrorType.rateLimitExceeded
        );
      } else if (response.statusCode >= 500) {
        throw LocationServiceException(
          'TomTom service temporarily unavailable',
          LocationErrorType.serviceDisabled
        );
      } else {
        throw LocationServiceException(
          'Error searching location: HTTP ${response.statusCode}',
          LocationErrorType.unknown
        );
      }
    } catch (e) {
      if (e is LocationServiceException) {
        rethrow;
      }
      if (e is SocketException) {
        throw LocationServiceException(
          'Network error: Unable to connect to TomTom service',
          LocationErrorType.networkError,
          e
        );
      }
      throw LocationServiceException(
        'Error searching location: ${e.toString()}',
        LocationErrorType.unknown,
        e
      );
    }
  }

  /// Helper method to build address string from TomTom response
  String _buildAddressFromTomTomResponse(Map<String, dynamic> location) {
    final address = location['address'];
    final components = <String>[];

    // Add address components in order of specificity
    void tryAddComponent(String key) {
      final value = address[key];
      if (value != null && value.toString().isNotEmpty) {
        components.add(value.toString());
      }
    }

    // Street address
    if (address.containsKey('streetNumber')) {
      tryAddComponent('streetNumber');
      tryAddComponent('streetName');
    } else {
      tryAddComponent('streetName');
    }

    // City/locality information
    tryAddComponent('municipalitySubdivision');
    tryAddComponent('municipality');
    
    // Region and country
    tryAddComponent('countrySubdivision');
    tryAddComponent('country');
    
    // Postal code
    tryAddComponent('postalCode');

    return components.join(', ');
  }

  @override
  Future<LocationAddress?> getCurrentLocation() async {
    // Implement if needed, or throw UnimplementedError
    throw UnimplementedError('getCurrentLocation is not implemented for TomTom service');
  }

  /// Get address details from coordinates using TomTom reverse geocoding
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final uri = Uri.parse(
        '${TomTomConfig.baseUrl}/search/${TomTomConfig.apiVersion}/reverseGeocode/${latitude},${longitude}.json'
        '?key=${TomTomConfig.apiKey}'
        '&language=${TomTomConfig.language}'
      );

      final response = await _client
          .get(uri)
          .timeout(TomTomConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final addresses = data['addresses'] as List<dynamic>;

        if (addresses.isEmpty) {
          print('No address found for coordinates ($latitude, $longitude)');
          return null;
        }

        final address = addresses.first['address'];
        return _buildAddressFromTomTomResponse({'address': address});
      } else if (response.statusCode == 403) {
        throw LocationServiceException(
          'Invalid or expired API key',
          LocationErrorType.rateLimitExceeded
        );
      } else {
        throw LocationServiceException(
          'Error in reverse geocoding: HTTP ${response.statusCode}',
          LocationErrorType.reverseGeocodingError
        );
      }
    } catch (e) {
      if (e is LocationServiceException) {
        rethrow;
      }
      if (e is SocketException) {
        throw LocationServiceException(
          'Network error during reverse geocoding',
          LocationErrorType.networkError,
          e
        );
      }
      print('Error in reverse geocoding: $e');
      return null;
    }
  }

  @override
  Stream<Position> getLocationStream() {
    // Implement if needed, or throw UnimplementedError
    throw UnimplementedError('getLocationStream is not implemented for TomTom service');
  }

  @override
  Future<bool> checkLocationPermission() async {
    // Implement if needed
    return true;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    // Implement if needed
    return true;
  }
}