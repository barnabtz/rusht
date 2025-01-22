import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Request location permission and check if location services are enabled
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable the services');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.');
    }

    return true;
  }

  /// Get the current position and convert it to a readable address
  Future<String> getCurrentAddress() async {
    await _handleLocationPermission();
    
    // Get current position
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        throw Exception('No address found for this location');
      }

      Placemark place = placemarks[0];
      
      // Build address components, filtering out empty or null values
      List<String> addressComponents = [];

      // Add street address
      if (place.street?.isNotEmpty ?? false) {
        addressComponents.add(place.street!);
      }

      // Add sublocality (neighborhood/district)
      if (place.subLocality?.isNotEmpty ?? false) {
        addressComponents.add(place.subLocality!);
      }

      // Add locality (city)
      if (place.locality?.isNotEmpty ?? false) {
        addressComponents.add(place.locality!);
      }

      // Add country
      if (place.country?.isNotEmpty ?? false) {
        addressComponents.add(place.country!);
      }

      if (addressComponents.isEmpty) {
        throw Exception('Could not determine address for this location');
      }

      return addressComponents.join(', ');
    } catch (e) {
      throw Exception('Failed to get address: ${e.toString()}');
    }
  }
}
