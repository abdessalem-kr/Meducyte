import 'package:flutter/material.dart' show Color, debugPrint;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:meducyte_app/features/notifications/data/repositories/notification_repository.dart';
import 'package:meducyte_app/features/notifications/domain/models/notification.dart';
import 'package:meducyte_app/features/settings/providers/settings_provider.dart';
import 'package:meducyte_app/features/auth/application/providers/auth_provider.dart';
import 'package:meducyte_app/features/auth/application/providers/device_id_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';
import 'package:meducyte_app/core/routes/routes.dart';
import 'package:meducyte_app/core/routes/app_router.dart';

class NotificationService {
  final NotificationRepository _repository;
  final Ref _ref;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  Map<String, dynamic>? _pendingData;

  NotificationService(this._repository, this._ref) {
    // Listen for app readiness to process pending notifications
    _ref.listen<bool>(routerNotifierProvider.select((n) => n.isReady), (
      previous,
      next,
    ) {
      if (next && _pendingData != null) {
        final data = _pendingData!;
        _pendingData = null;
        debugPrint('DEBUG: App ready, processing pending notification launch');
        Future.delayed(const Duration(milliseconds: 500), () {
          navigateToContext(data);
        });
      }
    });
  }

  /// Checks if system-level notification permission is granted
  Future<bool> isPermissionGranted() async {
    try {
      if (kIsWeb) return true;
      
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      final isFCMAuthorized = settings.authorizationStatus == AuthorizationStatus.authorized ||
                              settings.authorizationStatus == AuthorizationStatus.provisional;
      
      if (!isFCMAuthorized) return false;

      // Platform specific check for local notifications
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidImplementation = _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        return await androidImplementation?.areNotificationsEnabled() ?? false;
      }
      
      return true;
    } catch (e) {
      debugPrint('DEBUG: Error checking notification permission: $e');
      return false;
    }
  }

  /// Opens the device system settings for this app
  Future<void> openSettings() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        // We'll try the generic 'app-settings:' which works on both Android (via some plugins or if handled by system)
        // or a specific intent if we had android_intent. Since we use url_launcher, app-settings: is the safest bet for iOS.
        // For Android, we can try package:com.meducyte.app
        final Uri uri = Uri.parse('app-settings:');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      } else {
        await launchUrl(Uri.parse('app-settings:'));
      }
    } catch (e) {
      debugPrint('DEBUG: Error opening settings: $e');
    }
  }

  /// Initializes remote notifications (e.g., FCM)
  Future<void> initRemoteNotifications() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // 1. Request permissions (iOS/Web)
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Ensure foreground notifications show up as push popups (Heads-Up)
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized || 
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // 2. Setup Local Notifications for foreground messages
        const initSettingsAndroid = AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        );
        const initSettingsIOS = DarwinInitializationSettings();
        const initSettings = InitializationSettings(
          android: initSettingsAndroid,
          iOS: initSettingsIOS,
        );

        await _localNotifications.initialize(
          settings: initSettings,
          onDidReceiveNotificationResponse: _onLocalNotificationTap,
        );

        // 3. Setup Android foreground notification channel
        const channels = [
          AndroidNotificationChannel(
            'high_importance_channel',
            'High Importance Notifications',
            description: 'This channel is used for important notifications.',
            importance: Importance.max,
          ),
          AndroidNotificationChannel(
            'productive_bay_reminders',
            'Productive Bay Reminders',
            description: 'Reminders for your tasks, exams, and study sessions.',
            importance: Importance.max,
          ),
        ];

        final platformPlugin = _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        
        for (final channel in channels) {
          await platformPlugin?.createNotificationChannel(channel);
        }

        // 4. Listen to foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          handleMessage(message, channel: channels.first);
        });

        // 5. Handle background/terminated message taps
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          _handleMessageTap(message);
        });

        // Also check if app was opened from a terminated state
        final initialMessage = await FirebaseMessaging.instance
            .getInitialMessage();
        if (initialMessage != null) {
          _handleMessageTap(initialMessage);
        }

        // 6. Get device token
        String? token;
        try {
          if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
            final apnsToken = await messaging.getAPNSToken();
            if (apnsToken == null) {
              debugPrint('DEBUG: APNS token not yet available.');
            } else {
              token = await messaging.getToken();
            }
          } else {
            token = await messaging.getToken();
          }

          if (token != null) {
            debugPrint('DEBUG: FCM Token: $token');
            final authRepo = _ref.read(authRepositoryProvider);
            final deviceId = await _ref.read(deviceIdProvider.future);
            await authRepo.updateFcmToken(token, deviceId);
            debugPrint('DEBUG: FCM Token registered with backend');
          }
        } catch (e) {
          debugPrint(
            'DEBUG: FCM Token retrieval failed (expected on simulator): $e',
          );
        }
      }
    } catch (e) {
      debugPrint('DEBUG: Failed to initialize remote notifications: $e');
    }
  }

  Future<void> handleMessage(
    RemoteMessage message, {
    AndroidNotificationChannel? channel,
  }) async {
    // Only show if notifications are enabled
    final appSettings = _ref.read(appSettingsProvider);
    if (!appSettings.notificationsEnabled) return;

    final notification = message.notification;
    final android = message.notification?.android;
    final data = message.data;

    // 1. Save to local DB (scoped to user)
    await addNotification(
      remoteId: message.messageId,
      title: notification?.title ?? data['title'] ?? 'New Notification',
      body: notification?.body ?? data['body'] ?? '',
      type: _parseType(data['type']),
      data: data,
    );

    // 2. Show popup (if not on web)
    if (!kIsWeb) {
      // Use provided channel or fall back to a default one if needed
      final targetChannelId =
          channel?.id ??
          data['android_channel_id'] ??
          'high_importance_channel';

      await _localNotifications.show(
        id: notification?.hashCode ?? message.messageId.hashCode,
        title: notification?.title ?? data['title'] ?? 'New Notification',
        body: notification?.body ?? data['body'] ?? '',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            targetChannelId,
            channel?.name ?? 'High Importance Notifications',
            channelDescription:
                channel?.description ??
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(data),
      );
    }
  }

  void _handleMessageTap(RemoteMessage message) {
    debugPrint('DEBUG: Notification tapped (FCM). Data: ${message.data}');
    navigateToContext(message.data);
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        debugPrint('DEBUG: Notification tapped (Local). Payload: $data');
        navigateToContext(data);
      } catch (e) {
        debugPrint('DEBUG: Error parsing local notification payload: $e');
      }
    }
  }

  void navigateToContext(Map<String, dynamic> data) {
    final routerNotifier = _ref.read(routerNotifierProvider);
    if (!routerNotifier.isReady) {
      debugPrint('DEBUG: App not ready, queueing notification data');
      _pendingData = data;
      return;
    }

    String? route = data['route'] as String?;
    String? id = data['id']?.toString();
    final type = data['type']?.toString();

    // Infer route from type if missing
    if (route == null && type != null) {
      if (type == 'comment_reply' || type == 'community') {
        if (data.containsKey('question_id')) {
          route = AppRoutes.quizSession;
        } else if (data.containsKey('lesson_id')) {
          route = AppRoutes.courseReader;
          id = data['lesson_id']?.toString();
        } else if (data.containsKey('course_id')) {
          route = AppRoutes.courseReader;
          id = data['course_id']?.toString();
        }
      }
    }

    final router = _ref.read(goRouterProvider);

    if (route != null) {
      debugPrint('DEBUG: Navigating to route: $route, id: $id');
      if (route == AppRoutes.courseReader && id != null) {
        final commentId = data['comment_id']?.toString();
        final path = AppRoutes.courseReader.replaceAll(':id', id);
        if (commentId != null) {
          router.push('$path?commentId=$commentId');
        } else {
          router.push(path);
        }
      } else if (route == AppRoutes.moduleLessons && id != null) {
        router.push(AppRoutes.moduleLessons.replaceAll(':id', id));
      } else if (route == AppRoutes.quizSession) {
        final questionId =
            data['question_id']?.toString() ?? data['id']?.toString();
        final commentId = data['comment_id']?.toString();
        String path = AppRoutes.quizSession;
        if (questionId != null || commentId != null) {
          path += '?';
          if (questionId != null) path += 'questionId=$questionId';
          if (commentId != null) {
            if (questionId != null) path += '&';
            path += 'commentId=$commentId';
          }
        }
        router.push(path);
      } else if (route == AppRoutes.specialtyCourses && id != null) {
        router.push(
          AppRoutes.specialtyCourses.replaceAll(':specialtyName', id),
        );
      } else if (route == AppRoutes.quizTraining) {
        router.push(AppRoutes.quizTraining);
      } else if (route == AppRoutes.simulation) {
        router.push(AppRoutes.simulation);
      } else if (route == AppRoutes.ecgHelper) {
        router.push(AppRoutes.ecgHelper);
      } else if (route == AppRoutes.radiologyHelper) {
        router.push(AppRoutes.radiologyHelper);
      } else if (route == AppRoutes.labHelper) {
        router.push(AppRoutes.labHelper);
      } else if (route == AppRoutes.medicalCalculator) {
        router.push(AppRoutes.medicalCalculator);
      } else if (route == AppRoutes.notifications) {
        router.push(AppRoutes.notifications);
      } else if (route == AppRoutes.productiveBay) {
        router.push(AppRoutes.productiveBay);
      } else {
        debugPrint('DEBUG: Unhandled notification route: $route');
      }
    } else {
      debugPrint('DEBUG: Notification data has no route: $data');
    }
  }

  NotificationType _parseType(String? typeStr) {
    if (typeStr == null) return NotificationType.system;
    return NotificationType.values.firstWhere(
      (e) => e.name == typeStr.toLowerCase(),
      orElse: () => NotificationType.system,
    );
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    // 1. Add to database
    await addNotification(
      title: title,
      body: body,
      type: type,
      data: data,
    );

    // 2. Show native popup (unless on web)
    if (!kIsWeb) {
      await _localNotifications.show(
        id: title.hashCode ^ body.hashCode,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: data != null ? jsonEncode(data) : null,
      );
    }
  }

  Future<void> addNotification({
    String? remoteId,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    final settings = _ref.read(appSettingsProvider);

    // Only persist if notifications are enabled
    if (!settings.notificationsEnabled) return;

    final userId = _ref.read(authControllerProvider).value?.id.toString();
    if (userId == null) {
      debugPrint('DEBUG: Skipping notification persist - no active user');
      return;
    }

    final notification = AppNotification(
      id: '', // DB will auto-generate
      remoteId: remoteId,
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
      isRead: false,
      data: data,
    );

    try {
      await _repository.insertNotification(notification, userId);
    } catch (e) {
      debugPrint('DEBUG: Error inserting notification: $e');
    }
  }

  // Helper methods for common notification types
  Future<void> notifyContent(
    String title,
    String body, {
    Map<String, dynamic>? data,
  }) => addNotification(
    title: title,
    body: body,
    type: NotificationType.content,
    data: data,
  );

  Future<void> notifyCommunity(
    String title,
    String body, {
    Map<String, dynamic>? data,
  }) => addNotification(
    title: title,
    body: body,
    type: NotificationType.community,
    data: data,
  );

  Future<void> notifyPerformance(
    String title,
    String body, {
    Map<String, dynamic>? data,
  }) => addNotification(
    title: title,
    body: body,
    type: NotificationType.performance,
    data: data,
  );

  Future<void> notifySystem(
    String title,
    String body, {
    Map<String, dynamic>? data,
  }) => addNotification(
    title: title,
    body: body,
    type: NotificationType.system,
    data: data,
  );

  /// Schedules a local notification for a study event
  Future<void> scheduleStudyReminder({
    required String id,
    required String title,
    required DateTime scheduledDate,
  }) async {
    if (kIsWeb) return;

    // Schedule 10 minutes before
    final reminderTime = scheduledDate.subtract(const Duration(minutes: 10));
    if (reminderTime.isBefore(DateTime.now())) return;

    try {
      await _localNotifications.zonedSchedule(
        id: id.hashCode,
        title: 'Rappel Étude: $title',
        body: 'Votre séance commence dans 10 minutes.',
        scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'productive_bay_reminders',
            'Productive Bay Reminders',
            channelDescription: 'Rappels pour vos séances d\'étude planifiées',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: jsonEncode({'route': AppRoutes.productiveBay, 'id': id}),
      );
      debugPrint('DEBUG: Study Notification scheduled for $reminderTime');
    } catch (e) {
      debugPrint('DEBUG: Error scheduling notification: $e');
    }
  }

  /// Schedules a notification for a task deadline
  Future<void> scheduleTaskReminder({
    required String id,
    required String title,
    required DateTime deadline,
  }) async {
    if (kIsWeb) return;

    // Reminder 1 hour before deadline
    final reminderTime = deadline.subtract(const Duration(hours: 1));
    if (reminderTime.isBefore(DateTime.now())) {
      // If deadline is soon, try 5 mins before
      final nearFuture = DateTime.now().add(const Duration(minutes: 5));
      if (deadline.isBefore(nearFuture)) return;
    }

    try {
      await _localNotifications.zonedSchedule(
        id: id.hashCode,
        title: 'Échéance: $title',
        body: 'Votre tâche doit être terminée dans 1 heure.',
        scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'productive_bay_reminders',
            'Productive Bay Reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: jsonEncode({'route': AppRoutes.productiveBay, 'id': id}),
      );
      debugPrint('DEBUG: Task reminder scheduled for $reminderTime');
    } catch (e) {
      debugPrint('DEBUG: Error scheduling task reminder: $e');
    }
  }

  /// Schedules a notification for an exam (24 hours before)
  Future<void> scheduleExamReminder({
    required String id,
    required String title,
    required DateTime examDate,
  }) async {
    if (kIsWeb) return;

    // 1. Reminder 24 hours before
    final reminderTimeRow = examDate.subtract(const Duration(days: 1));
    final reminderTime = reminderTimeRow.isBefore(DateTime.now())
        ? DateTime.now().add(const Duration(minutes: 30)) // If tomorrow, remind in 30 mins
        : reminderTimeRow;

    if (reminderTime.isBefore(DateTime.now())) return;

    try {
      await _localNotifications.zonedSchedule(
        id: id.hashCode,
        title: 'Examen Demain: $title',
        body: 'Vérifiez vos fiches une dernière fois !',
        scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'productive_bay_reminders',
            'Productive Bay Reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: jsonEncode({'route': AppRoutes.productiveBay, 'id': id}),
      );
      debugPrint('DEBUG: Exam reminder scheduled for $reminderTime');
    } catch (e) {
      debugPrint('DEBUG: Error scheduling exam reminder: $e');
    }
  }

  Future<void> cancelStudyReminder(String id) async {
    await _localNotifications.cancel(id: id.hashCode);
  }

  Future<void> cancelNotification(String id) async {
    await _localNotifications.cancel(id: id.hashCode);
  }

  /// Simulates a notification for testing (e.g., on simulators)
  Future<void> simulateNotification() async {
    final message = RemoteMessage(
      messageId: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      data: {
        'type': 'comment_reply',
        'title': 'New Reply to Your Comment',
        'body': '"This is a simulated notification for testing purposes."',
      },
      notification: const RemoteNotification(
        title: 'New Reply to Your Comment',
        body: '"This is a simulated notification for testing purposes."',
      ),
    );

    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
    );

    await handleMessage(message, channel: channel);
  }

  /// Shows a persistent notification for an active Pomodoro session
  Future<void> showPomodoroNotification({
    required String title,
    required Duration remainingDuration,
    required bool isWork,
  }) async {
    if (kIsWeb) return;

    // Use a chronometer to let Android handle the countdown natively
    final targetTime = DateTime.now().add(remainingDuration);

    final androidDetails = AndroidNotificationDetails(
      'pomodoro_v14_final',
      'Minuteur de Concentration',
      channelDescription: 'Minuteur Pomodoro (Natif & Silencieux)',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      onlyAlertOnce: true,
      showWhen: true,
      when: targetTime.millisecondsSinceEpoch,
      usesChronometer: true,
      chronometerCountDown: true,
      playSound: false,
      enableVibration: false,
      category: AndroidNotificationCategory.status,
      color: isWork ? const Color(0xFFFF5252) : const Color(0xFF4CAF50),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    await _localNotifications.show(
      id: 999,
      title: title,
      body: isWork
          ? "Séance en cours (Timer en haut à droite)"
          : "Pause en cours (Timer en haut à droite)",
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
    );
  }

  Future<void> dismissPomodoroNotification() async {
    if (kIsWeb) return;
    await _localNotifications.cancel(id: 999);
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationService(repository, ref);
});
