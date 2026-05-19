import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';
import 'package:meducyte_app/features/learn/presentation/providers/lesson_interaction_provider.dart';

class InteractionReportBottomSheet extends ConsumerWidget {
  final String id;
  final InteractionType type;

  const InteractionReportBottomSheet({
    super.key,
    required this.id,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (id: id, type: type);
    final state = ref.watch(interactionProvider(params));
    final notifier = ref.read(interactionProvider(params).notifier);
    final l10n = AppLocalizations.of(context)!;
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;

    if (state.isReportingSuccess) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: quizTheme.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.reportSent,
              style: TextStyle(
                color: quizTheme.primaryTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('OK'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: quizTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: quizTheme.secondaryTextColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              type == InteractionType.lesson
                  ? l10n.reportError
                  : "Report Course",
              style: TextStyle(
                color: quizTheme.primaryTextColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.selectReason,
              style: TextStyle(
                color: quizTheme.secondaryTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            _ReasonTile(
              label: l10n.reasonTypo,
              isSelected: state.selectedReportReason == LearnReportReason.typo,
              onTap: () => notifier.setReportReason(LearnReportReason.typo),
              quizTheme: quizTheme,
            ),
            _ReasonTile(
              label: l10n.reasonInaccurate,
              isSelected:
                  state.selectedReportReason == LearnReportReason.inaccurate,
              onTap: () =>
                  notifier.setReportReason(LearnReportReason.inaccurate),
              quizTheme: quizTheme,
            ),
            _ReasonTile(
              label: l10n.reasonMissing,
              isSelected:
                  state.selectedReportReason == LearnReportReason.missing,
              onTap: () => notifier.setReportReason(LearnReportReason.missing),
              quizTheme: quizTheme,
            ),
            _ReasonTile(
              label: l10n.reasonUnclearExplanation,
              isSelected:
                  state.selectedReportReason == LearnReportReason.unclear,
              onTap: () => notifier.setReportReason(LearnReportReason.unclear),
              quizTheme: quizTheme,
            ),
            _ReasonTile(
              label: l10n.reasonOther,
              isSelected: state.selectedReportReason == LearnReportReason.other,
              onTap: () => notifier.setReportReason(LearnReportReason.other),
              quizTheme: quizTheme,
            ),
            if (state.selectedReportReason == LearnReportReason.other) ...[
              const SizedBox(height: 16),
              TextField(
                onChanged: notifier.setCustomReportDescription,
                maxLines: 3,
                style: TextStyle(color: quizTheme.primaryTextColor),
                decoration: InputDecoration(
                  hintText: l10n.otherDescription,
                  hintStyle: TextStyle(
                    color: quizTheme.secondaryTextColor.withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: quizTheme.secondaryTextColor.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed:
                  state.selectedReportReason == null || state.isReportingLoading
                  ? null
                  : () => notifier.report(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: quizTheme.secondaryTextColor
                    .withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: state.isReportingLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l10n.sendReport,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final QuizThemeExtension quizTheme;

  const _ReasonTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.quizTheme,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.1)
              : quizTheme.secondaryTextColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? quizTheme.primaryTextColor
                      : quizTheme.secondaryTextColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: primaryColor, size: 20),
          ],
        ),
      ),
    );
  }
}

//Deprecated alias for compatibility
class LessonReportBottomSheet extends InteractionReportBottomSheet {
  const LessonReportBottomSheet({super.key, required String lessonId})
    : super(id: lessonId, type: InteractionType.lesson);
}
