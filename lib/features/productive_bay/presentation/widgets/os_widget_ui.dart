import 'package:meducyte_app/export.dart';

///These widgets are designed specifically for rendering to PNG
///and being displayed as OS Home Screen widgets via the home_widget package.
///They use the exact same UI patterns as the main app.

class OSScheduleWidget extends StatelessWidget {
  final String? nextEventTitle;
  final String? nextEventTime;
  final int? pendingTaskCount;
  final String? urgentTaskTitle;

  //Localized Labels
  final String nextSessionLabel;
  final String noSessionLabel;
  final String urgentLabel;
  final String noUrgentTaskLabel;

  const OSScheduleWidget({
    super.key,
    this.nextEventTitle,
    this.nextEventTime,
    this.pendingTaskCount,
    this.urgentTaskTitle,
    this.nextSessionLabel = "PROCHAINE SESSION",
    this.noSessionLabel = "Aucune session",
    this.urgentLabel = "URGENT",
    this.noUrgentTaskLabel = "Pas de tâches",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Productive Bay",
                style: TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (pendingTaskCount != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "$pendingTaskCount tâches",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            nextSessionLabel,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          Text(
            nextEventTitle ?? noSessionLabel,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            nextEventTime ?? "--:--",
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const Spacer(),
          Text(
            urgentLabel,
            style: const TextStyle(
              color: AppColors.errorLight,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          Text(
            urgentTaskTitle ?? noUrgentTaskLabel,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class OSStatsWidget extends StatelessWidget {
  final String? nextExamTitle;
  final int? daysToExam;
  final int? pomodorosDone;
  final int? pomodorosGoal;
  final String? focusScore;

  //Localized Labels
  final String daysLabel;
  final String nextExamLabel;
  final String noExamLabel;
  final String pomodoroLabel;
  final String focusLabel;

  const OSStatsWidget({
    super.key,
    this.nextExamTitle,
    this.daysToExam,
    this.pomodorosDone,
    this.pomodorosGoal,
    this.focusScore,
    this.daysLabel = "jours",
    this.nextExamLabel = "PROCHAIN EXAMEN",
    this.noExamLabel = "Pas d'examen",
    this.pomodoroLabel = "POMODOROS",
    this.focusLabel = "FOCUS",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          //Left:Countdown Circle
          Expanded(
            flex: 4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: daysToExam != null ? (daysToExam! % 30) / 30 : 0,
                    strokeWidth: 8,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      daysToExam?.toString() ?? "--",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      daysLabel,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          //Right:Details
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  nextExamLabel,
                  style: const TextStyle(
                    color: Colors.purple,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  nextExamTitle ?? noExamLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  pomodoroLabel,
                  "${pomodorosDone ?? 0}/${pomodorosGoal ?? 8}",
                  AppColors.primary,
                ),
                const SizedBox(height: 8),
                _buildStatRow(
                  focusLabel,
                  focusScore ?? "0%",
                  AppColors.secondaryLight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 7,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
