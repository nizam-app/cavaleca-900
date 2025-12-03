// features/notifications/data/notifications_repository.dart
import 'dart:convert';

// features/notifications/logic/notifications_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:workpleis/core/constants/api_control/notificiaon_api.dart';
import 'package:workpleis/core/utils/global_save_login_data.dart';
import 'package:workpleis/features/notification/model/notification_model.dart';

class NotificationsRepository {
  final String baseUrl;
  final http.Client _client;

  NotificationsRepository({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  Future<Map<String, String>> _headers() async {
    final token = await AuthLocalStorage.getToken();
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET /api/notifications?unreadOnly=true/false
  Future<List<FsNotification>> fetchNotifications({
    bool unreadOnly = false,
  }) async {
    final query = unreadOnly ? '?unreadOnly=true' : '';
    final uri = Uri.parse(NotificiaonAPIController.notifications(query));

    final response = await _client.get(uri, headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception('Failed to load notifications');
    }

    final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;

    return jsonList
        .map((e) => FsNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// PATCH /api/notifications/{id}/read
  Future<FsNotification> markRead(int id) async {
    final uri = Uri.parse(NotificiaonAPIController.readNotifications(id));
    final response = await _client.patch(uri, headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }

    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
    return FsNotification.fromJson(json);
  }

  /// PATCH /api/notifications/read-all
  Future<void> markAllRead() async {
    final uri = Uri.parse(NotificiaonAPIController.all_read_Notifications);
    final response = await _client.patch(uri, headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception('Failed to mark all notifications as read');
    }
  }
}

const String _baseUrl = 'https://outside1backend.mtscorporate.com';

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepository(baseUrl: _baseUrl),
);

class NotificationsNotifier extends AsyncNotifier<List<FsNotification>> {
  @override
  Future<List<FsNotification>> build() async {
    final repo = ref.read(notificationsRepositoryProvider);
    return repo.fetchNotifications(unreadOnly: false);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(notificationsRepositoryProvider);
      return repo.fetchNotifications(unreadOnly: false);
    });
  }

  Future<void> markAsRead(int id) async {
    final current = state.value ?? [];
    final repo = ref.read(notificationsRepositoryProvider);

    try {
      final updated = await repo.markRead(id);
      state = AsyncValue.data([
        for (final n in current)
          if (n.id == id) updated else n,
      ]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAllAsRead() async {
    final current = state.value ?? [];
    final repo = ref.read(notificationsRepositoryProvider);

    try {
      await repo.markAllRead();
      state = AsyncValue.data([
        for (final n in current) n.copyWith(isRead: true),
      ]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<FsNotification>>(
      NotificationsNotifier.new,
    );
