import 'dart:ui';
import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/productive_bay/presentation/widgets/smart_todo_list_widget.dart';

class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: isDark
                ? AppColors.backgroundDark.withOpacity(0.8)
                : AppColors.backgroundLight.withOpacity(0.8),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: 20,
                bottom: 16,
                right: 20,
              ),
              title: Text(
                context.l10n.taskListTitle,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: -0.5,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.primaryColor.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.add,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                  ),
                  onPressed: () => _showAddTaskSheet(context, ref),
                ),
              ),
            ],
          ),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              const SmartTodoListWidget(),
              const SizedBox(height: 100), //Reserve space for scrolling
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTaskSheet(
    BuildContext context,
    WidgetRef ref, {
    TodoItem? task,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTaskSheet(initialTask: task),
    );
  }
}

class AddTaskSheet extends ConsumerStatefulWidget {
  final TodoItem? initialTask;
  const AddTaskSheet({super.key, this.initialTask});

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _subTaskController;
  late TodoPriority _priority;
  late int _estimatedPomodoros;
  late List<SubTask> _subtasks;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialTask?.title ?? '',
    );
    _subTaskController = TextEditingController();
    _priority = widget.initialTask?.priority ?? TodoPriority.optional;
    _estimatedPomodoros = widget.initialTask?.estimatedPomodoros ?? 1;
    _subtasks = widget.initialTask?.subtasks != null
        ? List.from(widget.initialTask!.subtasks)
        : [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subTaskController.dispose();
    super.dispose();
  }

  void _addSubTask() {
    if (_subTaskController.text.isNotEmpty) {
      setState(() {
        _subtasks.add(
          SubTask(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: _subTaskController.text,
          ),
        );
        _subTaskController.clear();
      });
    }
  }

  void _editSubTask(SubTask subtask) {
    final controller = TextEditingController(text: subtask.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Modifier la sous-tâche"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Nom de la sous-tâche"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  final index = _subtasks.indexOf(subtask);
                  if (index != -1) {
                    _subtasks[index] = subtask.copyWith(title: controller.text);
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              top: 12,
              left: 24,
              right: 24,
            ),
            child: SingleChildScrollView(
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
                          Iconsax.add_square,
                          color: theme.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        widget.initialTask == null
                            ? context.l10n.newTask
                            : "Modifier la tâche",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: context.l10n.whatWillYouAchieve,
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    context.l10n.priority,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: TodoPriority.values.map((p) {
                      final isSelected = _priority == p;
                      String label;
                      IconData icon;
                      Color color;

                      switch (p) {
                        case TodoPriority.urgent:
                          label = context.l10n.urgentLabel;
                          icon = Iconsax.flash;
                          color = Colors.red;
                          break;
                        case TodoPriority.exam:
                          label = context.l10n.examLabel;
                          icon = Iconsax.book;
                          color = Colors.orange;
                          break;
                        case TodoPriority.optional:
                          label = context.l10n.optionalLabel;
                          icon = Iconsax.info_circle;
                          color = theme.primaryColor;
                          break;
                      }

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _priority = p),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withOpacity(0.15)
                                  : isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? color : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  icon,
                                  color: isSelected ? color : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  label,
                                  style: TextStyle(
                                    color: isSelected ? color : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    context.l10n.estimatedWork,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(8, (index) {
                        final i = index + 1;
                        final isSelected = _estimatedPomodoros == i;
                        return GestureDetector(
                          onTap: () => setState(() => _estimatedPomodoros = i),
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.primaryColor.withOpacity(0.15)
                                  : isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? theme.primaryColor
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "🍅",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: isSelected ? null : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "$i",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: isSelected
                                        ? theme.primaryColor
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 48),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Sous-tâches",
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        "${_subtasks.length}",
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_subtasks.isNotEmpty)
                    ..._subtasks.map(
                      (s) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              s.isCompleted
                                  ? Iconsax.tick_circle
                                  : Iconsax.record_circle,
                              size: 18,
                              color: s.isCompleted ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                s.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  decoration: s.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: s.isCompleted ? Colors.grey : null,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _editSubTask(s),
                              icon: const Icon(Iconsax.edit, size: 18),
                              color: theme.primaryColor.withOpacity(0.7),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () =>
                                  setState(() => _subtasks.remove(s)),
                              icon: const Icon(Iconsax.trash, size: 18),
                              color: Colors.red.withOpacity(0.7),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _subTaskController,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "Ajouter une sous-tâche...",
                            filled: true,
                            fillColor: isDark
                                ? Colors.white.withOpacity(0.03)
                                : Colors.black.withOpacity(0.03),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (_) => _addSubTask(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addSubTask,
                        icon: Icon(
                          Iconsax.add_circle,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_titleController.text.isNotEmpty) {
                          final notifier = ref.read(
                            productiveBayProvider.notifier,
                          );
                          if (widget.initialTask == null) {
                            notifier.addTask(
                              'manual',
                              _titleController.text,
                              priority: _priority,
                              estimatedPomodoros: _estimatedPomodoros,
                              subtasks: _subtasks,
                            );
                          } else {
                            notifier.updateTask(
                              taskId: widget.initialTask!.id,
                              title: _titleController.text,
                              priority: _priority,
                              estimatedPomodoros: _estimatedPomodoros,
                              subtasks: _subtasks,
                            );
                          }
                          Navigator.pop(context);
                        }
                      },
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
                        widget.initialTask == null
                            ? context.l10n.addToList
                            : "Enregistrer les modifications",
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
      ),
    );
  }
}
