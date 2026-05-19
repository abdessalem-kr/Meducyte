import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';
import 'package:meducyte_app/shared/widgets/subscription_gate.dart';

class FlashcardsScreen extends ConsumerWidget {
  const FlashcardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;

    return SubscriptionGate(
      child: Scaffold(
        backgroundColor: quizTheme.backgroundColor,
        appBar: AppBar(
          title: Text(l10n.flashcards),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, l10n, quizTheme),
              const SizedBox(height: 32),
              Text(
                l10n.studyDecks,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: quizTheme.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 16),
              _buildDeckCard(
                context: context,
                ref: ref,
                title: l10n.savedQuizzes,
                subtitle: l10n.savedQuizzesSubtitle,
                icon: Iconsax.bookmark,
                color: const Color(0xFF6366F1),
                onTap: () => _startStudyFromSaved(context, ref),
              ),
              const SizedBox(height: 16),
              _buildDeckCard(
                context: context,
                ref: ref,
                title: l10n.spacedRepetition,
                subtitle: l10n.spacedRepetitionSubtitle,
                icon: Iconsax.repeat,
                color: AppColors.primary,
                onTap: () => _startStudyFromSrs(context, ref),
              ),
              const SizedBox(height: 16),
              _buildDeckCard(
                context: context,
                ref: ref,
                title: l10n.byModule,
                subtitle: l10n.byModuleSubtitle,
                icon: Iconsax.box,
                color: const Color(0xFFF59E0B),
                onTap: () => _showModulePicker(context, ref),
              ),
              const SizedBox(height: 16),
              _buildDeckCard(
                context: context,
                ref: ref,
                title: l10n.folders,
                subtitle: l10n.studyByFolder,
                icon: Iconsax.folder,
                color: const Color(0xFF10B981),
                onTap: () => _showFolderPicker(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    QuizThemeExtension quizTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.masterYourMemory,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.flashcardsHeaderSubtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Iconsax.flash_1, color: Colors.white, size: 48),
        ],
      ),
    );
  }

  Widget _buildDeckCard({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: quizTheme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: quizTheme.secondaryTextColor.withOpacity(0.05),
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: quizTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              size: 16,
              color: quizTheme.secondaryTextColor.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startStudyFromSaved(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;

    //Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final savedQuestions = await ref.read(mySavedQuestionsProvider.future);
      final questions = savedQuestions
          .where((s) => s.question != null)
          .map((s) => s.question!)
          .toList();

      if (!context.mounted) return;
      context.pop(); //dismiss loading

      if (questions.isEmpty) {
        AppSnackBars.error(context, l10n.noSavedQuestionsToStudy);
        return;
      }

      context.push(
        AppRoutes.flashcardStudy,
        extra: {'questions': questions, 'title': l10n.savedQuizzes},
      );
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        context.pop();
        AppSnackBars.error(context, l10n.errorLoadingQuestionsShort);
      }
    }
  }

  Future<void> _startStudyFromSrs(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final srsRepo = ref.read(srsRepositoryProvider);
      final quizRepo = ref.read(quizRepositoryProvider);

      final dueReviews = await srsRepo.getDueReviews();
      final ids = dueReviews.map((r) => r.questionId).toSet().toList();

      if (ids.isEmpty) {
        if (!context.mounted) return;
        context.pop();
        AppSnackBars.success(context, l10n.allCaughtUp);
        return;
      }

      final questions = await quizRepo.getQuestionsByIds(ids);

      if (!context.mounted) return;
      context.pop();

      context.push(
        AppRoutes.flashcardStudy,
        extra: {'questions': questions, 'title': l10n.spacedRepetition},
      );
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        context.pop();
        AppSnackBars.error(context, l10n.errorLoadingQuestionsShort);
      }
    }
  }

  void _showModulePicker(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    final modulesAsync = ref.read(learnModulesProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: quizTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => modulesAsync.when(
        data: (modules) => Column(
          children: [
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
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.selectModule,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final module = modules[index];
                  return ListTile(
                    title: Text(module.name),
                    subtitle: Text(
                      l10n.otherYearOrdinal(module.year.toString()),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _startStudyFromModule(context, ref, module);
                    },
                  );
                },
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Future<void> _startStudyFromModule(
    BuildContext context,
    WidgetRef ref,
    LearnModule module,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final quizRepo = ref.read(quizRepositoryProvider);
      final session = await quizRepo.startPracticeSession(
        QuizFilters(isPractice: true, moduleIds: [module.id]),
      );

      if (!context.mounted) return;
      context.pop();

      final l10n = AppLocalizations.of(context)!;
      if (session.questions.isEmpty) {
        AppSnackBars.error(context, l10n.noQuestionsInModule);
        return;
      }

      context.push(
        AppRoutes.flashcardStudy,
        extra: {'questions': session.questions, 'title': module.name},
      );
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        context.pop();
        AppSnackBars.error(context, l10n.errorLoadingQuestionsShort);
      }
    }
  }

  void _showFolderPicker(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    final foldersAsync = ref.read(myQuestionFoldersProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: quizTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => foldersAsync.when(
        data: (folders) => Column(
          children: [
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
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.selectFolder,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: folders.length,
                itemBuilder: (context, index) {
                  final folder = folders[index];
                  final color = folder.color != null
                      ? Color(
                          int.parse(folder.color!.replaceFirst('#', '0xFF')),
                        )
                      : AppColors.primary;

                  return ListTile(
                    leading: Icon(Iconsax.folder_2, color: color),
                    title: Text(folder.name),
                    onTap: () {
                      Navigator.pop(context);
                      _startStudyFromFolder(context, ref, folder);
                    },
                  );
                },
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Future<void> _startStudyFromFolder(
    BuildContext context,
    WidgetRef ref,
    QuestionFolder folder,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final savedQuestions = await ref.read(mySavedQuestionsProvider.future);
      final questions = savedQuestions
          .where((s) => s.folderId == folder.id && s.question != null)
          .map((s) => s.question!)
          .toList();

      if (!context.mounted) return;
      context.pop();

      final l10n = AppLocalizations.of(context)!;
      if (questions.isEmpty) {
        AppSnackBars.error(context, l10n.noQuestionsInFolder);
        return;
      }

      context.push(
        AppRoutes.flashcardStudy,
        extra: {'questions': questions, 'title': folder.name},
      );
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        context.pop();
        AppSnackBars.error(context, l10n.errorLoadingQuestionsShort);
      }
    }
  }
}
