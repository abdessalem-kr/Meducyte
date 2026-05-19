import 'package:meducyte_app/features/notifications/domain/models/notification.dart';

final List<AppNotification> mockNotifications = [
  AppNotification(
    id: '1',
    title: 'New Course Available!',
    body: 'Master Cardiology with our new advanced hemodynamics course.',
    timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    type: NotificationType.content,
    isRead: false,
  ),
  AppNotification(
    id: '2',
    title: 'New Reply',
    body: 'Dr.Sarah replied to your comment on the ECG interpretation quiz.',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    type: NotificationType.community,
    isRead: false,
  ),
  AppNotification(
    id: '3',
    title: 'Quiz Milestone!',
    body: "You've completed 100 oncology questions this week.Keep it up!",
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    type: NotificationType.performance,
    isRead: true,
  ),
  AppNotification(
    id: '4',
    title: 'System Update',
    body: 'Meducyte v1.2.0 is now live with improved radiology helpers.',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    type: NotificationType.system,
    isRead: true,
  ),
  AppNotification(
    id: '5',
    title: 'Book Added',
    body:
        "The 22nd edition of Harrison's Principles of Internal Medicine is now in the library.",
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    type: NotificationType.content,
    isRead: true,
  ),
];
