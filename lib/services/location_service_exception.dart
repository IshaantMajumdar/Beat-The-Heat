/// Custom exception class for location service errors
class LocationServiceException implements Exception {
  final String message;
  final LocationErrorType type;
  final dynamic originalError;

  LocationServiceException(this.message, this.type, [this.originalError]);

  @override
  String toString() => 'LocationServiceException: $message (Type: $type)';
}

/// Enum representing different types of location errors
enum LocationErrorType {
  /// Location services are disabled
  serviceDisabled,
  
  /// Permission denied by user
  permissionDenied,
  
  /// Permission permanently denied
  permissionDeniedForever,
  
  /// Network error during geocoding
  networkError,
  
  /// Invalid or empty search query
  invalidQuery,
  
  /// No results found for the search query
  noResults,
  
  /// Error during reverse geocoding
  reverseGeocodingError,
  
  /// Rate limit exceeded for geocoding service
  rateLimitExceeded,
  
  /// Invalid coordinates
  invalidCoordinates,
  
  /// Unknown error
  unknown
}