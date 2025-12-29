import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

/// Service to handle all app permissions at startup
class AppPermissionService {
  static final _log = Logger();

  /// Request all necessary permissions for the app
  /// This should be called when the app starts
  static Future<void> requestAllPermissions() async {
    _log.i('Requesting all app permissions...');

    try {
      // List of all permissions to request
      final List<Permission> permissions = [
        // Location permissions
        Permission.location,
        Permission.locationWhenInUse,
        Permission.locationAlways,
        
        // Camera permission
        Permission.camera,
        
        // Storage/Media permissions
        Permission.storage,
        Permission.photos,
        Permission.mediaLibrary,
        
        // Notification permission (Android 13+)
        Permission.notification,
      ];

      // Request permissions one by one
      for (final permission in permissions) {
        try {
          // Check if permission is already granted
          final status = await permission.status;
          
          if (status.isGranted) {
            _log.i('${permission.toString()} is already granted');
            continue;
          }

          // Request permission
          final result = await permission.request();
          
          if (result.isGranted) {
            _log.i('${permission.toString()} granted');
          } else if (result.isDenied) {
            _log.w('${permission.toString()} denied');
          } else if (result.isPermanentlyDenied) {
            _log.w('${permission.toString()} permanently denied');
          }
        } catch (e) {
          _log.e('Error requesting ${permission.toString()}: $e');
        }
      }

      // Handle platform-specific permissions
      if (Platform.isAndroid) {
        await _requestAndroidSpecificPermissions();
      } else if (Platform.isIOS) {
        await _requestIOSSpecificPermissions();
      }

      _log.i('Permission request process completed');
    } catch (e) {
      _log.e('Error in requestAllPermissions: $e');
    }
  }

  /// Request Android-specific permissions
  static Future<void> _requestAndroidSpecificPermissions() async {
    try {
      // For Android 13+ (API 33+), use READ_MEDIA_IMAGES instead of storage
      final androidInfo = await Permission.photos.status;
      if (!androidInfo.isGranted) {
        await Permission.photos.request();
      }

      // Request storage permission for older Android versions
      final storageStatus = await Permission.storage.status;
      if (!storageStatus.isGranted) {
        await Permission.storage.request();
      }
    } catch (e) {
      _log.e('Error requesting Android-specific permissions: $e');
    }
  }

  /// Request iOS-specific permissions
  static Future<void> _requestIOSSpecificPermissions() async {
    try {
      // iOS handles most permissions automatically when needed
      // But we can explicitly request location
      final locationStatus = await Permission.location.status;
      if (!locationStatus.isGranted) {
        await Permission.location.request();
      }
    } catch (e) {
      _log.e('Error requesting iOS-specific permissions: $e');
    }
  }

  /// Check if all critical permissions are granted
  static Future<bool> areAllPermissionsGranted() async {
    final permissions = [
      Permission.location,
      Permission.camera,
      Platform.isAndroid ? Permission.photos : Permission.mediaLibrary,
    ];

    for (final permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        return false;
      }
    }
    return true;
  }
}
