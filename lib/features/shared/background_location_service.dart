import 'package:geolocator/geolocator.dart';
import 'package:workpleis/features/shared/profile_update_service.dart';
import 'package:workpleis/features/shared/location_update_service.dart';
import 'package:workpleis/features/shared/realtime_location_service.dart';
import 'package:logger/logger.dart';

/// Service to handle location updates in the background without showing popups
class BackgroundLocationService {
  static final _log = Logger();

  /// Request location permission and update location silently in the background
  /// This will show the system permission dialog if needed, but not our custom popup
  static Future<void> requestAndUpdateLocationInBackground() async {
    _log.i('Starting background location update...');

    try {
      // Check if location service is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _log.w('Location service is disabled');
        // Start real-time service anyway, it will handle permission checks
        RealtimeLocationService().start();
        return;
      }

      // Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Request permission (this will show system dialog, but not our custom popup)
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _log.w('Location permission denied or denied forever');
        // Start real-time service anyway, it will handle permission checks
        RealtimeLocationService().start();
        return;
      }

      // Get current location
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        _log.i('Got location: ${position.latitude}, ${position.longitude}');

        // Update profile location via PATCH /api/auth/profile
        try {
          await ProfileUpdateService.updateLocation(
            latitude: position.latitude,
            longitude: position.longitude,
          );
          _log.i('Profile location updated successfully');
        } catch (e) {
          _log.e('Error updating profile location: $e');
        }

        // Update location via POST /api/location/update (without status)
        try {
          await LocationUpdateService.updateLocation(
            latitude: position.latitude,
            longitude: position.longitude,
          );
          _log.i('Location updated successfully');
        } catch (e) {
          _log.e('Error updating location: $e');
        }

        // Start real-time location updates
        RealtimeLocationService().start();
        _log.i('Background location update completed successfully');
      } catch (e) {
        _log.e('Error getting current location: $e');
        // Start real-time service anyway
        RealtimeLocationService().start();
      }
    } catch (e) {
      _log.e('Error in requestAndUpdateLocationInBackground: $e');
      // Start real-time service anyway
      RealtimeLocationService().start();
    }
  }
}
