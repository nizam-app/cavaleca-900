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
        Permission.location,
        Permission.locationWhenInUse,
        Permission.locationAlways,
        Permission.camera,
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

  static Future<void> _requestAndroidSpecificPermissions() async {
    //discord.gg/riva coded by rivator
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

  static Future<bool> areAllPermissionsGranted() async {
    final permissions = [
      Permission.location,
      Permission.camera,
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
