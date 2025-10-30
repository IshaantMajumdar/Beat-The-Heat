import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:beat_the_heat/services/tomtom_location_service.dart';
import 'package:beat_the_heat/services/location_service_exception.dart';
import 'package:beat_the_heat/config/tomtom_config.dart';

import 'tomtom_location_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late TomTomLocationService service;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    service = TomTomLocationService(client: mockClient);
  });

  group('TomTomLocationService', () {
    final mockSuccessResponse = {
      'results': [
        {
          'position': {
            'lat': 51.5074,
            'lon': -0.1278
          },
          'address': {
            'streetNumber': '10',
            'streetName': 'Downing Street',
            'municipality': 'London',
            'countrySubdivision': 'England',
            'country': 'United Kingdom',
            'postalCode': 'SW1A 2AA'
          }
        }
      ]
    };

    test('successful search returns location address', () async {
      when(mockClient.get(any)).thenAnswer((_) async =>
        http.Response(json.encode(mockSuccessResponse), 200));

      final result = await service.getLocationFromSearch('London');

      expect(result, isNotNull);
      expect(result?.position.latitude, 51.5074);
      expect(result?.position.longitude, -0.1278);
      expect(result?.address, contains('London'));
      expect(result?.address, contains('United Kingdom'));
    });

    test('empty query throws InvalidQuery exception', () async {
      expect(
        () => service.getLocationFromSearch(''),
        throwsA(isA<LocationServiceException>()
          .having((e) => e.type, 'type', LocationErrorType.invalidQuery))
      );
    });

    test('api key error throws RateLimitExceeded exception', () async {
      when(mockClient.get(any)).thenAnswer((_) async =>
        http.Response('Unauthorized', 403));

      expect(
        () => service.getLocationFromSearch('London'),
        throwsA(isA<LocationServiceException>()
          .having((e) => e.type, 'type', LocationErrorType.rateLimitExceeded))
      );
    });

    test('server error throws ServiceDisabled exception', () async {
      when(mockClient.get(any)).thenAnswer((_) async =>
        http.Response('Server Error', 500));

      expect(
        () => service.getLocationFromSearch('London'),
        throwsA(isA<LocationServiceException>()
          .having((e) => e.type, 'type', LocationErrorType.serviceDisabled))
      );
    });

    test('network error throws NetworkError exception', () async {
      when(mockClient.get(any)).thenThrow(
        const SocketException('Failed to connect'));

      expect(
        () => service.getLocationFromSearch('London'),
        throwsA(isA<LocationServiceException>()
          .having((e) => e.type, 'type', LocationErrorType.networkError))
      );
    });

    test('empty results throws NoResults exception', () async {
      when(mockClient.get(any)).thenAnswer((_) async =>
        http.Response(json.encode({'results': []}), 200));

      expect(
        () => service.getLocationFromSearch('NonExistentPlace'),
        throwsA(isA<LocationServiceException>()
          .having((e) => e.type, 'type', LocationErrorType.noResults))
      );
    });
  });
}