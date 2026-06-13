import 'package:meducyte_app/export.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:meducyte_app/shared/services/access_gating_service.dart';
import 'package:meducyte_app/features/learn/presentation/providers/lesson_interaction_provider.dart';
import 'package:meducyte_app/features/learn/presentation/widgets/lesson_comment_bottom_sheet.dart';
import 'package:meducyte_app/features/learn/presentation/widgets/lesson_report_bottom_sheet.dart';

class ModuleLessonsScreen extends ConsumerWidget {
  final String moduleId;

  const ModuleLessonsScreen({super.key, required this.moduleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(moduleLessonsProvider(moduleId));
    final modulesAsync = ref.watch(learnModulesProvider);
    final l10n = AppLocalizations.of(context)!;

    //Find module info for the title
    final module = modulesAsync.maybeWhen(
      data: (modules) => modules.firstWhere((m) => m.id == moduleId),
      orElse: () => null,
    );

    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, module, primaryColor, isDark, l10n),

          lessonsAsync.when(
            data: (lessons) {
              if (lessons.isEmpty) {
                return SliverFillRemaining(
                  child: Center(child: Text(l10n.noLessonsAvailable)),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final lesson = lessons[index];
                    return _buildLessonItem(
                      context,
                      lesson,
                      primaryColor,
                      isDark,
                      index,
                      l10n,
                      ref,
                    );
                  }, childCount: lessons.length),
                ),
              );
            },
            loading: () => SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Skeletonizer(
                    enabled: true,
                    child: _buildLessonItem(
                      context,
                      const LearnLesson(
                        id: 'dummy',
                        moduleId: 'dummy',
                        title: 'Titre de leçon factice en cours de chargement',
                        order: 1,
                        isFree: true,
                        isStudied: false,
                      ),
                      primaryColor,
                      isDark,
                      index,
                      l10n,
                      ref,
                    ),
                  );
                }, childCount: 3),
              ),
            ),
            error: (err, _) =>
                SliverFillRemaining(child: Center(child: Text('$err'))),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 50)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    LearnModule? module,
    Color primaryColor,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return SliverAppBar(
      expandedHeight: 150,
      pinned: true,
      backgroundColor: primaryColor,
      leading: IconButton(
        icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Iconsax.messages_3, color: Colors.white),
          onPressed: () =>
              _onChatTap(context, module?.id ?? moduleId, module: module),
        ),
        IconButton(
          icon: const Icon(Iconsax.flag, color: Colors.white),
          onPressed: () => _onFlagTap(context, module?.id ?? moduleId),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          module?.name ?? l10n.loading,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.backgroundDark],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                bottom: -30,
                child: Icon(
                  Iconsax.book_1,
                  size: 120,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLessonItem(
    BuildContext context,
    LearnLesson lesson,
    Color primaryColor,
    bool isDark,
    int index,
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
    final gating = ref.watch(accessGatingServiceProvider);
    final isFree = gating.canAccessModule(lesson);
    final isSubscriber = gating.hasActiveSubscription;
    final showBadge = isFree && !isSubscriber;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.push('/learn/course/${lesson.id}');
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    final params = (
                      id: lesson.id,
                      type: InteractionType.lesson,
                    );
                    ref
                        .read(interactionProvider(params).notifier)
                        .toggleLessonStudied();
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: lesson.isStudied
                          ? Colors.green.withOpacity(0.15)
                          : primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: lesson.isStudied
                          ? Border.all(
                              color: Colors.green.withOpacity(0.5),
                              width: 2,
                            )
                          : null,
                    ),
                    child: Center(
                      child: lesson.isStudied
                          ? const Icon(
                              Icons.check,
                              color: Colors.green,
                              size: 24,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lesson.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (showBadge)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                l10n.freeBadge,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.accessContent,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Iconsax.arrow_right_3,
                  size: 20,
                  color: primaryColor.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onChatTap(
    BuildContext context,
    String moduleId, {
    LearnModule? module,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InteractionCommentBottomSheet(
        id: moduleId,
        type: InteractionType.course,
        module: module,
        initialTabIndex: 0,
      ),
    );
  }

  void _onFlagTap(BuildContext context, String moduleId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InteractionReportBottomSheet(
        id: moduleId,
        type: InteractionType.course,
      ),
    );
  }
}
