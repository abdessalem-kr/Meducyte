import 'package:meducyte_app/export.dart';

class SavedQuizzesScreen extends ConsumerStatefulWidget {
  const SavedQuizzesScreen({super.key});

  @override
  ConsumerState<SavedQuizzesScreen> createState() => _SavedQuizzesScreenState();
}

class _SavedQuizzesScreenState extends ConsumerState<SavedQuizzesScreen> {
  int? selectedFolderId;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final foldersAsync = ref.watch(myQuestionFoldersProvider);
    final savedQuestionsAsync = ref.watch(mySavedQuestionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        appBar: AppBar(
          title: Text(l10n.savedQuizzes),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.theoretical),
              Tab(text: l10n.clinicalCases),
            ],
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        body: Column(
          children: [
            //Folder Filter Chips
            foldersAsync.when(
              data: (folders) {
                return folders.isEmpty
                    ? const SizedBox.shrink()
                    : _buildFolderSelector(folders);
              },
              loading: () => const SizedBox(height: 60),
              error: (err, stack) => const SizedBox.shrink(),
            ),

            //Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (value) =>
                    setState(() => _searchQuery = value.trim()),
                decoration: InputDecoration(
                  hintText: l10n.search,
                  prefixIcon: const Icon(Iconsax.search_normal),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            Expanded(
              child: savedQuestionsAsync.when(
                data: (allSaved) {
                  //Apply folder filter first
                  var folderFiltered = selectedFolderId == null
                      ? allSaved
                      : allSaved
                            .where((s) => s.folderId == selectedFolderId)
                            .toList();

                  //Apply search query
                  if (_searchQuery.isNotEmpty) {
                    final query = _searchQuery.toLowerCase();
                    folderFiltered = folderFiltered.where((s) {
                      final text = s.question?.text.toLowerCase() ?? '';
                      final lesson =
                          s.question?.lessonTitle?.toLowerCase() ?? '';
                      final id = s.question?.id.toString() ?? '';
                      return text.contains(query) ||
                          lesson.contains(query) ||
                          id.contains(query);
                    }).toList();
                  }

                  //Group into Theoretical and Clinical Cases
                  final theoretical = folderFiltered
                      .where((s) => s.question?.clinicalCase == null)
                      .toList();

                  //Group questions by clinical case ID
                  final clinicalCaseGroups = <int, List<SavedQuestion>>{};
                  for (var s in folderFiltered) {
                    final ccId = s.question?.clinicalCase?.id;
                    if (ccId != null) {
                      clinicalCaseGroups.putIfAbsent(ccId, () => []).add(s);
                    }
                  }

                  return TabBarView(
                    children: [
                      //Theoretical Tab
                      _buildQuestionsList(context, theoretical, l10n, isDark),
                      //Clinical Cases Tab
                      _buildClinicalCasesList(
                        context,
                        clinicalCaseGroups.values.toList(),
                        l10n,
                        isDark,
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsList(
    BuildContext context,
    List<SavedQuestion> questions,
    AppLocalizations l10n,
    bool isDark,
  ) {
    if (questions.isEmpty) {
      return _buildEmptyState(l10n, isDark);
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        return _SavedQuestionTile(
          savedQuestion: questions[index],
          onUnsave: () => _handleUnsave(questions[index].questionId),
        );
      },
    );
  }

  Widget _buildClinicalCasesList(
    BuildContext context,
    List<List<SavedQuestion>> groups,
    AppLocalizations l10n,
    bool isDark,
  ) {
    if (groups.isEmpty) {
      return _buildEmptyState(l10n, isDark);
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return _ClinicalCaseTile(
          questions: group,
          onUnsave: () => _handleUnsave(group.first.questionId),
        );
      },
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.document_favorite,
            size: 64,
            color:
                (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight)
                    .withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noQuestionsFound,
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUnsave(int questionId) async {
    try {
      await ref.read(quizRepositoryProvider).toggleSaveQuestion(questionId);
      ref.invalidate(mySavedQuestionsProvider);
    } catch (e) {
      if (mounted) {
        AppSnackBars.error(context, e.toString());
      }
    }
  }

  Widget _buildFolderSelector(List<QuestionFolder> folders) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: folders.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(l10n.all),
                selected: selectedFolderId == null,
                onSelected: (_) => setState(() => selectedFolderId = null),
                backgroundColor: isDark
                    ? AppColors.cardDark
                    : AppColors.cardLight,
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selectedFolderId == null
                      ? AppColors.primary
                      : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                  fontWeight: selectedFolderId == null
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            );
          }

          final folder = folders[index - 1];
          final isSelected = selectedFolderId == folder.id;
          final folderColor = folder.color != null
              ? Color(int.parse(folder.color!.replaceFirst('#', '0xFF')))
              : AppColors.primary;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onLongPress: () => _showEditFolderDialog(context, folder),
              child: FilterChip(
                label: Text(folder.name),
                selected: isSelected,
                onSelected: (_) => setState(
                  () => selectedFolderId = isSelected ? null : folder.id,
                ),
                backgroundColor: isDark
                    ? AppColors.cardDark
                    : AppColors.cardLight,
                selectedColor: folderColor.withOpacity(0.2),
                checkmarkColor: folderColor,
                avatar: CircleAvatar(backgroundColor: folderColor, radius: 6),
                labelStyle: TextStyle(
                  color: isSelected
                      ? folderColor
                      : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditFolderDialog(BuildContext context, QuestionFolder folder) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: folder.name);
    String selectedColor = folder.color ?? '#f44336';

    final List<String> presetColors = [
      '#f44336',
      '#e91e63',
      '#9c27b0',
      '#673ab7',
      '#3f51b5',
      '#2196f3',
      '#009688',
      '#4caf50',
      '#ffc107',
      '#ff9800',
      '#795548',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.renameCollection),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(hintText: l10n.collectionName),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 40,
                width: 300,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: presetColors.length,
                  itemBuilder: (context, index) {
                    final colorHex = presetColors[index];
                    final color = Color(
                      int.parse(colorHex.replaceFirst('#', '0xFF')),
                    );
                    final isSelected = selectedColor == colorHex;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () =>
                            setDialogState(() => selectedColor = colorHex),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  try {
                    await ref
                        .read(quizRepositoryProvider)
                        .renameQuestionFolder(
                          folder.id,
                          newName,
                          color: selectedColor,
                        );
                    ref.invalidate(myQuestionFoldersProvider);
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    if (context.mounted) {
                      AppSnackBars.error(context, e.toString());
                    }
                  }
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedQuestionTile extends StatelessWidget {
  final SavedQuestion savedQuestion;
  final VoidCallback onUnsave;

  const _SavedQuestionTile({
    required this.savedQuestion,
    required this.onUnsave,
  });

  @override
  Widget build(BuildContext context) {
    final question = savedQuestion.question;
    if (question == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: InkWell(
        onTap: () {
          context.push(
            AppRoutes.quizSession,
            extra: QuizFilters(
              isPractice: true,
              questionIds: [question.id.toString()],
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (question.sourceExam != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        question.sourceExam!,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    '#${question.id}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      final l10n = AppLocalizations.of(context)!;
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.unsaveQuestion),
                          content: Text(l10n.unsaveQuestionConfirmation),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(l10n.cancel),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                onUnsave();
                              },
                              child: Text(
                                l10n.confirm,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(
                      Iconsax.star5,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Iconsax.arrow_right_3,
                    size: 16,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Text(
                question.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (question.lessonTitle != null) ...[
                    Icon(
                      Iconsax.book,
                      size: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        question.lessonTitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const SizedBox(width: 12),
                  Text(
                    '${savedQuestion.createdAt.day}/${savedQuestion.createdAt.month}/${savedQuestion.createdAt.year}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClinicalCaseTile extends StatelessWidget {
  final List<SavedQuestion> questions;
  final VoidCallback onUnsave;

  const _ClinicalCaseTile({required this.questions, required this.onUnsave});

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) return const SizedBox.shrink();
    final firstSaved = questions.first;
    final clinicalCase = firstSaved.question?.clinicalCase;
    if (clinicalCase == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: InkWell(
        onTap: () {
          final filters = QuizFilters(
            isPractice: true,
            questionIds: questions.map((s) => s.questionId.toString()).toList(),
          );
          context.push('/quiz/session/new', extra: filters);
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.clinicalCase,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.unsaveQuestion),
                          content: Text(l10n.unsaveQuestionConfirmation),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(l10n.cancel),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                onUnsave();
                              },
                              child: Text(
                                l10n.confirm,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(
                      Iconsax.star5,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Iconsax.arrow_right_3,
                    size: 16,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                clinicalCase.title ?? clinicalCase.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Iconsax.task,
                    size: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.questionsCount(questions.length),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${firstSaved.createdAt.day}/${firstSaved.createdAt.month}/${firstSaved.createdAt.year}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
