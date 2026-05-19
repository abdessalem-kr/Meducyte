import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/calendar_provider.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/calendar_models.dart';
import 'package:intl/intl.dart';

class PrintablePlannerView extends ConsumerWidget {
  const PrintablePlannerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarProvider);
    final events = state.events;
    final selectedDate = state.selectedDate;
    final startOfWeek = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          context.l10n.exportPlannerTitle,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, startOfWeek),
            const SizedBox(height: 32),
            _buildObjectivesSection(context, state.weeklyObjectives),
            const SizedBox(height: 32),
            _buildWeeklyGrid(context, events, startOfWeek),
            const SizedBox(height: 32),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DateTime startOfWeek) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "MEDUCYTE",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Text(
              context.l10n.clinicalRevisionPlanner,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.weekOf(
                DateFormat('dd MMMM yyyy').format(startOfWeek),
              ),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const Icon(Iconsax.calendar_tick, size: 40, color: Colors.black),
      ],
    );
  }

  Widget _buildObjectivesSection(
    BuildContext context,
    List<String> objectives,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.weeklyPriorityObjectives,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const Divider(color: Colors.black),
          ...objectives.map(
            (obj) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(obj, style: const TextStyle(fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyGrid(
    BuildContext context,
    List<StudyEvent> events,
    DateTime startOfWeek,
  ) {
    return Table(
      border: TableBorder.all(color: Colors.black45, width: 1),
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Colors.black12),
          children: [
            _HeaderCell(context.l10n.hourTitle),
            ...List.generate(
              7,
              (i) => _HeaderCell(
                DateFormat(
                  'EEE',
                ).format(startOfWeek.add(Duration(days: i))).toUpperCase(),
              ),
            ),
          ],
        ),
        ...List.generate(12, (index) {
          final hour = index + 8;
          return TableRow(
            children: [
              _Cell("${hour}h", isTime: true),
              ...List.generate(7, (dayIndex) {
                final day = startOfWeek.add(Duration(days: dayIndex));
                final dayEvents = events
                    .where(
                      (e) =>
                          e.startTime.hour == hour &&
                          e.startTime.day == day.day,
                    )
                    .toList();
                return _Cell(dayEvents.map((e) => e.title).join("\n"));
              }),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildFooterBox(context.l10n.clinicalNotesReminders)),
        const SizedBox(width: 20),
        Expanded(child: _buildFooterBox(context.l10n.intensityTrackerAi)),
      ],
    );
  }

  Widget _buildFooterBox(String title) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final bool isTime;
  const _Cell(this.text, {this.isTime = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      padding: const EdgeInsets.all(4),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: isTime ? 10 : 9,
          fontWeight: isTime ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
