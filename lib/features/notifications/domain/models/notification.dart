import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:drift/drift.dart';
import 'package:meducyte_app/core/database/app_database.dart';

enum NotificationType {
  content, // New courses, books, etc.
  community, // General community updates
  commentReply, // Replies to comments
  system, // App updates, maintenance
  performance, // Quiz milestones, streaks
}

class AppNotification extends Equatable {
  final String id;
  final String? remoteId;
  final String? userId;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;
  final Map<String, dynamic>? data; // For deep linking or extra info

  const AppNotification({
    required this.id,
    this.remoteId,
    this.userId,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    required this.type,
    this.data,
  });

  factory AppNotification.fromDb(DbNotification db) {
    return AppNotification(
      id: db.id.toString(),
      remoteId: db.remoteId,
      userId: db.userId,
      title: db.title,
      body: db.body,
      timestamp: db.timestamp,
      isRead: db.isRead,
      type: NotificationType.values.firstWhere(
        (e) => e.name.toLowerCase().replaceAll('_', '') == db.type.toLowerCase().replaceAll('_', ''),
        orElse: () => NotificationType.system,
      ),
      data: db.data != null
          ? jsonDecode(db.data!) as Map<String, dynamic>
          : null,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? dataMap;
    if (json['data'] is String) {
      try {
        dataMap = jsonDecode(json['data'] as String) as Map<String, dynamic>;
      } catch (_) {}
    } else if (json['data'] is Map) {
      dataMap = Map<String, dynamic>.from(json['data'] as Map);
    }

    // If no nested data map, or if we want to ensure top-level keys are included
    dataMap ??= {};

    // Add important top-level keys to dataMap if they exist and aren't already there
    final importantKeys = ['route', 'id', 'comment_id', 'question_id', 'type'];
    for (final key in importantKeys) {
      if (json.containsKey(key) && !dataMap.containsKey(key)) {
        dataMap[key] = json[key];
      }
    }

    final typeStr = json['type']?.toString().toLowerCase().replaceAll('_', '') ?? 'system';

    return AppNotification(
      id: json['id']?.toString() ?? '',
      remoteId: json['remoteId']?.toString() ?? json['id']?.toString(),
      userId: json['userId']?.toString(),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      timestamp: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : (json['timestamp'] != null
                ? DateTime.parse(json['timestamp'].toString())
                : DateTime.now()),
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      type: NotificationType.values.firstWhere(
        (e) => e.name.toLowerCase().replaceAll('_', '') == typeStr,
        orElse: () => NotificationType.system,
      ),
      data: dataMap.isEmpty ? null : dataMap,
    );
  }

  NotificationsCompanion toCompanion() {
    return NotificationsCompanion.insert(
      remoteId: Value(remoteId),
      userId: Value(userId),
      title: title,
      body: body,
      timestamp: Value(timestamp),
      isRead: Value(isRead),
      type: type.name,
      data: Value(data != null ? jsonEncode(data) : null),
    );
  }

  AppNotification copyWith({
    String? id,
    String? remoteId,
    String? userId,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    NotificationType? type,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [
    id,
    remoteId,
    userId,
    title,
    body,
    timestamp,
    isRead,
    type,
    data,
  ];
}
