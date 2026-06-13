import 'package:meducyte_app/export.dart';
import 'package:flutter/services.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/study_group_provider.dart';
import 'package:meducyte_app/features/productive_bay/data/repositories/calendar_repository.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/calendar_models.dart';

class QuizSelectionSheet extends ConsumerStatefulWidget {
  final StudyGroup group;
  final StudyGroupQuizSession? editingSession;

  const QuizSelectionSheet({
    super.key,
    required this.group,
    this.editingSession,
  });

  @override
  ConsumerState<QuizSelectionSheet> createState() => _QuizSelectionSheetState();
}

class _QuizSelectionSheetState extends ConsumerState<QuizSelectionSheet> {
  String? _loadingModuleId;
  String? _errorText;
  int? _selectedYear;
  bool _isClinical = false;
  bool _isScheduled = false;

  // Navigation / Drill-down state
  LearnModule? _selectedParentModule;

  //Configuration state
  LearnModule? _selectedModule;
  final List<String> _selectedLessonIds = [];
  int _questionCount = 20;
  int _secondsPerQuestion = 15;
  bool _isDiscussionMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.editingSession != null) {
      _questionCount = widget.editingSession!.questions.length;
      _secondsPerQuestion = widget.editingSession!.secondsPerQuestion;
      _isDiscussionMode = widget.editingSession!.secondsPerQuestion == 0;
      if (_secondsPerQuestion == 0) {
        _secondsPerQuestion = 15; //default for toggle back
      }
    } else {
      _isDiscussionMode = widget.group.type == StudyGroupType.silent;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authControllerProvider).value;
      if (user != null && user.year != 7) {
        setState(() => _selectedYear = user.year);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final modulesAsync = ref.watch(learnModulesProvider);
    final yearsAsync = ref.watch(quizYearsProvider);
    final user = ref.watch(authControllerProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    final canChangeYear = user?.year == 7;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              if (_selectedModule != null)
                IconButton(
                  onPressed: () => setState(() => _selectedModule = null),
                  icon: const Icon(Iconsax.arrow_left_2),
                )
              else if (_selectedParentModule != null)
                IconButton(
                  onPressed: () => setState(() => _selectedParentModule = null),
                  icon: const Icon(Iconsax.arrow_left_2),
                ),
              Expanded(
                child: Text(
                  widget.editingSession != null
                      ? "Modifier la session"
                      : (_selectedModule == null
                          ? (_selectedParentModule == null
                              ? l10n.selectTopic
                              : _selectedParentModule!.name)
                          : "Configuration"),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.editingSession != null
                ? "Modifiez les paramètres de la session active"
                : (_selectedModule == null
                    ? l10n.chooseModuleForBattle
                    : "Personnalisez votre duel pour ${_selectedModule!.name}"),
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: widget.editingSession != null
                  ? _buildConfiguration(isDark, primaryColor, l10n)
                  : (_selectedModule == null
                      ? _buildModuleSelection(
                          canChangeYear,
                          yearsAsync,
                          modulesAsync,
                          isDark,
                          primaryColor,
                          l10n,
                          user,
                        )
                      : _buildConfiguration(isDark, primaryColor, l10n)),
            ),
          ),

          if (_errorText != null) ...[
            const SizedBox(height: 16),
            _buildErrorBanner(),
          ],
        ],
      ),
    );
  }

  Widget _buildModuleSelection(
    bool canChangeYear,
    AsyncValue<List<int>> yearsAsync,
    AsyncValue<List<LearnModule>> modulesAsync,
    bool isDark,
    Color primaryColor,
    AppLocalizations l10n,
    User? user,
  ) {
    return Column(
      key: const ValueKey("modules"),
      children: [
        // FILTERS (only show if we aren't viewing child modules)
        if (_selectedParentModule == null) ...[
          Column(
            children: [
              if (canChangeYear) ...[
                yearsAsync.when(
                  data: (years) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedYear,
                          hint: Text(
                            l10n.selectStudyYear,
                            style: const TextStyle(fontSize: 14),
                          ),
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                          items: years.map((y) {
                            String label;
                            if (y == 7) {
                              label = l10n.residencyExam;
                            } else if (y == 1) {
                              label = l10n.firstYearOrdinal;
                            } else {
                              label = l10n.otherYearOrdinal(y.toString());
                            }
                            return DropdownMenuItem<int>(
                              value: y,
                              child: Text(
                                label,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedYear = val);
                          },
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox(height: 48),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 12),
              ] else if (user != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${l10n.studyYear}: ${user.year == 1 ? l10n.firstYearOrdinal : l10n.otherYearOrdinal(user.year.toString())}",
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              // TYPE TOGGLE (Theo vs Clinical)
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                child: Row(
                  children: [
                    _buildTypeButton(
                      label: l10n.theoretical,
                      isSelected: !_isClinical,
                      onTap: () => setState(() => _isClinical = false),
                    ),
                    _buildTypeButton(
                      label: l10n.clinical,
                      isSelected: _isClinical,
                      onTap: () => setState(() => _isClinical = true),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        Expanded(
          child: modulesAsync.when(
            data: (modules) {
              final modulesListToDisplay = _selectedParentModule != null
                  ? (_selectedParentModule!.children ?? [])
                  : (_selectedYear != null
                      ? modules.where((m) => m.year == _selectedYear).toList()
                      : modules);

              if (modulesListToDisplay.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.search_status,
                        size: 48,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noResultsFound(""),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: modulesListToDisplay.length,
                itemBuilder: (context, index) {
                  final module = modulesListToDisplay[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white10
                            : Colors.black.withOpacity(0.03),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Iconsax.book_1,
                          color: primaryColor,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        module.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        "${l10n.otherYearOrdinal(module.year.toString())} • ${module.description ?? 'Module d\'étude'}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      trailing: const Icon(Iconsax.arrow_right_3, size: 18),
                      onTap: () {
                        if (module.children != null && module.children!.isNotEmpty) {
                          setState(() {
                            _selectedParentModule = module;
                          });
                        } else {
                          setState(() {
                            _selectedModule = module;
                            _selectedLessonIds.clear();
                          });
                        }
                      },
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text("Error: $e")),
          ),
        ),
      ],
    );
  }

  Widget _buildConfiguration(
    bool isDark,
    Color primaryColor,
    AppLocalizations l10n,
  ) {
    if (_selectedModule == null && widget.editingSession == null) {
      return const SizedBox.shrink();
    }

    final lessonsAsync = _selectedModule != null
        ? ref.watch(moduleLessonsProvider(_selectedModule!.id))
        : null;

    return SingleChildScrollView(
      key: const ValueKey("config"),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedModule != null && lessonsAsync != null) ...[
            //LESSONS SELECTION
            Text(
              "Leçons (${_selectedLessonIds.length} sélectionnées)",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            lessonsAsync.when(
              data: (lessons) {
                if (lessons.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Text("Aucune leçon trouvée dans ce module"),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];
                    final isSelected = _selectedLessonIds.contains(lesson.id);
                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(
                        lesson.title,
                        style: const TextStyle(fontSize: 14),
                      ),
                      activeColor: primaryColor,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedLessonIds.add(lesson.id);
                          } else {
                            _selectedLessonIds.remove(lesson.id);
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text("Erreur: $e"),
              ),
            ),
            const SizedBox(height: 24),
          ],

          //QUESTION COUNT
          Text(
            "Nombre de questions",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [10, 20, 30, 50].map((count) {
              final isSelected = _questionCount == count;
              return GestureDetector(
                onTap: () => setState(() => _questionCount = count),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor
                        : (isDark
                            ? Colors.white10
                            : Colors.black.withOpacity(0.04)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black54),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          //TIMER CONFIG
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Mode Discussion (sans timer)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Switch.adaptive(
                value: _isDiscussionMode,
                activeColor: primaryColor,
                onChanged: (val) => setState(() => _isDiscussionMode = val),
              ),
            ],
          ),
          if (!_isDiscussionMode) ...[
            const SizedBox(height: 12),
            Text(
              "Temps par question (secondes)",
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [10, 15, 30, 60].map((seconds) {
                final isSelected = _secondsPerQuestion == seconds;
                return GestureDetector(
                  onTap: () => setState(() => _secondsPerQuestion = seconds),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor
                          : (isDark
                              ? Colors.white10
                              : Colors.black.withOpacity(0.04)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${seconds}s",
                      style: TextStyle(
                        color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black54),
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 24),
          //SCHEDULE TOGGLE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
            ),
            child: Row(
              children: [
                Icon(
                  Iconsax.calendar_1,
                  size: 20,
                  color: _isScheduled ? primaryColor : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: const Text(
                    "Programmer pour plus tard",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                Switch.adaptive(
                  value: _isScheduled,
                  activeColor: primaryColor,
                  onChanged: (val) => setState(() => _isScheduled = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          //START BUTTON
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _loadingModuleId != null
                  ? null
                  : () => _startOrSchedule(context, _selectedModule),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _loadingModuleId != null
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      widget.editingSession != null
                          ? "Mettre à jour la session"
                          : (_isScheduled
                              ? "Valider le planning"
                              : "Lancer le Duel"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(4),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startOrSchedule(
    BuildContext sheetContext,
    LearnModule? module,
  ) async {
    HapticFeedback.mediumImpact();

    if (_isScheduled) {
      _scheduleSession(sheetContext, module);
      return;
    }

    final navigator = Navigator.of(sheetContext);
    final router = GoRouter.of(sheetContext);

    setState(() {
      _loadingModuleId = module?.id;
      _errorText = null;
    });

    try {
      final title = _isClinical
          ? "Duel Clinique: ${module?.name}"
          : "Duel: ${module?.name}";

      StudyGroupQuizSession? session;
      if (widget.editingSession != null) {
        session = await ref
            .read(studyGroupRepositoryProvider)
            .updateQuizSession(
              widget.editingSession!.id,
              title: _isClinical
                  ? "Duel Clinique (Modifié)"
                  : widget.editingSession!.title,
              questionCount: _questionCount,
              isClinical: _isClinical,
              secondsPerQuestion: _isDiscussionMode ? 0 : _secondsPerQuestion,
            );
      } else {
        if (module == null) return;
        session = await ref
            .read(studyGroupRepositoryProvider)
            .startQuizSession(
              widget.group.id,
              module.id,
              title,
              lessonIds: _selectedLessonIds.isEmpty ? null : _selectedLessonIds,
              questionCount: _questionCount,
              isClinical: _isClinical,
              secondsPerQuestion: _isDiscussionMode ? 0 : _secondsPerQuestion,
            );
      }

      if (session != null) {
        ref.invalidate(activeStudyGroupQuizProvider(widget.group.id));

        if (sheetContext.mounted) {
          navigator.pop();
          router.pushNamed(
            AppRoutes.quizGroupStudy,
            pathParameters: {'id': widget.group.id},
            extra: {'session': session},
          );
        }
      } else {
        throw Exception("Impossible de créer la session");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingModuleId = null;
          _errorText = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _scheduleSession(
    BuildContext sheetContext,
    LearnModule? module,
  ) async {
    final now = DateTime.now();
    //Default to tomorrow at 18:00
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 18, 0);
    final moduleTitle = module?.name ?? "Battle";

    final event = StudyEvent(
      id: "temp_${DateTime.now().millisecondsSinceEpoch}",
      title: "Battle: $moduleTitle",
      startTime: tomorrow,
      endTime: tomorrow.add(const Duration(hours: 1)),
      color: Colors.green,
      type: StudyEventType.quiz,
      relatedId: widget.group.id,
    );

    try {
      await ref.read(calendarRepositoryProvider).syncEvent(event);
      if (sheetContext.mounted) {
        Navigator.pop(sheetContext);
        ScaffoldMessenger.of(sheetContext).showSnackBar(
          SnackBar(
            content: Text("Duel programmé pour demain à 18h"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _errorText = "Erreur lors de la programmation");
    }
  }
}
