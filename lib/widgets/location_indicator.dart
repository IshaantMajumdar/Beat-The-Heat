import 'package:flutter/material.dart';
import '../services/location_service.dart';

class LocationIndicator extends StatelessWidget {
  final LocationAddress locationData;

  const LocationIndicator({
    super.key,
    required this.locationData,
  });

  @override
  Widget build(BuildContext context) {
    final address = locationData.address;
    final position = locationData.position;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Location',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (address != null) ...[
              Text(address),
              const SizedBox(height: 4),
            ],
            Text(
              'Coordinates: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}