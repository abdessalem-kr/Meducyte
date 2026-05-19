import 'package:meducyte_app/export.dart';

class InProgressCard extends ConsumerWidget {
  const InProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizSession = ref.watch(quizSessionProvider);
    final l10n = AppLocalizations.of(context)!;
    final isInitialized = quizSession.isInitialized;

    return InkWell(
      onTap: () {
        if (isInitialized) {
          context.push(AppRoutes.quizSession.replaceAll(':id', 'current'));
        } else {
          context.push(
            AppRoutes.quizTraining,
            extra: {'isPractice': true, 'isExplore': false},
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.inProgress.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Iconsax.play_circle,
                  color: Colors.white70,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isInitialized ? l10n.quizTraining : l10n.noActiveQuiz,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              isInitialized
                  ? '${quizSession.userAnswers.length}Questions'
                  : l10n.startNewQuiz,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (isInitialized) {
                    context.push(
                      AppRoutes.quizSession.replaceAll(':id', 'current'),
                    );
                  } else {
                    context.push(
                      AppRoutes.quizTraining,
                      extra: {'isPractice': true, 'isExplore': false},
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryDark,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  isInitialized ? l10n.continueQuiz : l10n.startNewQuiz,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
