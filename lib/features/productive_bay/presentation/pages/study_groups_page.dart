import 'package:meducyte_app/export.dart';
import 'package:flutter/services.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/study_group_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StudyGroupsPage extends ConsumerStatefulWidget {
  const StudyGroupsPage({super.key});

  @override
  ConsumerState<StudyGroupsPage> createState() => _StudyGroupsPageState();
}

class _StudyGroupsPageState extends ConsumerState<StudyGroupsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedType; // null = All

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StudyGroup> _applyFilters(List<StudyGroup> groups) {
    return groups.where((g) {
      final matchesSearch = _searchQuery.isEmpty ||
          g.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          g.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _selectedType == null ||
          g.type.name.toLowerCase() == _selectedType!.toLowerCase();
      return matchesSearch && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final myGroupsAsync = ref.watch(myStudyGroupsProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        onRefresh: () async {
          ref.invalidate(availableStudyGroupsProvider);
          ref.invalidate(myStudyGroupsProvider);
          try {
            await ref.read(myStudyGroupsProvider.future);
          } catch (_) {}
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverAppBar(
              title: Text(
                context.l10n.studyGroups,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: -0.5,
                ),
              ),
              backgroundColor: isDark
                  ? AppColors.backgroundDark
                  : AppColors.backgroundLight,
              elevation: 0,
              pinned: true,
              centerTitle: false,
              expandedHeight: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.05),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Search bar ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          decoration: InputDecoration(
                            hintText: 'Rechercher un groupe...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 16, right: 12),
                              child: Icon(
                                Iconsax.search_normal,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close_rounded, size: 18),
                                    color: Colors.grey,
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    // ── Filter chips ──
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          _FilterChip(
                            label: 'Tous',
                            icon: Iconsax.category,
                            isSelected: _selectedType == null,
                            onTap: () => setState(() => _selectedType = null),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Silent',
                            icon: Iconsax.volume_cross,
                            isSelected: _selectedType == 'silent',
                            onTap: () => setState(
                              () => _selectedType = _selectedType == 'silent' ? null : 'silent',
                            ),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'QCM Battle',
                            icon: Iconsax.flash,
                            isSelected: _selectedType == 'qcmBattle',
                            onTap: () => setState(
                              () => _selectedType = _selectedType == 'qcmBattle' ? null : 'qcmBattle',
                            ),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Focus',
                            icon: Iconsax.timer_1,
                            isSelected: _selectedType == 'focus',
                            onTap: () => setState(
                              () => _selectedType = _selectedType == 'focus' ? null : 'focus',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // ── Groups list ──
                    myGroupsAsync.when(
                      data: (groups) {
                        final filtered = _applyFilters(groups);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildSectionHeader(context.l10n.myActiveGroups),
                                  if (groups.isNotEmpty)
                                    Text(
                                      '${filtered.length}/${groups.length}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white38 : Colors.black38,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              if (filtered.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 40),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _searchQuery.isNotEmpty || _selectedType != null
                                              ? Iconsax.search_status
                                              : Iconsax.people,
                                          size: 48,
                                          color: Colors.grey.withOpacity(0.5),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          _searchQuery.isNotEmpty || _selectedType != null
                                              ? 'Aucun groupe trouvé'
                                              : context.l10n.noActiveGroups,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (_searchQuery.isNotEmpty || _selectedType != null) ...[
                                          const SizedBox(height: 8),
                                          TextButton(
                                            onPressed: () => setState(() {
                                              _searchController.clear();
                                              _searchQuery = '';
                                              _selectedType = null;
                                            }),
                                            child: const Text('Effacer les filtres'),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                )
                              else
                                Column(
                                  children: filtered.map((group) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _buildMiniGroupTile(
                                        context,
                                        group.title,
                                        context.l10n.pomodorosToday,
                                        group.icon,
                                        group.themeColor,
                                        onTap: () {
                                          context.pushNamed(
                                            AppRoutes.studyGroupDetails,
                                            pathParameters: {'id': group.id},
                                            extra: {'group': group},
                                          ).then((_) {
                                            ref.invalidate(availableStudyGroupsProvider);
                                            ref.invalidate(myStudyGroupsProvider);
                                          });
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        );
                      },
                      loading: () => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(context.l10n.myActiveGroups),
                            const SizedBox(height: 20),
                            Skeletonizer(
                              enabled: true,
                              child: _buildMiniGroupTile(
                                context,
                                "Groupe d'étude factice de chargement",
                                "10 pomodoros aujourd'hui",
                                Iconsax.timer_1,
                                AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                      error: (e, s) => Center(child: Text("Erreur: $e")),
                    ),
                    const SizedBox(height: 100), // FAB space
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showCreateGroupSheet(context),
          label: Text(
            context.l10n.createGroup,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          icon: const Icon(Iconsax.add_circle, size: 20),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildMiniGroupTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
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
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              size: 18,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateGroupSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CreateGroupSheet(),
    );
  }
}

// ── Filter chip widget ──────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : isDark
              ? AppColors.surfaceDark
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isDark
                ? AppColors.dividerDark
                : AppColors.dividerLight,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? Colors.white
                  : isDark
                  ? Colors.white54
                  : Colors.black54,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isSelected
                    ? Colors.white
                    : isDark
                    ? Colors.white54
                    : Colors.black54,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateGroupSheet extends ConsumerStatefulWidget {
  const _CreateGroupSheet();

  @override
  ConsumerState<_CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends ConsumerState<_CreateGroupSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String selectedType = "Silent";
  // Module/lesson selection
  String? selectedModuleId;
  String? selectedModuleName;
  String? selectedLessonId;
  String? selectedLessonName;
  // Expanded module for lesson drill-down
  String? expandedModuleId;
  Color selectedColor = AppColors.primary;
  bool isLoading = false;

  final List<Color> _availableColors = [
    AppColors.primary,
    Colors.teal,
    Colors.pinkAccent,
    Colors.orange,
    Colors.blueGrey,
    Colors.indigo,
  ];

  void _handleCreate() async {
    if (_nameController.text.isEmpty) return;

    setState(() => isLoading = true);
    HapticFeedback.lightImpact(); //Use lightImpact for smoother feel

    final repository = ref.read(studyGroupRepositoryProvider);
    final type = selectedType == "Silent"
        ? StudyGroupType.silent
        : selectedType == "QCM Battle"
        ? StudyGroupType.qcmBattle
        : StudyGroupType.focus;

    // Build category & tags from module/lesson selection
    final category = selectedModuleName ?? 'Général';
    final tags = [
      selectedType,
      if (selectedModuleName != null) selectedModuleName!,
      if (selectedLessonName != null) selectedLessonName!,
    ];

    final newGroup = StudyGroup(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _nameController.text,
      description: _descriptionController.text.isEmpty
          ? "Travail intensif en groupe."
          : _descriptionController.text,
      membersCount: 0,
      totalPomodoros: 0,
      tags: tags,
      themeColor: selectedColor,
      icon: type == StudyGroupType.silent
          ? Iconsax.book_1
          : type == StudyGroupType.qcmBattle
          ? Iconsax.flash
          : Iconsax.timer_1,
      type: type,
      category: category,
    );

    try {
      await repository.createGroup(newGroup);

      //Refresh the available groups and user's active groups
      ref.invalidate(availableStudyGroupsProvider);
      ref.invalidate(myStudyGroupsProvider);

      if (!mounted) return;

      setState(() => isLoading = false);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Iconsax.tick_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                context.l10n.roomCreatedSuccess,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${context.l10n.roomCreationError}: $e"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 40,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.createRoom,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: -0.5,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Iconsax.close_circle, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              context.l10n.roomNameLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: "Ex:Prépa Neuro-Chirurgie J-10",
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(18),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.descriptionOptional,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              maxLength: 120,
              decoration: InputDecoration(
                hintText: "Objectifs,règles de la salle...",
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                counterStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(18),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              context.l10n.sessionType,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildTypeOption(
                  "Silent",
                  Iconsax.volume_cross,
                  context.l10n.silent,
                  'Travail calme,\nsans interactions',
                ),
                const SizedBox(width: 10),
                _buildTypeOption(
                  "QCM Battle",
                  Iconsax.flash,
                  context.l10n.qcmBattle,
                  'Quiz en temps réel\ncontre tes amis',
                ),
                const SizedBox(width: 10),
                _buildTypeOption(
                  "Focus",
                  Iconsax.timer_1,
                  context.l10n.focus,
                  'Sessions Pomodoro\nminutées',
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              context.l10n.themeColorLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _availableColors.length,
                separatorBuilder: (context, _) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final color = _availableColors[index];
                  final isSelected = selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => selectedColor = color);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: isDark ? Colors.white : Colors.black,
                                width: 3,
                              )
                            : null,
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'MODULE & COURS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            // Module selector row
            ref.watch(learnModulesProvider).when(
              loading: () => _buildSelectorRow(
                context,
                isDark,
                icon: Iconsax.book_1,
                label: 'Chargement des modules...',
                hasValue: false,
                onTap: null,
              ),
              error: (_, __) => _buildSelectorRow(
                context,
                isDark,
                icon: Iconsax.book_1,
                label: 'Erreur de chargement',
                hasValue: false,
                onTap: null,
              ),
              data: (modules) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSelectorRow(
                    context,
                    isDark,
                    icon: Iconsax.book_1,
                    label: selectedModuleName ?? 'Choisir un module...',
                    hasValue: selectedModuleId != null,
                    onTap: () => _pickModule(context, isDark, modules),
                    onClear: selectedModuleId != null
                        ? () => setState(() {
                              selectedModuleId = null;
                              selectedModuleName = null;
                              selectedLessonId = null;
                              selectedLessonName = null;
                            })
                        : null,
                  ),
                  if (selectedModuleId != null) ...[
                    const SizedBox(height: 8),
                    _buildSelectorRow(
                      context,
                      isDark,
                      icon: Iconsax.document_text,
                      label: selectedLessonName ?? 'Choisir un cours (optionnel)',
                      hasValue: selectedLessonId != null,
                      onTap: () {
                        final mod = modules.firstWhere(
                          (m) => m.id == selectedModuleId,
                        );
                        final lessons = mod.lessons ?? [];
                        if (lessons.isNotEmpty) {
                          _pickLesson(context, isDark, lessons);
                        }
                      },
                      onClear: selectedLessonId != null
                          ? () => setState(() {
                                selectedLessonId = null;
                                selectedLessonName = null;
                              })
                          : null,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide.none,
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "CRÉER LA SALLE",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(
    String id,
    IconData icon,
    String label,
    String subtitle,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = selectedType == id;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => selectedType = id);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.08)
                : isDark
                ? Colors.white.withOpacity(0.03)
                : Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : isDark
                  ? Colors.white12
                  : Colors.black12,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : isDark
                      ? Colors.white10
                      : Colors.black.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Colors.white
                      : isDark
                      ? Colors.white54
                      : Colors.black45,
                  size: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isSelected
                      ? AppColors.primary
                      : isDark
                      ? Colors.white70
                      : Colors.black87,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white38 : Colors.black38,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Compact selector row ─────────────────────────────────────────────────
  Widget _buildSelectorRow(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String label,
    required bool hasValue,
    required VoidCallback? onTap,
    VoidCallback? onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: hasValue
              ? AppColors.primary.withOpacity(0.06)
              : isDark
              ? Colors.white.withOpacity(0.04)
              : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasValue
                ? AppColors.primary.withOpacity(0.5)
                : isDark
                ? Colors.white12
                : Colors.black12,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: hasValue ? AppColors.primary : (isDark ? Colors.white38 : Colors.black38),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: hasValue ? FontWeight.w700 : FontWeight.w500,
                  color: hasValue
                      ? (isDark ? Colors.white : Colors.black87)
                      : (isDark ? Colors.white38 : Colors.black38),
                ),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded, size: 16, color: Colors.grey),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
          ],
        ),
      ),
    );
  }

  // ── Module picker sheet ───────────────────────────────────────────────────
  void _pickModule(BuildContext context, bool isDark, List<LearnModule> modules) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Choisir un module',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                shrinkWrap: true,
                itemCount: modules.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final mod = modules[i];
                  final isSelected = selectedModuleId == mod.id;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        selectedModuleId = mod.id;
                        selectedModuleName = mod.name;
                        selectedLessonId = null;
                        selectedLessonName = null;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : isDark
                            ? Colors.white.withOpacity(0.05)
                            : AppColors.primary.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : isDark
                              ? Colors.white12
                              : AppColors.primary.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.book_1,
                            size: 16,
                            color: isSelected ? Colors.white : AppColors.primary.withOpacity(0.7),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              mod.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Lesson picker sheet ───────────────────────────────────────────────────
  void _pickLesson(BuildContext context, bool isDark, List<LearnLesson> lessons) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Choisir un cours',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                shrinkWrap: true,
                itemCount: lessons.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final lesson = lessons[i];
                  final isSelected = selectedLessonId == lesson.id;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        selectedLessonId = lesson.id;
                        selectedLessonName = lesson.title;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : isDark
                            ? Colors.white.withOpacity(0.04)
                            : Colors.black.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : isDark ? Colors.white10 : Colors.black.withOpacity(0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Iconsax.tick_circle : Iconsax.document_text,
                            size: 14,
                            color: isSelected
                                ? AppColors.primary
                                : isDark ? Colors.white38 : Colors.black38,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              lesson.title,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primary
                                    : isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
