import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, please enable them in settings.',
      );
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  /// Returns a human-readable address string using reverse geocoding via OpenStreetMap.
  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'Citizen/1.0.0', // OSM requires user agent
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['address'] != null) {
          final addr = data['address'];
          final List<String> parts = [];

          // Specific landmark (shop, building, amenity)
          if (addr['amenity'] != null) parts.add(addr['amenity']);
          if (parts.isEmpty && addr['shop'] != null) parts.add(addr['shop']);
          if (parts.isEmpty && addr['building'] != null) {
            parts.add(addr['building']);
          }

          // House number + road for precise street address
          if (addr['house_number'] != null && addr['road'] != null) {
            parts.add('${addr['house_number']}, ${addr['road']}');
          } else if (addr['road'] != null) {
            parts.add(addr['road']);
          }

          // Area / neighbourhood
          if (addr['neighbourhood'] != null) parts.add(addr['neighbourhood']);
          if (addr['suburb'] != null &&
              addr['suburb'] != addr['neighbourhood']) {
            parts.add(addr['suburb']);
          }
          if (addr['quarter'] != null) parts.add(addr['quarter']);

          // City or town or village
          final city =
              addr['city'] ??
              addr['town'] ??
              addr['village'] ??
              addr['county'] ??
              addr['state_district'];
          if (city != null) parts.add(city);

          // Pincode
          if (addr['postcode'] != null) parts.add(addr['postcode']);

          if (parts.isNotEmpty) {
            return parts.join(', ');
          }
          if (data['display_name'] != null) {
            // Trim long display names to top 4 segments
            final split = data['display_name'].split(',');
            if (split.length > 4) {
              return split.take(4).join(',').trim();
            }
            return data['display_name'];
          }
        }
      }
      return 'Unknown Location ($lat, $lng)';
    } catch (e) {
      return 'Unknown Location ($lat, $lng)';
    }
  }
}
