import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/calendar_models.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/todo_item.dart';
import 'package:meducyte_app/features/productive_bay/presentation/widgets/os_widget_ui.dart';

class WidgetService {
  static const String androidWidgetName = 'ProductiveBayWidget';
  static const String statsWidgetName = 'StudyStatsWidget';

  //Keys for data
  static const String keyScheduleImage = 'schedule_image_path';
  static const String keyStatsImage = 'stats_image_path';

  ///Updates the OS Home Screen widgets with high-fidelity Flutter-rendered images
  static Future<void> updateWidget({
    StudyEvent? nextEvent,
    int? pendingTasks,
    TodoItem? urgentTask,
    String? nextExam,
    int? daysToExam,
    int? pomodoroDone,
    int? pomodoroGoal,
    String? focusScore,
  }) async {
    try {
      //Ensure group ID is set for iOS screenshot rendering
      await HomeWidget.setAppGroupId('group.com.example.meducyte_app');
      //1.Render Schedule Widget
      final schedulePath = await HomeWidget.renderFlutterWidget(
        OSScheduleWidget(
          nextEventTitle: nextEvent?.title,
          nextEventTime: nextEvent != null
              ? "${nextEvent.startTime.hour.toString().padLeft(2, '0')}:${nextEvent.startTime.minute.toString().padLeft(2, '0')}"
              : null,
          pendingTaskCount: pendingTasks,
          urgentTaskTitle: urgentTask?.title,
        ),
        key: keyScheduleImage,
        pixelRatio: 3.0, //High density for S24 Ultra
      );
      if (schedulePath != null) {
        await HomeWidget.saveWidgetData(keyScheduleImage, schedulePath);
      }

      //2.Render Stats Widget
      final statsPath = await HomeWidget.renderFlutterWidget(
        OSStatsWidget(
          nextExamTitle: nextExam,
          daysToExam: daysToExam,
          pomodorosDone: pomodoroDone,
          pomodorosGoal: pomodoroGoal,
          focusScore: focusScore,
        ),
        key: keyStatsImage,
        pixelRatio: 3.0,
      );
      if (statsPath != null) {
        await HomeWidget.saveWidgetData(keyStatsImage, statsPath);
      }

      //3.Trigger updates
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        androidName: androidWidgetName,
        iOSName: 'ProductiveBayWidget',
      );

      await HomeWidget.updateWidget(
        name: statsWidgetName,
        androidName: statsWidgetName,
        iOSName: 'StudyStatsWidget',
      );

      debugPrint('DEBUG:Home Screen Widgets rendered and updated');
    } catch (e) {
      debugPrint('DEBUG:Error rendering OS Widgets: $e');
    }
  }
}
