import 'dart:ui';
import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/productive_bay/presentation/widgets/exam_countdown_widget.dart';
import 'package:meducyte_app/features/productive_bay/presentation/widgets/fatigue_tracker_widget.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/ambient_sound_provider.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/bay_settings_provider.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/pomodoro_settings_provider.dart';
import 'package:meducyte_app/features/productive_bay/presentation/widgets/ai_scheduler_widget.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/pomodoro_provider.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/pomodoro_models.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/settings_models.dart';

import 'package:meducyte_app/features/productive_bay/presentation/widgets/live_sessions_carousel.dart';

class ProductiveBayPage extends ConsumerWidget {
  const ProductiveBayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(baySettingsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.productiveBayTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.setting_4),
            onPressed: () => context.pushNamed(AppRoutes.customizeBay),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          const LiveSessionsCarousel(),
          for (final section in sections)
            if (section.isEnabled)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSection(context, ref, section),
              ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    WidgetRef ref,
    BaySection section,
  ) {
    switch (section.type) {
      case BaySectionType.fatigueTracker:
        return _wrapSection(
          context,
          context.l10n.focusFatigueAnalysis,
          Iconsax.mask,
          const FatigueTrackerWidget(),
        );
      case BaySectionType.navigationHub:
        return _wrapSection(
          context,
          context.l10n.dashboardHub,
          Iconsax.category,
          _buildNavigationHub(context, ref),
        );
      case BaySectionType.pomodoroTimer:
        return _wrapSection(
          context,
          context.l10n.deepWorkMode,
          Iconsax.timer_1,
          const PomodoroTimer(),
        );
      case BaySectionType.examCountdown:
        return _wrapSection(
          context,
          context.l10n.examCountdown,
          Iconsax.clock,
          const ExamCountdownWidget(),
        );
      case BaySectionType.aiScheduler:
        return _wrapSection(
          context,
          context.l10n.aiPlanner,
          Iconsax.magic_star,
          const AiSchedulerWidget(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _wrapSection(
    BuildContext context,
    String title,
    IconData icon,
    Widget child,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildNavigationHub(BuildContext context, WidgetRef ref) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildNavCard(
          context,
          title: context.l10n.planner,
          subtitle: "Schedule&AI",
          icon: Iconsax.calendar_2,
          color: Colors.blue,
          onTap: () => context.pushNamed(AppRoutes.planner),
        ),
        _buildNavCard(
          context,
          title: context.l10n.myTasks,
          subtitle: ref
              .watch(productiveBayProvider)
              .when(
                data: (tasks) {
                  final urgent = tasks
                      .where((t) => t.priority == TodoPriority.urgent)
                      .length;
                  return context.l10n.urgentTasksCount(urgent);
                },
                loading: () => context.l10n.loading,
                error: (_, __) => "Tasks",
              ),
          icon: Iconsax.task,
          color: Colors.green,
          onTap: () => context.pushNamed(AppRoutes.tasks),
        ),
        _buildNavCard(
          context,
          title: context.l10n.analytics,
          subtitle: "Study Patterns",
          icon: Iconsax.chart_21,
          color: Colors.purple,
          onTap: () => context.pushNamed(AppRoutes.analytics),
        ),
        _buildNavCard(
          context,
          title: context.l10n.groups,
          subtitle: "Study Together",
          icon: Iconsax.people,
          color: AppColors.primary,
          onTap: () => context.pushNamed(AppRoutes.studyGroups),
        ),
      ],
    );
  }

  Widget _buildNavCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.1), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PomodoroTimer extends ConsumerStatefulWidget {
  const PomodoroTimer({super.key});

  @override
  ConsumerState<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _SmartSound {
  final String id;
  final String name;
  final IconData icon;
  _SmartSound(this.id, this.name, this.icon);
}

class _PomodoroTimerState extends ConsumerState<PomodoroTimer> {
  @override
  Widget build(BuildContext context) {
    final session = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final minutes = (session.remainingSeconds / 60).floor();
    final seconds = session.remainingSeconds % 60;

    //Get active task title if any
    String? taskTitle;
    if (session.taskId != null) {
      final tasks = ref.watch(productiveBayProvider).value ?? [];
      try {
        taskTitle = tasks.firstWhere((t) => t.id == session.taskId).title;
      } catch (_) {}
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getGradientColors(session.type, theme),
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color:
                (session.type == PomodoroSessionType.work
                        ? theme.primaryColor
                        : (session.type == PomodoroSessionType.shortBreak
                              ? Colors.green
                              : Colors.blue))
                    .withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSessionBadge(session.type),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () =>
                              _showSettingsBottomSheet(context, ref),
                          icon: const Icon(
                            Iconsax.setting_2,
                            color: Colors.white70,
                          ),
                          tooltip: "Paramètres",
                        ),
                        IconButton(
                          onPressed: () =>
                              context.pushNamed(AppRoutes.deepWork),
                          icon: const Icon(
                            Iconsax.maximize_3,
                            color: Colors.white,
                          ),
                          tooltip: "Pleinécran",
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (taskTitle != null)
                  Text(
                    taskTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                Text(
                  "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}",
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildControlButton(
                      onPressed: () {
                        if (session.state == PomodoroState.running) {
                          notifier.pauseSession();
                        } else {
                          notifier.startSession();
                        }
                      },
                      icon: session.state == PomodoroState.running
                          ? Iconsax.pause
                          : Iconsax.play,
                      label: session.state == PomodoroState.running
                          ? l10n.pause
                          : l10n.start,
                    ),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => notifier.stopSession(),
                        icon: const Icon(
                          Iconsax.refresh,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSoundSelector(theme, [
                  _SmartSound('Forest', l10n.forest, Iconsax.tree),
                  _SmartSound('Rain', l10n.rain, Iconsax.cloud_drizzle),
                  _SmartSound('Waves', l10n.waves, Iconsax.reserve),
                  _SmartSound('Wind', l10n.wind, Iconsax.wind),
                  _SmartSound('Cafe', l10n.cafe, Iconsax.coffee),
                  _SmartSound('Library', l10n.library, Iconsax.book_1),
                  _SmartSound('Brown Noise', l10n.brownNoise, Iconsax.speaker),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors(PomodoroSessionType type, ThemeData theme) {
    switch (type) {
      case PomodoroSessionType.work:
        return [theme.primaryColor, theme.primaryColor.withOpacity(0.8)];
      case PomodoroSessionType.shortBreak:
        return [Colors.green.shade600, Colors.green.shade400];
      case PomodoroSessionType.longBreak:
        return [Colors.blue.shade700, Colors.blue.shade500];
    }
  }

  Widget _buildSessionBadge(PomodoroSessionType type) {
    String label;
    IconData icon;
    switch (type) {
      case PomodoroSessionType.work:
        label = context.l10n.deepWork;
        icon = Iconsax.flash;
        break;
      case PomodoroSessionType.shortBreak:
        label = context.l10n.shortBreak;
        icon = Iconsax.coffee;
        break;
      case PomodoroSessionType.longBreak:
        label = context.l10n.longBreak;
        icon = Iconsax.moon;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PomodoroSettingsBottomSheet(),
    );
  }

  Widget _buildSoundSelector(ThemeData theme, List<_SmartSound> sounds) {
    final activeSound = ref.watch(ambientSoundProvider);
    final l10n = context.l10n;

    //Helper to build a sound item
    Widget buildSoundItem(_SmartSound sound) {
      final isSelected =
          activeSound == sound.id ||
          (activeSound == null && sound.id == 'None');
      return GestureDetector(
        onTap: () =>
            ref.read(ambientSoundProvider.notifier).playSound(sound.id),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                sound.icon,
                size: 16,
                color: isSelected ? theme.primaryColor : Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                sound.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.black : Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Sons d'ambiance",
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                buildSoundItem(
                  _SmartSound('None', l10n.none, Iconsax.volume_low),
                ),
                ...sounds.map(buildSoundItem),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PomodoroSettingsBottomSheet extends ConsumerWidget {
  const PomodoroSettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(pomodoroSettingsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundDark.withOpacity(0.85)
            : Colors.white.withOpacity(0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Iconsax.setting_2,
                        color: theme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      context.l10n.personalization,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.black12,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                settingsAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (err, _) => Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Erreur: $err",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  data: (settings) => Column(
                    children: [
                      _buildSliderRow(
                        context,
                        label: context.l10n.pomodoroWork,
                        value: settings.workDuration,
                        icon: Iconsax.flash,
                        min: 5,
                        max: 60,
                        step: 5,
                        onChanged: (val) => ref
                            .read(pomodoroSettingsProvider.notifier)
                            .updateSettings(workDuration: val),
                      ),
                      const SizedBox(height: 24),
                      _buildSliderRow(
                        context,
                        label: context.l10n.shortBreak,
                        value: settings.shortBreakDuration,
                        icon: Iconsax.coffee,
                        min: 1,
                        max: 15,
                        step: 1,
                        onChanged: (val) => ref
                            .read(pomodoroSettingsProvider.notifier)
                            .updateSettings(shortBreak: val),
                      ),
                      const SizedBox(height: 24),
                      _buildSliderRow(
                        context,
                        label: context.l10n.longBreak,
                        value: settings.longBreakDuration,
                        icon: Iconsax.moon,
                        min: 10,
                        max: 45,
                        step: 5,
                        onChanged: (val) => ref
                            .read(pomodoroSettingsProvider.notifier)
                            .updateSettings(longBreak: val),
                      ),
                      const SizedBox(height: 24),
                      _buildSliderRow(
                        context,
                        label: "Intervalle",
                        value: settings.sessionsUntilLongBreak,
                        icon: Iconsax.repeat,
                        min: 2,
                        max: 8,
                        step: 1,
                        unit: "séances",
                        onChanged: (val) => ref
                            .read(pomodoroSettingsProvider.notifier)
                            .updateSettings(sessionsUntilLong: val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      context.l10n.done,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderRow(
    BuildContext context, {
    required String label,
    required int value,
    required IconData icon,
    required double min,
    required double max,
    required double step,
    String unit = "min",
    required Function(int) onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: theme.primaryColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "$value$unit",
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 10,
              elevation: 4,
              pressedElevation: 8,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            activeTrackColor: theme.primaryColor,
            inactiveTrackColor: theme.primaryColor.withOpacity(0.1),
            thumbColor: Colors.white,
          ),
          child: Slider(
            value: value.toDouble(),
            min: min,
            max: max,
            divisions: ((max - min) / step).toInt(),
            onChanged: (val) => onChanged(val.toInt()),
          ),
        ),
      ],
    );
  }
}
