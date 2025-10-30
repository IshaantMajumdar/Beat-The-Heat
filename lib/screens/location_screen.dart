import 'package:flutter/material.dart';
import '../services/location_service.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final LocationService _locationService = LocationService();
  LocationAddress? _currentLocation;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _currentLocation = position;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkLocationPermission() async {
    final hasPermission = await _locationService.checkLocationPermission();
    if (!hasPermission) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Location permission denied';
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Services'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location Access',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We need your location to provide accurate heat risk assessments based on local weather conditions.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_currentLocation != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Location:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          if (_currentLocation!.address != null)
                            Text(
                              _currentLocation!.address!,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          const SizedBox(height: 8),
                          Text(
                            'Latitude: ${_currentLocation!.position.latitude.toStringAsFixed(4)}',
                          ),
                          Text(
                            'Longitude: ${_currentLocation!.position.longitude.toStringAsFixed(4)}',
                          ),
                          Text(
                            'Accuracy: ±${_currentLocation!.position.accuracy.toStringAsFixed(1)} meters',
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.location_on),
                      label: Text(_currentLocation == null
                          ? 'Get Current Location'
                          : 'Update Location'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manual Location Entry',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'If you prefer, you can manually enter your location:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'City',
                        hintText: 'Enter your city',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'State/Province',
                        hintText: 'Enter your state or province',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        hintText: 'Enter your country',
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement manual location submission
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save Manual Location'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}