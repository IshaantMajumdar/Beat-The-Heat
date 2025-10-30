
---

#### 📁 `docs/data_sources.md`

```markdown
# 🌐 Data Sources

## 🌡️ Weather Data

### Open-Meteo API
- **Documentation**: https://open-meteo.com/en/docs
- **Endpoints Used**:
  - `/v1/forecast`: Current weather and forecasts
  - `/v1/geocoding`: Location search and reverse geocoding
- **Data Points**:
  - Temperature (°C)
  - Relative Humidity (%)
  - UV Index
  - Wind Speed
  - Weather Codes
- **Update Frequency**: Every 30 minutes
- **Cache Duration**: 30 minutes
- **Limitations**: Free tier limitations apply

## 🌍 Location Services

### Device GPS
- **Purpose**: Current location detection
- **Data Points**:
  - Latitude
  - Longitude
  - Location Permission Status
- **Update Frequency**: On-demand
- **Permissions Required**: 
  - `ACCESS_FINE_LOCATION`
  - `ACCESS_COARSE_LOCATION`

### Open-Meteo Geocoding API
- **Documentation**: https://geocoding-api.open-meteo.com/v1/
- **Purpose**: Location search and address lookup
- **Features**:
  - Forward geocoding (search by name)
  - Reverse geocoding (coordinates to address)
- **Update Frequency**: On-demand
- **Cache Duration**: None (real-time lookups)

## 🧮 Risk Calculation

### Heat Index Algorithm
- **Source**: NOAA/NWS Heat Index Formula
- **Documentation**: https://www.wpc.ncep.noaa.gov/html/heatindex.shtml
- **Calculations**:
  - Basic heat index from temperature and humidity
  - Adjustments for extreme conditions
  - Personal risk factor calculations

### Health Risk Factors
- **Source**: CDC Heat Stress Guidelines
- **Risk Factors Considered**:
  - Age
  - Medical conditions
  - Activity level
  - Gender
- **Update Frequency**: On profile changes

## 💾 Local Storage

### Shared Preferences
- **Purpose**: Temporary data caching
- **Stored Data**:
  - Last known weather
  - Location cache
  - User preferences
- **Retention**: Session-only
- **Privacy**: Data stored locally only

### Memory Storage
- **Purpose**: Runtime data management
- **Stored Data**:
  - Current session data
  - User profile
  - Active location
- **Retention**: Memory-only
- **Privacy**: Cleared on app close

## � Data Flow

1. Location Detection:
   ```
   Device GPS -> Location Permission -> Coordinates
   ```

2. Weather Data:
   ```
   Coordinates -> Open-Meteo API -> Weather Data -> Local Cache
   ```

3. Risk Calculation:
   ```
   Weather Data + User Profile -> Heat Index -> Risk Score
   ```

4. Location Search:
   ```
   Search Query -> Geocoding API -> Coordinates -> Weather Data
   ```

## ⚠️ Error Handling

- Network connectivity issues
- Location permission denials
- API rate limits
- Invalid location data
- Cached data fallbacks
