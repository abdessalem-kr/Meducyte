import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';
import 'package:meducyte_app/features/quiz/domain/models/quiz_note_entry.dart';
import 'package:meducyte_app/features/quiz/presentation/providers/quiz_notes_provider.dart';
import 'package:intl/intl.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? selectedModuleName;
  int? selectedYear;
  String? selectedType; // 'theoretical'or'clinical'
  String? selectedCategory; // 'global'or'highlight'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(quizNotesProvider);
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.notes),
        centerTitle: true,
        elevation: 0,
        actions: [
          notesAsync.maybeWhen(
            data: (allNotes) {
              if (allNotes.isEmpty) return const SizedBox.shrink();
              final hasActiveFilters =
                  selectedYear != null ||
                  selectedType != null ||
                  selectedCategory != null;
              return IconButton(
                onPressed: () => _showFilterSheet(context, allNotes),
                icon: Stack(
                  children: [
                    const Icon(Iconsax.filter),
                    if (hasActiveFilters)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: notesAsync.when(
        data: (allNotes) {
          if (allNotes.isEmpty) {
            return _buildEmptyState(l10n, isDark);
          }

          //Filter by module
          var filteredNotes = selectedModuleName == null
              ? allNotes
              : allNotes
                    .where((n) => n.moduleName == selectedModuleName)
                    .toList();
          //Filter by year
          final user = ref.watch(authControllerProvider).value;
          final is1to6YearUser = user != null && user.year >= 1 && user.year <= 6;
          final activeYearFilter = is1to6YearUser ? user.year : selectedYear;
          if (activeYearFilter != null) {
            filteredNotes = filteredNotes
                .where((n) => n.year == activeYearFilter)
                .toList();
          }

          //Filter by type
          if (selectedType != null) {
            if (selectedType == 'theoretical') {
              filteredNotes = filteredNotes
                  .where((n) => n.clinicalCaseId == null)
                  .toList();
            } else {
              filteredNotes = filteredNotes
                  .where((n) => n.clinicalCaseId != null)
                  .toList();
            }
          }

          //Filter by category
          if (selectedCategory != null) {
            if (selectedCategory == 'global') {
              filteredNotes = filteredNotes.where((n) => n.isGlobal).toList();
            } else {
              filteredNotes = filteredNotes.where((n) => !n.isGlobal).toList();
            }
          }

          //Filter by search query
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            filteredNotes = filteredNotes.where((n) {
              return n.note.toLowerCase().contains(query) ||
                  (n.highlightText?.toLowerCase().contains(query) ?? false) ||
                  n.questionText.toLowerCase().contains(query) ||
                  (n.lessonTitle?.toLowerCase().contains(query) ?? false);
            }).toList();
          }

          //Get unique modules for filtering
          final modules =
              allNotes
                  .map((n) => n.moduleName)
                  .whereType<String>()
                  .toSet()
                  .toList()
                ..sort();

          return Column(
            children: [
              _buildSearchBar(l10n, isDark),
              if (modules.isNotEmpty) _buildModuleSelector(modules, isDark),
              Expanded(
                child: filteredNotes.isEmpty
                    ? _buildNoResultsState(l10n, isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredNotes.length,
                        itemBuilder: (context, index) {
                          return _NoteCard(
                            note: filteredNotes[index],
                            quizTheme: quizTheme,
                            isDark: isDark,
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value.trim()),
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
    );
  }

  Widget _buildModuleSelector(List<String> modules, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: modules.length + 1,
        itemBuilder: (context, index) {
          final isSelected = index == 0
              ? selectedModuleName == null
              : selectedModuleName == modules[index - 1];
          final label = index == 0 ? l10n.all : modules[index - 1];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) {
                setState(
                  () => selectedModuleName = index == 0
                      ? null
                      : modules[index - 1],
                );
              },
              backgroundColor: isDark
                  ? AppColors.cardDark
                  : AppColors.cardLight,
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.note_2,
            size: 64,
            color:
                (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight)
                    .withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noNotes,
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

  Widget _buildNoResultsState(AppLocalizations l10n, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.search_status,
            size: 48,
            color:
                (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight)
                    .withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noResultsFound(_searchQuery),
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
  void _showFilterSheet(BuildContext context, List<QuizNoteEntry> allNotes) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.read(authControllerProvider).value;
    final is1to6YearUser = user != null && user.year >= 1 && user.year <= 6;

    final years = allNotes.map((n) => n.year).whereType<int>().toSet().toList()
      ..sort();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.backgroundDark
                : AppColors.backgroundLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.filters,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedYear = null;
                        selectedType = null;
                        selectedCategory = null;
                      });
                      Navigator.pop(context);
                    },
                    child: Text(l10n.reset),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),

              //Year Filter
              if (!is1to6YearUser && years.isNotEmpty) ...[
                Text(
                  l10n.year,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: years.map((y) {
                    final isSelected = selectedYear == y;
                    final label = y == 1
                        ? l10n.firstYearOrdinal
                        : l10n.otherYearOrdinal(y);
                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (val) {
                        setModalState(() => selectedYear = val ? y : null);
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],

              //Type Filter
              Text(
                l10n.simulation, //or something for Type
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  ChoiceChip(
                    label: Text(l10n.theoretical),
                    selected: selectedType == 'theoretical',
                    onSelected: (val) {
                      setModalState(
                        () => selectedType = val ? 'theoretical' : null,
                      );
                      setState(() {});
                    },
                  ),
                  ChoiceChip(
                    label: Text(l10n.clinicalCases),
                    selected: selectedType == 'clinical',
                    onSelected: (val) {
                      setModalState(
                        () => selectedType = val ? 'clinical' : null,
                      );
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              //Category Filter
              const Text(
                "Note Source", //Need to localize or use generic
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  ChoiceChip(
                    label: const Text("Question Note"),
                    selected: selectedCategory == 'global',
                    onSelected: (val) {
                      setModalState(
                        () => selectedCategory = val ? 'global' : null,
                      );
                      setState(() {});
                    },
                  ),
                  ChoiceChip(
                    label: const Text("Segment Highlight"),
                    selected: selectedCategory == 'highlight',
                    onSelected: (val) {
                      setModalState(
                        () => selectedCategory = val ? 'highlight' : null,
                      );
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(l10n.apply),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final QuizNoteEntry note;
  final QuizThemeExtension quizTheme;
  final bool isDark;

  const _NoteCard({
    required this.note,
    required this.quizTheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: InkWell(
        onTap: () {
          context.push(
            AppRoutes.quizSession,
            extra: QuizFilters(
              isPractice: true,
              questionIds: [note.questionId.toString()],
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: note.isGlobal
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      note.isGlobal ? "Global Note" : "Highlight Note",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: note.isGlobal
                            ? AppColors.primary
                            : Colors.orange,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('dd/MM/yyyy').format(note.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (note.highlightText != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(
                      0.03,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      left: BorderSide(
                        color: Colors.orange.withOpacity(0.5),
                        width: 4,
                      ),
                    ),
                  ),
                  child: Text(
                    note.highlightText!,
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                note.note,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (note.clinicalCaseTitle != null)
                          Text(
                            note.clinicalCaseTitle!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text(
                          note.questionText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Iconsax.arrow_right_3,
                    size: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ],
              ),
              if (note.lessonTitle != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Iconsax.book_1,
                      size: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "${note.moduleName ?? ''} > ${note.lessonTitle}",
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
