import 'package:meducyte_app/export.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:home_widget/home_widget.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meducyte_app/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'dart:convert';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

// Focus & Fatigue / Notifications Imports
import 'package:meducyte_app/features/productive_bay/application/services/fatigue_notification_observer.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //Initialize Firebase for the background isolate
  await Firebase.initializeApp();

  final data = message.data;
  final notification = message.notification;

  if (notification != null || data.isNotEmpty) {
    //1.Show local notification ONLY IF the OS didn't already display it natively.
    if (notification == null && data.isNotEmpty) {
      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      const initializationSettingsAndroid = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const initializationSettingsIOS = DarwinInitializationSettings();
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
      );

      final channelId = data['android_channel_id'] ?? 'high_importance_channel';

      await flutterLocalNotificationsPlugin.show(
        id: message.messageId.hashCode,
        title: data['title'] ?? 'New Notification',
        body: data['body'] ?? '',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
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

    //2.Save to database(Scoped to user)
    try {
      //Retrieve the cached user ID for scoping
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('cached_user');
      String? userId;
      if (userJson != null) {
        try {
          final Map<String, dynamic> userMap = jsonDecode(userJson);
          userId = userMap['id']?.toString();
        } catch (_) {}
      }

      final db = AppDatabase();
      final typeStr = data['type']?.toString().toLowerCase() ?? 'system';

      await db.insertNotification(
        NotificationsCompanion.insert(
          remoteId: Value(message.messageId),
          userId: Value(userId), //Scoping to the last active user
          title: notification?.title ?? data['title'] ?? 'New Notification',
          body: notification?.body ?? data['body'] ?? '',
          timestamp: Value(DateTime.now()),
          isRead: const Value(false),
          type: typeStr,
          data: Value(data.isNotEmpty ? jsonEncode(data) : null),
        ),
      );
      await db.close();
    } catch (e) {
      debugPrint('Error saving background notification: $e');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Set App Group ID for Home Screen Widgets(iOS requirement)
  await HomeWidget.setAppGroupId('group.com.example.meducyte_app');

  try {
    await Firebase.initializeApp();
    //Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint(
      'Firebase initialization failed: $e.Make sure config files are set up.',
    );
  }

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    setWindowMinSize(const Size(400, 720)); // ✅min width/height
  }

  //Initialize Timezones for scheduled notifications
  tz.initializeTimeZones();
  final timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName.identifier));

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch global fatigue notifications observer
    ref.watch(fatigueNotificationObserverProvider);

    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(goRouterProvider);
    final highContrast = ref.watch(
      appSettingsProvider.select((s) => s.highContrastEnabled),
    );
    final fontSizeStr = ref.watch(
      appSettingsProvider.select((s) => s.fontSize),
    );

    double fontScale = 1.0;
    if (fontSizeStr == 'Small' || fontSizeStr == 'Petit') {
      fontScale = 0.85;
    } else if (fontSizeStr == 'Large' || fontSizeStr == 'Grand') {
      fontScale = 1.2;
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: getLightTheme(highContrast: highContrast),
      darkTheme: getDarkTheme(highContrast: highContrast),
      routerConfig: router,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('fr')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (deviceLocale != null) {
          for (var locale in supportedLocales) {
            if (locale.languageCode == deviceLocale.languageCode) {
              return deviceLocale;
            }
          }
        }
        return supportedLocales.first;
      },
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: TextScaler.linear(fontScale)),
          child: child!,
        );
      },
    );
  }
}
