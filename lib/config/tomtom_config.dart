/// Configuration class for TomTom services
class TomTomConfig {
  /// Your TomTom API key
  static const String apiKey = 'td0nV9aoB2ayEuep9Bgq07oh2GKDdyCr';

  /// Base URL for TomTom services
  static const String baseUrl = 'https://api.tomtom.com';

  /// Version of the API to use
  static const String apiVersion = '2';

  /// Maximum number of results to return
  static const int maxResults = 5;

  /// Default language for results
  static const String language = 'en-US';

  /// Timeout duration for API calls
  static const Duration timeout = Duration(seconds: 10);
}