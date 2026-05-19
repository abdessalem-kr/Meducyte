import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/calendar_provider.dart';
import 'package:meducyte_app/features/productive_bay/presentation/widgets/smart_calendar_widget.dart';
import 'package:meducyte_app/features/productive_bay/presentation/pages/printable_planner_view.dart';
import 'package:intl/intl.dart';

class PlannerPage extends ConsumerWidget {
  const PlannerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.planner),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.printer),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrintablePlannerView(),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeeklyNavigation(context, ref, state.selectedDate),
            const SizedBox(height: 24),
            _buildWeeklyObjectives(
              context,
              ref,
              state.weeklyObjectives,
              isDark,
            ),
            const SizedBox(height: 32),
            const SmartCalendarWidget(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyNavigation(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
  ) {
    final startOfWeek = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Iconsax.arrow_left_2),
            onPressed: () => ref.read(calendarProvider.notifier).previousWeek(),
          ),
          Column(
            children: [
              Text(
                context.l10n.weekLabel(
                  DateFormat('d').format(startOfWeek),
                  DateFormat('d MMMM').format(endOfWeek),
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                DateFormat('yyyy').format(selectedDate),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Iconsax.arrow_right_3),
            onPressed: () => ref.read(calendarProvider.notifier).nextWeek(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyObjectives(
    BuildContext context,
    WidgetRef ref,
    List<String> objectives,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.flag, color: theme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                context.l10n.weeklyObjectives,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(objectives.isNotEmpty
                  ? objectives
                  : [
                      context.l10n.defaultObjective1,
                      context.l10n.defaultObjective2,
                      context.l10n.defaultObjective3,
                    ])
              .map(
                (obj) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.tick_circle,
                        color: theme.primaryColor.withOpacity(0.5),
                        size: 16,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(obj, style: const TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
