import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/pomodoro_provider.dart';
import 'package:meducyte_app/features/productive_bay/presentation/pages/tasks_page.dart';

class SmartTodoListWidget extends ConsumerWidget {
  const SmartTodoListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(productiveBayProvider);

    return Column(
      children: [
        tasksAsync.when(
          data: (tasks) => Column(
            children: tasks
                .map((task) => SmartTodoItemCard(task: task))
                .toList(),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Column(
            children: [
              Text(
                "${context.l10n.errorLabel}: $err",
                style: const TextStyle(color: Colors.red, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => ref.invalidate(productiveBayProvider),
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SmartTodoItemCard extends ConsumerStatefulWidget {
  final TodoItem task;
  const SmartTodoItemCard({super.key, required this.task});

  @override
  ConsumerState<SmartTodoItemCard> createState() => _SmartTodoItemCardState();
}

class _SmartTodoItemCardState extends ConsumerState<SmartTodoItemCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final task = widget.task;

    Color priorityColor;
    switch (task.priority) {
      case TodoPriority.urgent:
        priorityColor = Colors.red;
        break;
      case TodoPriority.exam:
        priorityColor = Colors.orange;
        break;
      case TodoPriority.optional:
        priorityColor = theme.primaryColor;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            //Priority Accent Bar(stretches vertically via Positioned)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 6,
              child: Container(color: priorityColor),
            ),
            //Main Content
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                    leading: Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: task.isCompleted,
                        activeColor: priorityColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        onChanged: (_) => ref
                            .read(productiveBayProvider.notifier)
                            .toggleTask(task.id),
                      ),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: -0.5,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted
                            ? (isDark ? Colors.white38 : Colors.black38)
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _buildPriorityLabel(task.priority),
                                if (task.deadline != null)
                                  _buildDeadlineBadge(task.deadline!),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildPomodoroProgress(task),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFocusSelector(context, ref, task),
                        IconButton(
                          icon: Icon(
                            _isExpanded
                                ? Iconsax.arrow_up_1
                                : Iconsax.arrow_down_1,
                            size: 18,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                          onPressed: () =>
                              setState(() => _isExpanded = !_isExpanded),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            size: 20,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                          padding: EdgeInsets.zero,
                          onSelected: (value) {
                            if (value == 'edit') {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) =>
                                    AddTaskSheet(initialTask: task),
                              );
                            } else if (value == 'delete') {
                              _showDeleteConfirmation(context, ref, task);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(Iconsax.edit, size: 18),
                                  const SizedBox(width: 12),
                                  Text(context.l10n.editLabel),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(
                                    Iconsax.trash,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    context.l10n.deleteLabel,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_isExpanded && task.subtasks.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(52, 0, 16, 16),
                      child: Column(
                        children: task.subtasks
                            .map((s) => _buildSubTaskItem(context, task.id, s))
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    TodoItem task,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteTaskTitle),
        content: Text(context.l10n.deleteTaskConfirm(task.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(productiveBayProvider.notifier).removeTask(task.id);
              Navigator.pop(context);
            },
            child: Text(context.l10n.deleteLabel, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityLabel(TodoPriority priority) {
    Color color;
    String label;
    IconData icon;
    switch (priority) {
      case TodoPriority.urgent:
        color = Colors.red;
        label = context.l10n.urgentLabel;
        icon = Iconsax.flash;
        break;
      case TodoPriority.exam:
        color = Colors.orange;
        label = context.l10n.examLabel;
        icon = Iconsax.book;
        break;
      case TodoPriority.optional:
        color = Theme.of(context).primaryColor;
        label = context.l10n.optionalLabel;
        icon = Iconsax.info_circle;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color.withOpacity(0.7)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSubTaskItem(
    BuildContext context,
    String taskId,
    SubTask subtask,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: subtask.isCompleted,
              activeColor: theme.primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: (_) => ref
                  .read(productiveBayProvider.notifier)
                  .toggleSubTask(taskId, subtask.id),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              subtask.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                decoration: subtask.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: subtask.isCompleted
                    ? (isDark ? Colors.white38 : Colors.black38)
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineBadge(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;
    final color = difference < 2 ? Colors.red : Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.calendar, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            difference == 0
                ? context.l10n.todayLabel
                : context.l10n.daysRemaining(difference),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPomodoroProgress(TodoItem task) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < task.estimatedPomodoros; i++)
          Padding(
            padding: const EdgeInsets.only(right: 2.0),
            child: Opacity(
              opacity: i < task.completedPomodoros ? 1.0 : 0.2,
              child: const Text("🍅", style: TextStyle(fontSize: 12)),
            ),
          ),
      ],
    );
  }

  Widget _buildFocusSelector(
    BuildContext context,
    WidgetRef ref,
    TodoItem task,
  ) {
    final theme = Theme.of(context);
    final focusSession = ref.watch(pomodoroProvider);
    final isSelected = focusSession.taskId == task.id;

    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.red.withOpacity(0.1)
              : theme.primaryColor.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected ? Iconsax.timer : Iconsax.timer_1,
          color: isSelected ? Colors.red : theme.primaryColor,
          size: 18,
        ),
      ),
      onPressed: () {
        ref
            .read(pomodoroProvider.notifier)
            .selectTask(isSelected ? null : task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: theme.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Text(
              isSelected
                  ? context.l10n.taskDeselected
                  : context.l10n.focusOnTask(task.title),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }
}
