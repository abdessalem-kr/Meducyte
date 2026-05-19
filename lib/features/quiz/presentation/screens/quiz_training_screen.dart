import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';
import 'package:collection/collection.dart';
import 'package:meducyte_app/shared/widgets/subscription_gate.dart';

class QuizTrainingScreen extends ConsumerStatefulWidget {
  final bool isPractice;
  final bool isExplore;
  final int? initialYear;

  const QuizTrainingScreen({
    super.key,
    this.isPractice = true,
    this.isExplore = false,
    this.initialYear,
  });

  @override
  ConsumerState<QuizTrainingScreen> createState() => _QuizTrainingScreenState();
}

class _QuizTrainingScreenState extends ConsumerState<QuizTrainingScreen> {
  late bool _showClinicalOnly;
  late bool _isExplore;
  List<int> _selectedYears = [];
  List<String> _selectedModuleIds = [];
  List<String> _selectedLessonIds = [];
  List<String> _selectedSources = [];
  QuizCorrectionMode _correctionMode = QuizCorrectionMode.allOrNothing;
  int? _selectedTimeLimit;
  int _selectedQuestionCount = 20;

  @override
  void initState() {
    super.initState();
    _showClinicalOnly = false; //Default to Theoretical
    _isExplore = widget.isExplore;

    //Initialize year from LearnPage selection
    if (widget.initialYear != null) {
      //We'll set it in build or after frame if needed,but let's try to calculate it here if l10n was available.
      //Better to do it in build or use a postFrameCallback if we rely on l10n.
      //Actually,let's just use the int directly if we change _selectedYear to handle both.
      //For now,let's just use a flag to signal it should be set once l10n is ready.
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSubscriber =
        ref.watch(authControllerProvider).value?.isSubscriber ?? false;

    final yearsAsync = ref.watch(quizYearsProvider);
    final modulesAsync = ref.watch(quizModulesProvider);
    final sourcesAsync = ref.watch(quizSourcesProvider);
    final lessonsAsync = _selectedModuleIds.isNotEmpty
        ? ref.watch(modulesLessonsProvider(_selectedModuleIds))
        : const AsyncValue<List<LearnLesson>>.data([]);

    return SubscriptionGate(
      isEnabled: false,
      child: Scaffold(
        backgroundColor: quizTheme.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              //Custom Top Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Iconsax.arrow_left_2,
                        color: quizTheme.primaryTextColor,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.quizTraining,
                      style: TextStyle(
                        color: quizTheme.primaryTextColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Practice/Explore Toggle(Only in Practice mode)
                      if (widget.isPractice)
                        _buildTopToggle(l10n, primaryColor, quizTheme),
                      const SizedBox(height: 32),

                      //Configuration Dropdowns
                      yearsAsync.when(
                        data: (years) {
                          final user = ref.watch(authControllerProvider).value;
                          //Support initializing from int
                          if (_selectedYears.isEmpty) {
                            final y = widget.initialYear ?? user?.year;
                            if (y != null) {
                              _selectedYears = [y];
                            }
                          }

                          String formatYear(int y) {
                            if (y == 7) return l10n.residencyExam;
                            if (y == 1) return l10n.firstYearOrdinal;
                            return l10n.otherYearOrdinal(y.toString());
                          }

                          final yearOptions = years
                              .map((y) => formatYear(y))
                              .toList();

                          return _buildMultiSelectSection(
                            label: l10n.studyYear,
                            icon: Iconsax.calendar,
                            items: yearOptions,
                            selectedItems: _selectedYears
                                .map((y) => formatYear(y))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedYears = val.map((s) {
                                  if (s == l10n.residencyExam) return 7;
                                  if (s == l10n.firstYearOrdinal) return 1;
                                  return int.parse(
                                    s.split(RegExp(r'[^0-9]')).first,
                                  );
                                }).toList();
                                _selectedModuleIds = []; //Reset child
                                _selectedLessonIds = []; //Reset child
                                _selectedSources = []; //Reset child
                              });
                            },
                            quizTheme: quizTheme,
                            l10n: l10n,
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Text('Error: $err'),
                      ),

                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _selectedYears.isEmpty
                            ? const SizedBox.shrink()
                            : Column(
                                children: [
                                  const SizedBox(height: 24),
                                  modulesAsync.when(
                                    data: (modules) {
                                      //Filter modules:
                                      //1.For Year 2/3:Show only"child"modules(actual subjects).
                                      //2.For others:Show top-level modules.
                                      final filteredModules = modules.where((
                                        m,
                                      ) {
                                        final bool isYearMatch = _selectedYears
                                            .contains(m.year);
                                        if (!isYearMatch) return false;

                                        if (m.year == 2 || m.year == 3) {
                                          //Year 2/3 modules are children of UEIs
                                          //OR standalone top-level modules(no children)
                                          return m.parentId != null ||
                                              (m.children == null ||
                                                  m.children!.isEmpty);
                                        } else {
                                          //Other years use top-level modules
                                          return m.parentId == null;
                                        }
                                      }).toList();

                                      //Calculate groupings for hierarchical View(Year 2/3)
                                      final Map<String, List<String>>
                                      groupings = {};
                                      for (final m in filteredModules) {
                                        String parentName = "";
                                        if (m.parentId != null) {
                                          parentName =
                                              modules
                                                  .firstWhereOrNull(
                                                    (u) => u.id == m.parentId,
                                                  )
                                                  ?.name ??
                                              "";
                                        }
                                        groupings
                                            .putIfAbsent(parentName, () => [])
                                            .add(m.name);
                                      }

                                      return _buildMultiSelectSection(
                                        label: l10n.module,
                                        icon: Iconsax.book,
                                        items: filteredModules
                                            .map((m) => m.name)
                                            .toList(),
                                        selectedItems: _selectedModuleIds
                                            .map(
                                              (id) =>
                                                  filteredModules
                                                      .firstWhereOrNull(
                                                        (m) => m.id == id,
                                                      )
                                                      ?.name ??
                                                  '',
                                            )
                                            .where((n) => n.isNotEmpty)
                                            .toList(),
                                        onChanged: (selectedNames) {
                                          setState(() {
                                            _selectedModuleIds = selectedNames
                                                .map(
                                                  (name) => filteredModules
                                                      .firstWhere(
                                                        (m) => m.name == name,
                                                      )
                                                      .id,
                                                )
                                                .toList();
                                            _selectedLessonIds =
                                                []; //Reset child
                                            _selectedSources = []; //Reset child
                                          });
                                        },
                                        quizTheme: quizTheme,
                                        l10n: l10n,
                                        groupings: groupings.isNotEmpty
                                            ? groupings
                                            : null,
                                        maxItems: 10,
                                      );
                                    },
                                    loading: () => const SizedBox(
                                      height: 56,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    error: (err, _) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        "Erreur Modules: $err",
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),

                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _selectedModuleIds.isEmpty || !widget.isPractice
                            ? const SizedBox.shrink()
                            : Column(
                                children: [
                                  const SizedBox(height: 24),
                                  lessonsAsync.when(
                                    data: (lessons) => _buildMultiSelectSection(
                                      label: l10n.lessons,
                                      icon: Iconsax.document_text,
                                      items: lessons
                                          .map((l) => l.title)
                                          .toList(),
                                      selectedItems: _selectedLessonIds
                                          .map(
                                            (id) =>
                                                lessons
                                                    .firstWhereOrNull(
                                                      (l) => l.id == id,
                                                    )
                                                    ?.title ??
                                                '',
                                          )
                                          .where((t) => t.isNotEmpty)
                                          .toList()
                                          .cast<String>(),
                                      onChanged: (selectedTitles) {
                                        setState(() {
                                          _selectedLessonIds = selectedTitles
                                              .map(
                                                (title) => lessons
                                                    .firstWhere(
                                                      (l) => l.title == title,
                                                    )
                                                    .id,
                                              )
                                              .toList();
                                        });
                                      },
                                      quizTheme: quizTheme,
                                      l10n: l10n,
                                    ),
                                    loading: () => const SizedBox(
                                      height: 56,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    error: (err, _) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        "Erreur Cours: $err",
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _selectedModuleIds.isEmpty
                            ? const SizedBox.shrink()
                            : Column(
                                children: [
                                  sourcesAsync.when(
                                    data: (sources) => _buildMultiSelectSection(
                                      label: l10n.source,
                                      icon: Iconsax.category,
                                      items: sources,
                                      selectedItems: _selectedSources,
                                      onChanged: (selected) {
                                        setState(() {
                                          _selectedSources = selected;
                                        });
                                      },
                                      quizTheme: quizTheme,
                                      l10n: l10n,
                                      isSingleSelect: !widget.isPractice,
                                    ),
                                    loading: () => const SizedBox(
                                      height: 56,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    error: (err, _) => const SizedBox(),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                      ),

                      if (widget.isPractice) ...[
                        _buildSwitchSection(
                          label: "Mode Révision",
                          subtitle: "Afficher les réponses directement",
                          value: _isExplore,
                          onChanged: (val) {
                            setState(() {
                              _isExplore = val;
                            });
                          },
                          quizTheme: quizTheme,
                          primaryColor: primaryColor,
                        ),
                        const SizedBox(height: 24),
                        if (!_isExplore)
                          _buildDropdownSection(
                            label: "Mode de correction",
                            icon: Iconsax.edit,
                            items: ["Toute ou rien", "Points partiels"],
                            value:
                                _correctionMode ==
                                    QuizCorrectionMode.allOrNothing
                                ? "Toute ou rien"
                                : "Points partiels",
                            onChanged: (val) {
                              setState(() {
                                _correctionMode = val == "Toute ou rien"
                                    ? QuizCorrectionMode.allOrNothing
                                    : QuizCorrectionMode.partial;
                              });
                            },
                            quizTheme: quizTheme,
                            l10n: l10n,
                          ),
                      ] else
                        _buildDropdownSection(
                          label: "Durée de l'examen",
                          icon: Iconsax.timer_1,
                          items: [
                            "Aucune",
                            "30 min",
                            "60 min",
                            "90 min",
                            "120 min",
                            "180 min",
                          ],
                          value: _selectedTimeLimit == null
                              ? "Aucune"
                              : "$_selectedTimeLimit min",
                          onChanged: (val) {
                            setState(() {
                              if (val == "Aucune") {
                                _selectedTimeLimit = null;
                              } else {
                                _selectedTimeLimit = int.parse(
                                  val!.replaceAll("min", ""),
                                );
                              }
                            });
                          },
                          quizTheme: quizTheme,
                          l10n: l10n,
                        ),
                      _buildDropdownSection(
                        label: "Nombre de questions",
                        icon: Iconsax.document_text,
                        items: ["10", "20", "50", "100", "Toutes"],
                        value: _selectedQuestionCount == -1
                            ? "Toutes"
                            : _selectedQuestionCount.toString(),
                        onChanged: (val) {
                          setState(() {
                            if (val == "Toutes") {
                              _selectedQuestionCount = -1; // -1 for"All"
                            } else {
                              _selectedQuestionCount = int.parse(val!);
                            }
                          });
                        },
                        quizTheme: quizTheme,
                        l10n: l10n,
                      ),
                      const SizedBox(height: 48), //Bottom padding
                    ],
                  ),
                ),
              ),

              //Start Quiz Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: quizTheme.backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.white.withOpacity(0.02)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed:
                          (_selectedModuleIds.isEmpty ||
                              (!widget.isPractice && _selectedSources.isEmpty))
                          ? null
                          : () {
                              final filters = QuizFilters(
                                isPractice: widget
                                    .isPractice, //Practice flow if from Practice card
                                isExplore: widget.isPractice && _isExplore,
                                years: _selectedYears.isNotEmpty
                                    ? _selectedYears
                                    : null,
                                moduleIds: _selectedModuleIds.isNotEmpty
                                    ? _selectedModuleIds
                                    : null,
                                lessonIds: widget.isPractice
                                    ? _selectedLessonIds
                                    : [],
                                sources: _selectedSources,
                                correctionMode: widget.isPractice
                                    ? _correctionMode
                                    : QuizCorrectionMode.allOrNothing,
                                timeLimit: !widget.isPractice
                                    ? _selectedTimeLimit
                                    : null,
                                //If in Practice menu,toggle filters for Theo(false)or Clinical(true).
                                //If in Exam menu,fetch all(null).
                                hasClinicalCase: widget.isPractice
                                    ? _showClinicalOnly
                                    : null,
                                limit: _selectedQuestionCount == -1
                                    ? 100 //Cap"All"at 100 at once as requested
                                    : _selectedQuestionCount,
                              );

                              context.push('/quiz/session/new', extra: filters);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        elevation: 5,
                        shadowColor: primaryColor.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        (widget.isPractice && _isExplore)
                            ? l10n.startRevision
                            : l10n.startQuiz,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!isSubscriber) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.info_circle,
                            size: 14,
                            color: quizTheme.secondaryTextColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Free Trial:10 questions per session",
                            style: TextStyle(
                              fontSize: 12,
                              color: quizTheme.secondaryTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopToggle(
    AppLocalizations l10n,
    Color primaryColor,
    QuizThemeExtension quizTheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: quizTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: quizTheme.secondaryTextColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          _buildToggleOption(
            title: l10n.theoretical,
            isSelected: !_showClinicalOnly,
            onTap: () => setState(() {
              _showClinicalOnly = false;
            }),
            primaryColor: primaryColor,
            quizTheme: quizTheme,
          ),
          _buildToggleOption(
            title: l10n.clinical,
            isSelected: _showClinicalOnly,
            onTap: () => setState(() {
              _showClinicalOnly = true;
              if (_selectedSources.length > 1) {
                _selectedSources = [_selectedSources.first];
              }
            }),
            primaryColor: primaryColor,
            quizTheme: quizTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
    required QuizThemeExtension quizTheme,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? quizTheme.cardSelectedColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? primaryColor : quizTheme.secondaryTextColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownSection({
    required String label,
    required IconData icon,
    required List<String> items,
    required String? value,
    required ValueChanged<String?>? onChanged,
    required QuizThemeExtension quizTheme,
    required AppLocalizations l10n,
    bool isLocked = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: quizTheme.secondaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isLocked) ...[
              const SizedBox(width: 8),
              Icon(
                Iconsax.lock,
                size: 14,
                color: quizTheme.secondaryTextColor.withOpacity(0.5),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: quizTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: quizTheme.secondaryTextColor.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    hint: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.selectPrompt,
                        style: TextStyle(
                          color: quizTheme.secondaryTextColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                    isExpanded: true,
                    icon: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: quizTheme.primaryTextColor,
                      ),
                    ),
                    dropdownColor: quizTheme.cardColor,
                    items: items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            item,
                            style: TextStyle(color: quizTheme.primaryTextColor),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
              if (onChanged == null && isLocked)
                IconButton(
                  icon: const Icon(Iconsax.info_circle, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.upgradeToResidencyToUnlockYears),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  color: quizTheme.secondaryTextColor.withOpacity(0.5),
                ),
              Container(
                width: 1,
                height: 30,
                color: quizTheme.secondaryTextColor.withOpacity(0.1),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Icon(icon, color: quizTheme.primaryTextColor, size: 24),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchSection({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required QuizThemeExtension quizTheme,
    required Color primaryColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: quizTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: quizTheme.secondaryTextColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: quizTheme.primaryTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: quizTheme.secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: primaryColor),
        ],
      ),
    );
  }

  Widget _buildMultiSelectSection({
    required String label,
    required IconData icon,
    required List<String> items,
    required List<String> selectedItems,
    required ValueChanged<List<String>> onChanged,
    required QuizThemeExtension quizTheme,
    required AppLocalizations l10n,
    bool isSingleSelect = false,
    Map<String, List<String>>? groupings,
    int? maxItems,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: quizTheme.secondaryTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showMultiSelectBottomSheet(
            label: label,
            items: items,
            selectedItems: List.from(selectedItems),
            onChanged: onChanged,
            quizTheme: quizTheme,
            l10n: l10n,
            isSingleSelect: isSingleSelect,
            groupings: groupings,
            maxItems: maxItems,
          ),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: quizTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: quizTheme.secondaryTextColor.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedItems.isEmpty
                        ? (isSingleSelect ? l10n.selectPrompt : l10n.all)
                        : selectedItems.join(", "),
                    style: TextStyle(
                      color: selectedItems.isEmpty
                          ? quizTheme.secondaryTextColor.withOpacity(0.5)
                          : quizTheme.primaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: quizTheme.primaryTextColor),
                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 30,
                  color: quizTheme.secondaryTextColor.withOpacity(0.1),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: quizTheme.primaryTextColor, size: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showMultiSelectBottomSheet({
    required String label,
    required List<String> items,
    required List<String> selectedItems,
    required ValueChanged<List<String>> onChanged,
    required QuizThemeExtension quizTheme,
    required AppLocalizations l10n,
    bool isSingleSelect = false,
    Map<String, List<String>>? groupings,
    int? maxItems,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: quizTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        String searchQuery = "";
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredItems = items
                .where(
                  (item) =>
                      item.toLowerCase().contains(searchQuery.toLowerCase()),
                )
                .toList();

            final bool isAllSelected = items.every(
              (item) => selectedItems.contains(item),
            );

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  //Grab Handle
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: quizTheme.secondaryTextColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              color: quizTheme.primaryTextColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!isSingleSelect)
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                if (isAllSelected) {
                                  selectedItems.clear();
                                } else {
                                  if (maxItems != null &&
                                      items.length > maxItems) {
                                    //If too many,maybe just clear or toast.
                                    //For now,let's just not allow"Select All"if over limit
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Maximum$maxItems items allowed",
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    return;
                                  }
                                  selectedItems.addAll(items);
                                }
                              });
                              onChanged(List.from(selectedItems));
                            },
                            child: Text(
                              isAllSelected ? l10n.reset : l10n.all,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  //Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextField(
                      style: TextStyle(color: quizTheme.primaryTextColor),
                      decoration: InputDecoration(
                        hintText: l10n.search,
                        hintStyle: TextStyle(
                          color: quizTheme.secondaryTextColor.withOpacity(0.5),
                        ),
                        prefixIcon: Icon(
                          Iconsax.search_normal,
                          color: quizTheme.secondaryTextColor,
                        ),
                        filled: true,
                        fillColor: quizTheme.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          searchQuery = val;
                        });
                      },
                    ),
                  ),

                  //Selected Items Chips
                  if (selectedItems.isNotEmpty)
                    Container(
                      height: 50,
                      margin: const EdgeInsets.only(top: 16),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: selectedItems.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final item = selectedItems[index];
                          return Chip(
                            label: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: Theme.of(context).primaryColor,
                            deleteIcon: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                            onDeleted: () {
                              setModalState(() {
                                selectedItems.remove(item);
                              });
                              onChanged(List.from(selectedItems));
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.zero,
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 16),
                  Expanded(
                    child: filteredItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.search_status,
                                  size: 64,
                                  color: quizTheme.secondaryTextColor
                                      .withOpacity(0.2),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.noResultsFound(searchQuery),
                                  style: TextStyle(
                                    color: quizTheme.secondaryTextColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _buildHierarchicalList(
                            groupings: groupings,
                            items: filteredItems,
                            selectedItems: selectedItems,
                            isSingleSelect: isSingleSelect,
                            setModalState: setModalState,
                            onChanged: onChanged,
                            quizTheme: quizTheme,
                            l10n: l10n,
                            isSearching: searchQuery.isNotEmpty,
                            maxItems: maxItems,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        l10n.apply,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHierarchicalList({
    required Map<String, List<String>>? groupings,
    required List<String> items,
    required List<String> selectedItems,
    required bool isSingleSelect,
    required StateSetter setModalState,
    required ValueChanged<List<String>> onChanged,
    required QuizThemeExtension quizTheme,
    required AppLocalizations l10n,
    required bool isSearching,
    int? maxItems,
  }) {
    if (groupings == null || isSearching) {
      //Normal flat list if no groupings or searching
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildListItem(
            items[index],
            selectedItems,
            isSingleSelect,
            setModalState,
            onChanged,
            quizTheme,
            maxItems: maxItems,
          );
        },
      );
    }

    //Hierarchical list using persistent headers or ExpansionTiles
    final entries = groupings.entries.toList();
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final unityName = entry.key;
        final modules = entry.value;

        if (unityName.isEmpty) {
          return Column(
            children: modules
                .map(
                  (m) => _buildListItem(
                    m,
                    selectedItems,
                    isSingleSelect,
                    setModalState,
                    onChanged,
                    quizTheme,
                    maxItems: maxItems,
                  ),
                )
                .toList(),
          );
        }

        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              unityName,
              style: TextStyle(
                color: quizTheme.primaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              "${modules.length}modules",
              style: TextStyle(
                color: quizTheme.secondaryTextColor,
                fontSize: 12,
              ),
            ),
            tilePadding: const EdgeInsets.symmetric(horizontal: 8),
            childrenPadding: const EdgeInsets.only(left: 16),
            initiallyExpanded: true,
            children: modules
                .map(
                  (m) => _buildListItem(
                    m,
                    selectedItems,
                    isSingleSelect,
                    setModalState,
                    onChanged,
                    quizTheme,
                    maxItems: maxItems,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildListItem(
    String item,
    List<String> selectedItems,
    bool isSingleSelect,
    StateSetter setModalState,
    ValueChanged<List<String>> onChanged,
    QuizThemeExtension quizTheme, {
    int? maxItems,
  }) {
    final isSelected = selectedItems.contains(item);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          setModalState(() {
            if (isSingleSelect) {
              selectedItems.clear();
              selectedItems.add(item);
              onChanged(List.from(selectedItems));
              Navigator.pop(context);
              return;
            }
            if (isSelected) {
              selectedItems.remove(item);
            } else {
              if (maxItems != null && selectedItems.length >= maxItems) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Maximum$maxItems items allowed"),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                  ),
                );
                return;
              }
              selectedItems.add(item);
            }
          });
          onChanged(List.from(selectedItems));
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.08)
                : quizTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    color: quizTheme.primaryTextColor,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
              else
                Icon(
                  Icons.radio_button_unchecked,
                  color: quizTheme.secondaryTextColor.withOpacity(0.3),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
