import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:workpleis/core/constants/api_control/notificiaon_api.dart';
import 'package:workpleis/core/utils/global_save_login_data.dart';

class FCMService {
  static final _log = Logger();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  /// Initialize FCM and request permissions
  static Future<void> initialize() async {
    if (_isInitialized) {
      _log.i('FCM already initialized');
      return;
    }

    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request notification permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _log.i('User granted notification permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        _log.i('User granted provisional notification permission');
      } else {
        _log.w('User declined or has not accepted notification permission');
        return;
      }

      // Get FCM token
      final token = await getFCMToken();
      if (token != null) {
        await sendTokenToServer(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _log.i('FCM Token refreshed: $newToken');
        sendTokenToServer(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _log.i('Got a message whilst in the foreground!');
        _log.i('Message data: ${message.data}');
        _log.i('Message notification: ${message.notification}');
        
        // Show local notification when app is in foreground
        _showLocalNotification(message);
      });

      // Handle background messages (when app is in background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _log.i('A new onMessageOpenedApp event was published!');
        _log.i('Message data: ${message.data}');
        _handleNotificationTap(message);
      });

      // Check if app was opened from a notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _log.i('App opened from notification: ${initialMessage.data}');
        _handleNotificationTap(initialMessage);
      }

      _isInitialized = true;
      _log.i('FCM initialized successfully');
    } catch (e, stackTrace) {
      _log.e('Error initializing FCM: $e', error: e, stackTrace: stackTrace);
    }
  }

  /// Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _log.i('Notification tapped: ${response.payload}');
      },
    );
  }

  /// Show local notification for foreground messages
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title ?? 'New Notification',
      notification.body ?? '',
      details,
      payload: message.data.toString(),
    );
  }

  /// Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    _log.i('Handling notification tap: ${message.data}');
    // You can navigate to specific screen based on notification data
    // For example:
    // if (message.data['type'] == 'job') {
    //   // Navigate to job screen
    // }
  }

  /// Get FCM token
  static Future<String?> getFCMToken() async {
    try {
      final token = await _messaging.getToken();
      _log.i('FCM Token: $token');
      return token;
    } catch (e, stackTrace) {
      _log.e('Error getting FCM token: $e', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Send FCM token to server
  static Future<bool> sendTokenToServer(String fcmToken) async {
    try {
      final token = await AuthLocalStorage.getToken();
      if (token == null) {
        _log.w('No auth token found, skipping FCM token registration');
        return false;
      }

      final uri = Uri.parse(NotificiaonAPIController.fcmToken);
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'fcmToken': fcmToken,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _log.i('FCM token successfully sent to server');
        return true;
      } else {
        _log.w('Failed to send FCM token. Status: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      _log.e('Error sending FCM token to server: $e', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Delete FCM token from server (on logout)
  static Future<bool> deleteTokenFromServer() async {
    try {
      final token = await AuthLocalStorage.getToken();
      if (token == null) {
        _log.w('No auth token found, skipping FCM token deletion');
        return false;
      }

      final fcmToken = await getFCMToken();
      if (fcmToken == null) {
        _log.w('No FCM token found');
        return false;
      }

      final uri = Uri.parse(NotificiaonAPIController.fcmToken);
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'fcmToken': fcmToken,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _log.i('FCM token successfully deleted from server');
        return true;
      } else {
        _log.w('Failed to delete FCM token. Status: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      _log.e('Error deleting FCM token from server: $e', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}

/// Top-level function to handle background messages
/// This must be a top-level function, not a class method
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final logger = Logger();
  logger.i('Handling a background message: ${message.messageId}');
  logger.i('Message data: ${message.data}');
  if (message.notification != null) {
    logger.i('Message notification: ${message.notification}');
    
    // Initialize local notifications for background
    final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await localNotifications.initialize(initSettings);
    
    // Show notification
    final notification = message.notification;
    if (notification != null) {
      const androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await localNotifications.show(
        notification.hashCode,
        notification.title ?? 'New Notification',
        notification.body ?? '',
        details,
      );
    }
  }
}

