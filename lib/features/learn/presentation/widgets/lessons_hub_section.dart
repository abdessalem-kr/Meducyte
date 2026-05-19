import 'package:meducyte_app/export.dart';

class LessonsHubSection extends ConsumerStatefulWidget {
  const LessonsHubSection({super.key});

  @override
  ConsumerState<LessonsHubSection> createState() => _LessonsHubSectionState();
}

class _LessonsHubSectionState extends ConsumerState<LessonsHubSection> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allLessonsAsync = ref.watch(allLessonsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      cacheExtent: 1000,
      slivers: [
        //1.Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _buildSearchBar(isDark, l10n),
          ),
        ),

        //2.Lessons List
        allLessonsAsync.when(
          data: (lessons) {
            final filteredLessons = lessons.where((l) {
              return l.title.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

            if (filteredLessons.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.document_filter,
                        size: 48,
                        color: isDark
                            ? AppColors.textSecondaryDark.withOpacity(0.5)
                            : AppColors.textSecondaryLight.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? l10n.noLessonsAvailable
                            : "No lessons match your search",
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final lesson = filteredLessons[index];
                  return _buildLessonItem(
                    context,
                    lesson,
                    primaryColor,
                    isDark,
                  );
                }, childCount: filteredLessons.length),
              ),
            );
          },
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) =>
              SliverFillRemaining(child: Center(child: Text('$err'))),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: "Search lessons...",
          hintStyle: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          prefixIcon: Icon(
            Iconsax.search_normal_1,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildLessonItem(
    BuildContext context,
    LearnLesson lesson,
    Color primaryColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight)
                  .withOpacity(0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Iconsax.book_1, color: primaryColor, size: 24),
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              const Icon(Icons.star, size: 14, color: AppColors.accentLight),
              const SizedBox(width: 4),
              const Text("4.9", style: TextStyle(fontSize: 12)),
              const SizedBox(width: 12),
              Icon(
                Iconsax.timer_1,
                size: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 4),
              const Text("15 min", style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        trailing: Icon(
          Iconsax.arrow_right_3,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          size: 16,
        ),
        onTap: () {
          context.push('/learn/course/${lesson.id}');
        },
      ),
    );
  }
}
