import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/notifications/application/services/notification_service.dart';
import 'package:meducyte_app/features/notifications/domain/models/notification.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/fatigue_provider.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/analytics_models.dart';

final fatigueNotificationObserverProvider = Provider<void>((ref) {
  ref.listen<FatigueStatus>(fatigueStatusProvider, (previous, next) {
    final settings = ref.read(appSettingsProvider);
    if (!settings.notificationsEnabled || !settings.fatigueNotificationsEnabled) {
      return;
    }
    if (previous != null && previous.level != next.level) {
      if (next.level != FatigueLevel.tired && next.level != FatigueLevel.exhausted) {
        return;
      }
      final notificationService = ref.read(notificationServiceProvider);
      final locale = ref.read(localeProvider);
      final isFr = locale.languageCode == 'fr';

      String title;
      String body;
      NotificationType type = NotificationType.performance;

      switch (next.level) {
        case FatigueLevel.peak:
          title = isFr ? "Concentration maximale ! 🚀" : "Peak Focus! 🚀";
          body = isFr 
              ? "Vous êtes au top de vos capacités. Moment idéal pour les sujets complexes." 
              : "You are at your cognitive peak. Excellent time for complex topics.";
          break;
        case FatigueLevel.optimal:
          title = isFr ? "Concentration optimale 🧠" : "Optimal Concentration 🧠";
          body = isFr 
              ? "Votre concentration est stable. Gardez ce rythme !" 
              : "Your focus is stable. Keep up the good work!";
          break;
        case FatigueLevel.tired:
          title = isFr ? "Attention à la fatigue ☕" : "Fatigue Warning ☕";
          body = isFr 
              ? "Fatigue légère détectée. Envisagez une pause ou changez de sujet." 
              : "Light fatigue detected. Consider a break or changing subjects.";
          break;
        case FatigueLevel.exhausted:
          title = isFr ? "Repos requis ! 🛑" : "Rest Required! 🛑";
          body = isFr 
              ? "Votre niveau d'épuisement est élevé. Prenez une pause immédiatement." 
              : "Your fatigue level is high. Take a break immediately.";
          break;
      }

      notificationService.showLocalNotification(
        title: title,
        body: body,
        type: type,
        data: {'route': AppRoutes.productiveBay},
      );
    }
  });
});
