# Testing Guide

## Location Search Testing

### Main Screen Search
1. Verify the "Check Other Locations" button is visible in Quick Actions
2. Test searching for locations with different weather conditions:
   - Hot and humid locations (e.g., Dubai, Singapore)
   - Hot and dry locations (e.g., Phoenix, Las Vegas)
   - Cool locations (e.g., Vancouver, Oslo)
3. Verify risk scores change appropriately based on:
   - Temperature differences
   - Humidity levels
   - Time of day
   - UV index

### Risk Score Verification
1. Check heat index calculation:
   - Temperature impact
   - Humidity impact
   - Combined effects
2. Verify risk score ranges:
   - Low risk (0-20): Cool conditions
   - Moderate risk (21-40): Warm conditions
   - High risk (41-70): Hot conditions
   - Extreme risk (71-100): Dangerous heat conditions

### User Flow Testing
1. Search Location:
   - Open search dialog
   - Enter location name
   - Select from search results
   - Verify location update

2. Location Switch:
   - Check snackbar appearance
   - Verify "Use Current Location" option
   - Test switching between locations

3. Data Accuracy:
   - Compare with known weather sources
   - Verify temperature ranges
   - Check humidity levels
   - Validate heat index calculations

## Common Test Cases

### Positive Tests
1. Search for major cities
2. Switch between current and searched locations
3. Check risk score changes
4. Verify weather data updates

### Negative Tests
1. Invalid location names
2. Network connection loss
3. Location service disabled
4. Invalid coordinates

### Edge Cases
1. Extreme temperatures
2. Very high/low humidity
3. Polar regions
4. Equatorial regions
5. High altitude locations