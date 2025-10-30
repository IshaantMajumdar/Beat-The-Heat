import 'package:geolocator/geolocator.dart' show Position, LocationSettings, LocationAccuracy, Geolocator, LocationPermission;
import 'package:geocoding/geocoding.dart' show placemarkFromCoordinates, locationFromAddress, Location, Placemark;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show SocketException;
import 'location_service_exception.dart';
import 'tomtom_location_service.dart';

class LocationAddress {
  final Position position;
  final String? address;

  LocationAddress({required this.position, this.address});
}

class LocationService {
  /// Determine whether location services are enabled.
  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  /// Check location permissions and request if needed
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current location with address
  Future<LocationAddress?> getCurrentLocation() async {
    try {
      if (!await checkLocationPermission()) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition();
      String? address;
      
      // In web, use TomTom reverse geocoding
      if (kIsWeb) {
        try {
          final tomtomService = TomTomLocationService();
          address = await tomtomService.getAddressFromCoordinates(
            position.latitude,
            position.longitude,
          );
          if (address == null) {
            // Fallback to coordinates if reverse geocoding fails
            address = 'Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
          }
          print('Web environment: Using TomTom reverse geocoding');
        } catch (e) {
          print('TomTom reverse geocoding failed: $e');
          address = 'Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        }
      } else {
        try {
          print('Attempting to geocode coordinates: ${position.latitude}, ${position.longitude}');
          final placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            print('Received placemark data: ${place.toString()}');
            
            // Collect all available address components
            final addressComponents = <String>[];
            
            if (place.name?.isNotEmpty ?? false) addressComponents.add(place.name!);
            if (place.street?.isNotEmpty ?? false) addressComponents.add(place.street!);
            if (place.subLocality?.isNotEmpty ?? false) addressComponents.add(place.subLocality!);
            if (place.locality?.isNotEmpty ?? false) addressComponents.add(place.locality!);
            if (place.administrativeArea?.isNotEmpty ?? false) addressComponents.add(place.administrativeArea!);
            if (place.country?.isNotEmpty ?? false) addressComponents.add(place.country!);
            
            // Join non-empty components
            address = addressComponents.join(', ');
            print('Generated address: $address');
          } else {
            print('No placemarks found for the given coordinates');
            // Fallback to coordinate display
            address = 'Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
          }
        } catch (e, stackTrace) {
          // Log both error and stack trace for better debugging
          print('Geocoding failed: $e');
          print('Stack trace: $stackTrace');
          // Fallback to coordinate display
          address = 'Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        }
      }

      return LocationAddress(position: position, address: address);
    } catch (e) {
      return null;
    }
  }

  /// Get location stream
  Stream<Position> getLocationStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100, // Minimum distance (in meters) before updates
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Get location from search string (city name, address, etc.)
  Future<LocationAddress?> getLocationFromSearch(String searchQuery) async {
    if (searchQuery.trim().isEmpty) {
      throw LocationServiceException(
        'Search query cannot be empty',
        LocationErrorType.invalidQuery
      );
    }

    try {
      print('Searching for location: $searchQuery');
      List<Location> locations;
      
      try {
        locations = await locationFromAddress(searchQuery);
      } on SocketException catch (e) {
        throw LocationServiceException(
          'Network error while searching for location. Please check your internet connection.',
          LocationErrorType.networkError,
          e
        );
      } catch (e) {
        if (e.toString().contains('rate limit')) {
          throw LocationServiceException(
            'Rate limit exceeded for location search. Please try again later.',
            LocationErrorType.rateLimitExceeded,
            e
          );
        }
        throw LocationServiceException(
          'Error searching for location: ${e.toString()}',
          LocationErrorType.unknown,
          e
        );
      }
      
      if (locations.isEmpty) {
        throw LocationServiceException(
          'No locations found for "$searchQuery"',
          LocationErrorType.noResults
        );
      }

      final location = locations.first;
      print('Found coordinates: ${location.latitude}, ${location.longitude}');

      // Create position object
      final position = Position(
        latitude: location.latitude,
        longitude: location.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      // Get detailed address information
      String? address;
      try {
        print('Fetching detailed address for coordinates');
        List<Placemark> placemarks;
        
        try {
          placemarks = await placemarkFromCoordinates(
            location.latitude,
            location.longitude,
          );
        } on SocketException catch (e) {
          throw LocationServiceException(
            'Network error while fetching address details. Using search query as fallback.',
            LocationErrorType.networkError,
            e
          );
        } catch (e) {
          if (e.toString().contains('rate limit')) {
            throw LocationServiceException(
              'Rate limit exceeded for address lookup. Using search query as fallback.',
              LocationErrorType.rateLimitExceeded,
              e
            );
          }
          throw LocationServiceException(
            'Error fetching address details: ${e.toString()}. Using search query as fallback.',
            LocationErrorType.reverseGeocodingError,
            e
          );
        }

        if (placemarks.isEmpty) {
          throw LocationServiceException(
            'No address details found for the location. Using search query as fallback.',
            LocationErrorType.noResults
          );
        }

        final place = placemarks.first;
        final addressComponents = <String>[];
        final componentLog = <String, String>{};

        // Build address components with detailed logging
        void tryAddComponent(String? value, String componentName) {
          if (value?.isNotEmpty ?? false) {
            addressComponents.add(value!);
            componentLog[componentName] = value;
          }
        }

        tryAddComponent(place.name, 'place name');
        tryAddComponent(place.street, 'street');
        tryAddComponent(place.subLocality, 'subLocality');
        tryAddComponent(place.locality, 'locality');
        tryAddComponent(place.administrativeArea, 'administrative area');
        tryAddComponent(place.country, 'country');

        // Log all components for debugging
        componentLog.forEach((component, value) {
          print('Address component - $component: $value');
        });

        if (addressComponents.isNotEmpty) {
          address = addressComponents.join(', ');
          print('Generated complete address: $address');
        } else {
          print('No valid address components found, using original query');
          address = searchQuery;
        }
      } catch (e) {
        if (e is LocationServiceException) {
          print(e.toString());
        } else {
          print('Unexpected error during address lookup: $e');
        }
        // Fallback to original search query
        address = searchQuery;
      }

      final result = LocationAddress(position: position, address: address);
      print('Final location result: ${result.address} at (${result.position.latitude}, ${result.position.longitude})');
      return result;
    } catch (e, stackTrace) {
      if (e is LocationServiceException) {
        print('${e.toString()}\nStack trace: $stackTrace');
        rethrow;
      }
      print('Unexpected error in location search: $e\nStack trace: $stackTrace');
      throw LocationServiceException(
        'An unexpected error occurred while searching for the location',
        LocationErrorType.unknown,
        e
      );
    }
  }
}