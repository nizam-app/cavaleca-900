// features/notifications/model/fs_notification.dart
import 'dart:convert';

class FsNotification {
  final int id;
  final String title;
  final String message;
  final String type;
  final int? referenceId;
  final DateTime createdAt;
  final String? createdAtFormatted;
  final bool isRead;
  final DateTime? readAt;
  final Map<String, dynamic>? data;

  const FsNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
    this.referenceId,
    this.createdAtFormatted,
    this.readAt,
    this.data,
  });

  factory FsNotification.fromJson(Map<String, dynamic> json) {
    // backend কখনো data, কখনো dataJson পাঠাচ্ছে – দুইটাই handle করলাম
    Map<String, dynamic>? parsedData;
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      parsedData = Map<String, dynamic>.from(json['data']);
    } else if (json['dataJson'] != null && json['dataJson'] is String) {
      try {
        parsedData = Map<String, dynamic>.from(
          jsonDecode(json['dataJson'] as String),
        );
      } catch (_) {}
    }

    return FsNotification(
      id: json['id'] as int,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      referenceId: json['referenceId'],
      createdAt: DateTime.parse(json['createdAt']),
      createdAtFormatted: json['createdAtFormatted'],
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      data: parsedData,
    );
  }

  FsNotification copyWith({bool? isRead, DateTime? readAt}) {
    return FsNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      referenceId: referenceId,
      createdAt: createdAt,
      createdAtFormatted: createdAtFormatted,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      data: data,
    );
  }
}
