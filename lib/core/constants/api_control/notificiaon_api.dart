import 'global_api.dart';

class NotificiaonAPIController {
  static String _base_api = "$api/api";
  static String notifications(query) => "${_base_api}/notifications?$query";
  static String readNotifications(id) => "${_base_api}/notifications/$id/read";
  static String all_read_Notifications = "${_base_api}/notifications/read-all";
}
