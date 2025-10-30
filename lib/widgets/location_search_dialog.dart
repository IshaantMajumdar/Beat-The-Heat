import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../services/location_service_exception.dart';
import '../services/tomtom_location_service.dart';

class LocationSearchDialog extends StatefulWidget {
  final void Function(LocationAddress? location)? onLocationSelected;
  final LocationService? locationService;

  const LocationSearchDialog({
    super.key, 
    this.onLocationSelected,
    this.locationService,
  });

  @override
  State<LocationSearchDialog> createState() => _LocationSearchDialogState();
}

class _LocationSearchDialogState extends State<LocationSearchDialog> {
  final _searchController = TextEditingController();
  late final LocationService _locationService;
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _locationService = widget.locationService ?? TomTomLocationService();
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _errorMessage = 'Please enter a location');
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final location = await _locationService.getLocationFromSearch(query);
      
      if (mounted) {
        if (widget.onLocationSelected != null) {
          widget.onLocationSelected!(location);
        }
        Navigator.of(context).pop(location);
      }
    } on LocationServiceException catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          switch (e.type) {
            case LocationErrorType.networkError:
              _errorMessage = 'Please check your internet connection';
              break;
            case LocationErrorType.noResults:
              _errorMessage = 'Location not found';
              break;
            case LocationErrorType.invalidQuery:
              _errorMessage = 'Invalid location name';
              break;
            case LocationErrorType.rateLimitExceeded:
              _errorMessage = 'Too many searches. Please try again later';
              break;
            case LocationErrorType.reverseGeocodingError:
              _errorMessage = 'Error getting address details';
              break;
            case LocationErrorType.serviceDisabled:
              _errorMessage = 'Location services are disabled';
              break;
            case LocationErrorType.permissionDenied:
            case LocationErrorType.permissionDeniedForever:
              _errorMessage = 'Location permission denied';
              break;
            default:
              _errorMessage = 'Error searching location';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _errorMessage = 'Unexpected error occurred';
        });
        print('Unexpected error in location search: $e');
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Search Location'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Enter city name or address',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (_) => _searchLocation(),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSearching ? null : _searchLocation,
          child: const Text('Search'),
        ),
      ],
    );
  }
}