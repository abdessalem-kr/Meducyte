import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/calendar_provider.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/calendar_models.dart';
import 'package:intl/intl.dart';

class SmartCalendarWidget extends ConsumerStatefulWidget {
  const SmartCalendarWidget({super.key});

  @override
  ConsumerState<SmartCalendarWidget> createState() =>
      _SmartCalendarWidgetState();
}

class _SmartCalendarWidgetState extends ConsumerState<SmartCalendarWidget> {
  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        _buildHeader(context, ref, calendarState),
        const SizedBox(height: 16),
        Container(
          height: calendarState.viewMode == CalendarViewMode.month ? 400 : 600,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            ),
          ),
          child: _buildMainView(context, calendarState, isDark),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    CalendarState state,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMMM yyyy').format(state.selectedDate),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              state.viewMode == CalendarViewMode.month
                  ? context.l10n.monthlyView
                  : (state.viewMode == CalendarViewMode.week
                        ? context.l10n.weeklyView
                        : context.l10n.dailyView),
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const Spacer(),
        _buildViewModeSelector(context, ref, state),
        const SizedBox(width: 12),
        TextButton.icon(
          onPressed: () => ref
              .read(calendarProvider.notifier)
              .aiScheduleDay((title) => context.l10n.aiPrefix(title)),
          icon: Icon(Iconsax.magic_star, size: 18, color: theme.primaryColor),
          label: Text(
            context.l10n.aiPlanner,
            style: TextStyle(color: theme.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildViewModeSelector(
    BuildContext context,
    WidgetRef ref,
    CalendarState state,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.white10
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: CalendarViewMode.values.map((mode) {
          final isSelected = state.viewMode == mode;
          return GestureDetector(
            onTap: () => ref.read(calendarProvider.notifier).setViewMode(mode),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? theme.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                mode == CalendarViewMode.day
                    ? "J"
                    : (mode == CalendarViewMode.week ? "H" : "M"),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainView(
    BuildContext context,
    CalendarState state,
    bool isDark,
  ) {
    switch (state.viewMode) {
      case CalendarViewMode.month:
        return _buildMonthGrid(context, state, isDark);
      case CalendarViewMode.week:
      case CalendarViewMode.day:
        return _buildCalendarGrid(context, state, isDark);
    }
  }

  Widget _buildMonthGrid(
    BuildContext context,
    CalendarState state,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final firstDayOfMonth = DateTime(
      state.selectedDate.year,
      state.selectedDate.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      state.selectedDate.year,
      state.selectedDate.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday; //1=Mon

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final date = DateTime(2024, 1, 1 + i); //2024-01-01 is a Monday
              return Text(
                DateFormat('EEEEE').format(date).toUpperCase(),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: 42, //6 weeks
            itemBuilder: (context, index) {
              final dayNumber = index - (firstWeekday - 2);
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark
                          ? Colors.white10
                          : Colors.black.withOpacity(0.02),
                    ),
                  ),
                );
              }

              final date = DateTime(
                state.selectedDate.year,
                state.selectedDate.month,
                dayNumber,
              );
              final events = state.events
                  .where(
                    (e) =>
                        e.startTime.day == dayNumber &&
                        e.startTime.month == state.selectedDate.month,
                  )
                  .toList();

              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withOpacity(0.04),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      dayNumber.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: date.day == DateTime.now().day
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: date.day == DateTime.now().day
                            ? theme.primaryColor
                            : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ...events
                        .take(2)
                        .map(
                          (e) => Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 1,
                            ),
                            height: 4,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: e.color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                    if (events.length > 2)
                      const Icon(Icons.more_horiz, size: 8, color: Colors.grey),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    CalendarState state,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final selectedDate = state.selectedDate;
    final isWeekly = state.viewMode == CalendarViewMode.week;

    final startOfWeek = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );
    final now = DateTime.now();

    final dayCount = isWeekly ? 7 : 1;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: 12,
            horizontal: isWeekly ? 48 : 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dayCount, (index) {
              final day = isWeekly
                  ? startOfWeek.add(Duration(days: index))
                  : selectedDate;
              final isToday =
                  day.day == now.day &&
                  day.month == now.month &&
                  day.year == now.year;
              return Column(
                children: [
                  Text(
                    DateFormat(
                      isWeekly ? 'E' : 'EEEE',
                    ).format(day).toUpperCase(),
                    style: TextStyle(
                      color: isToday ? theme.primaryColor : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day.day.toString(),
                    style: TextStyle(
                      color: isToday
                          ? theme.primaryColor
                          : (isDark ? Colors.white : Colors.black),
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: 15, //7 AM to 10 PM
            itemBuilder: (context, index) {
              final hour = index + 7;
              return IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "${hour}h",
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: List.generate(dayCount, (dayIndex) {
                          final currentDay = isWeekly
                              ? startOfWeek.add(Duration(days: dayIndex))
                              : selectedDate;
                          final hourlyEvents = state.events
                              .where(
                                (e) =>
                                    e.startTime.day == currentDay.day &&
                                    e.startTime.month == currentDay.month &&
                                    hour >= e.startTime.hour &&
                                    hour < e.endTime.hour,
                              )
                              .toList();

                          return Expanded(
                            child: GestureDetector(
                              onTap: () => _showAddEventDialog(
                                context,
                                hour,
                                currentDay,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: isDark
                                          ? Colors.white10
                                          : Colors.black.withOpacity(0.03),
                                    ),
                                    left: BorderSide(
                                      color: isDark
                                          ? Colors.white10
                                          : Colors.black.withOpacity(0.03),
                                    ),
                                  ),
                                ),
                                child: Stack(
                                  children: hourlyEvents.asMap().entries.map((
                                    entry,
                                  ) {
                                    final idx = entry.key;
                                    final e = entry.value;
                                    final total = hourlyEvents.length;
                                    return FractionallySizedBox(
                                      widthFactor: 1 / total,
                                      alignment: Alignment(
                                        -1.0 +
                                            (idx *
                                                2 /
                                                (total > 1 ? total - 1 : 1)),
                                        0,
                                      ),
                                      child: _buildEventBlock(context, e),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventBlock(BuildContext context, StudyEvent event) {
    return GestureDetector(
      onTap: () => _showEventOptions(context, event),
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: event.color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: event.color.withOpacity(0.4), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: event.color,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Text(
              DateFormat('HH:mm').format(event.startTime),
              style: TextStyle(
                fontSize: 8,
                color: event.color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEventDialog(
    BuildContext context,
    int hour,
    DateTime date, {
    StudyEvent? eventToEdit,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddEventBottomSheet(
        initialHour: hour,
        initialDate: date,
        initialEvent: eventToEdit,
        onAdd: (event) {
          if (eventToEdit != null) {
            ref.read(calendarProvider.notifier).updateEvent(event);
          } else {
            ref.read(calendarProvider.notifier).addEvent(event);
          }
        },
      ),
    );
  }

  void _showEventOptions(BuildContext context, StudyEvent event) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: event.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "${DateFormat('EEEE d MMMM').format(event.startTime)} • ${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}",
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Iconsax.edit_2, color: Colors.blue),
              title: Text(context.l10n.editSession),
              onTap: () {
                Navigator.pop(context);
                _showAddEventDialog(
                  context,
                  event.startTime.hour,
                  event.startTime,
                  eventToEdit: event,
                );
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.trash, color: Colors.red),
              title: Text(
                context.l10n.deleteLabel,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                ref.read(calendarProvider.notifier).removeEvent(event.id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AddEventBottomSheet extends StatefulWidget {
  final int initialHour;
  final DateTime initialDate;
  final StudyEvent? initialEvent;
  final Function(StudyEvent) onAdd;

  const _AddEventBottomSheet({
    required this.initialHour,
    required this.initialDate,
    this.initialEvent,
    required this.onAdd,
  });

  @override
  State<_AddEventBottomSheet> createState() => _AddEventBottomSheetState();
}

class _AddEventBottomSheetState extends State<_AddEventBottomSheet> {
  late TextEditingController _titleController;
  late DateTime _startTime;
  late DateTime _endTime;
  StudyEventType _type = StudyEventType.manual;
  Color _selectedColor = AppColors.primary;

  final List<Color> _presetColors = [
    AppColors.primary,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pinkAccent,
    Colors.blue,
  ];

  @override
  void initState() {
    super.initState();
    final event = widget.initialEvent;
    _titleController = TextEditingController(text: event?.title);
    _type = event?.type ?? StudyEventType.manual;
    _selectedColor = event?.color ?? AppColors.primary;

    if (event != null) {
      _startTime = event.startTime;
      _endTime = event.endTime;
    } else {
      _startTime = DateTime(
        widget.initialDate.year,
        widget.initialDate.month,
        widget.initialDate.day,
        widget.initialHour,
      );
      _endTime = _startTime.add(const Duration(hours: 1));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
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
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                context.l10n.newSession,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Iconsax.close_circle),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: context.l10n.subjectHint,
              prefixIcon: const Icon(Iconsax.book_1),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.typeLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: StudyEventType.values.map((type) {
                final isSelected = _type == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(type.name),
                    onSelected: (val) => setState(() => _type = type),
                    selectedColor: theme.primaryColor.withOpacity(0.15),
                    checkmarkColor: theme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? theme.primaryColor : Colors.grey,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTimePicker(
                  context,
                  context.l10n.startTime,
                  _startTime,
                  (time) => setState(() {
                    _startTime = DateTime(
                      _startTime.year,
                      _startTime.month,
                      _startTime.day,
                      time.hour,
                      time.minute,
                    );
                    if (_endTime.isBefore(_startTime)) {
                      _endTime = _startTime.add(const Duration(hours: 1));
                    }
                  }),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimePicker(
                  context,
                  context.l10n.endTime,
                  _endTime,
                  (time) => setState(() {
                    _endTime = DateTime(
                      _endTime.year,
                      _endTime.month,
                      _endTime.day,
                      time.hour,
                      time.minute,
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.colorLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _presetColors.map((color) {
              final isSelected = _selectedColor == color;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  widget.onAdd(
                    StudyEvent(
                      id:
                          widget.initialEvent?.id ??
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      title: _titleController.text,
                      startTime: _startTime,
                      endTime: _endTime,
                      color: _selectedColor,
                      type: _type,
                    ),
                  );
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                context.l10n.planSession,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(
    BuildContext context,
    String label,
    DateTime time,
    Function(TimeOfDay) onSelected,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(time),
            );
            if (picked != null) onSelected(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.clock, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  DateFormat('HH:mm').format(time),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
