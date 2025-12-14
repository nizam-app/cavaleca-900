import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:workpleis/features/shared/profile_update_service.dart';
import 'package:logger/logger.dart';

class RealtimeLocationService {
  static final RealtimeLocationService _instance = RealtimeLocationService._internal();
  factory RealtimeLocationService() => _instance;
  RealtimeLocationService._internal();

  final _log = Logger();
  StreamSubscription<Position>? _positionStream;
  Timer? _periodicUpdateTimer;
  bool _isRunning = false;
  Position? _lastPosition;
  DateTime? _lastUpdateTime;

  // Update interval in seconds (default: 30 seconds)
  static const int _updateIntervalSeconds = 30;
  
  // Minimum distance in meters to trigger update (default: 10 meters)
  static const double _minimumDistanceMeters = 10.0;

  /// Start real-time location updates
  Future<void> start() async {
    if (_isRunning) {
      _log.w('RealtimeLocationService is already running');
      return;
    }

    _log.i('Starting RealtimeLocationService...');

    try {
      // Check location service and permissions
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _log.w('Location service is disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _log.w('Location permission denied');
        return;
      }

      _isRunning = true;

      // Get initial location and update
      try {
        final initialPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        await _updateLocation(initialPosition);
      } catch (e) {
        _log.e('Error getting initial location: $e');
      }

      // Start listening to position stream
      _positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Only update if moved 10+ meters
        ),
      ).listen(
        (Position position) {
          _updateLocation(position);
        },
        onError: (error) {
          _log.e('Error in position stream: $error');
        },
      );

      // Also set up periodic update as backup (every 30 seconds)
      _periodicUpdateTimer = Timer.periodic(
        const Duration(seconds: _updateIntervalSeconds),
        (timer) async {
          if (!_isRunning) {
            timer.cancel();
            return;
          }

          try {
            final position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            );
            await _updateLocation(position);
          } catch (e) {
            _log.e('Error in periodic location update: $e');
          }
        },
      );

      _log.i('RealtimeLocationService started successfully');
    } catch (e) {
      _log.e('Error starting RealtimeLocationService: $e');
      _isRunning = false;
    }
  }

  /// Stop real-time location updates
  void stop() {
    if (!_isRunning) {
      return;
    }

    _log.i('Stopping RealtimeLocationService...');

    _positionStream?.cancel();
    _positionStream = null;

    _periodicUpdateTimer?.cancel();
    _periodicUpdateTimer = null;

    _isRunning = false;
    _lastPosition = null;
    _lastUpdateTime = null;

    _log.i('RealtimeLocationService stopped');
  }

  /// Update location to both profile and location status
  Future<void> _updateLocation(Position position) async {
    try {
      // Check if position has changed significantly
      if (_lastPosition != null) {
        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        // If moved less than minimum distance and last update was recent, skip
        if (distance < _minimumDistanceMeters &&
            _lastUpdateTime != null &&
            DateTime.now().difference(_lastUpdateTime!).inSeconds < _updateIntervalSeconds) {
          return;
        }
      }

      _log.i('Updating location: ${position.latitude}, ${position.longitude}');

      // Update profile location via PATCH /api/auth/profile
      // Note: /api/location/update will be handled separately when availability status is changed
      try {
        await ProfileUpdateService.updateLocation(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        _log.i('Profile location updated successfully');
      } catch (e) {
        _log.e('Error updating profile location: $e');
      }

      _lastPosition = position;
      _lastUpdateTime = DateTime.now();
    } catch (e) {
      _log.e('Error in _updateLocation: $e');
    }
  }

  /// Check if service is running
  bool get isRunning => _isRunning;

  /// Get last known position
  Position? get lastPosition => _lastPosition;
}
