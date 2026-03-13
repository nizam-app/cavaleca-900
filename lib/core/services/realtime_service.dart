import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:workpleis/core/constants/api_control/global_api.dart';

/// Socket.IO realtime service for technician jobs and notifications.
/// Connect with JWT after login; disconnect on logout.
/// See REALTIME_FLUTTER.md for server events.
class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  IO.Socket? _socket;

  /// Base URL for socket (same as REST API).
  static String get baseUrl => api;

  bool get isConnected => _socket?.connected ?? false;

  void connect(String jwtToken) {
    if (_socket?.connected == true) return;

    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setPath('/socket.io/')
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': jwtToken})
          .enableForceNew()
          .build(),
    );

    _socket!.onConnect((_) {
      // ignore: avoid_print
      print('Realtime: connected');
    });

    _socket!.onConnectError((err) {
      // ignore: avoid_print
      print('Realtime: connect_error $err');
    });

    _socket!.onDisconnect((_) {
      // ignore: avoid_print
      print('Realtime: disconnected');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  /// Call when JWT is refreshed (e.g. after login refresh).
  void updateTokenAndReconnect(String newJwt) {
    disconnect();
    connect(newJwt);
  }

  /// Listen for an event from server.
  void on(String event, void Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  /// Remove listener (optional, for cleanup).
  void off(String event) {
    _socket?.off(event);
  }
}
