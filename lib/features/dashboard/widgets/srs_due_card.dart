import 'package:meducyte_app/export.dart';

class SrsDueCard extends ConsumerWidget {
  const SrsDueCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueCountAsync = ref.watch(dueQuestionsCountProvider);
    final l10n = AppLocalizations.of(context)!;

    return dueCountAsync.when(
      data: (count) {
        final hasDue = count > 0;

        return InkWell(
          onTap: () {
            if (hasDue) {
              context.push(AppRoutes.srsSession);
            } else {
              context.push(AppRoutes.flashcards);
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
                        l10n.srsDueTitle.toUpperCase(),
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
                    const Icon(Iconsax.repeat, color: Colors.white70, size: 18),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  hasDue ? l10n.cardsDueText(count) : l10n.allCaughtUp,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (hasDue) {
                        context.push(AppRoutes.srsSession);
                      } else {
                        context.push(AppRoutes.flashcards);
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
                      hasDue ? l10n.startReview : l10n.flashcards,
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
      },
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (err, _) => Center(
        child: Text(
          err.toString(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
