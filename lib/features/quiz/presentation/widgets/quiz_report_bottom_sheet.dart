import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';
import 'package:meducyte_app/features/quiz/presentation/providers/quiz_report_provider.dart';

class QuizReportBottomSheet extends ConsumerWidget {
  final String questionId;

  const QuizReportBottomSheet({super.key, required this.questionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizReportProvider);
    final notifier = ref.read(quizReportProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;

    if (state.isSuccess) {
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
              l10n.reportError,
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
              isSelected: state.selectedReason == ReportReason.typo,
              onTap: () => notifier.setReason(ReportReason.typo),
              quizTheme: quizTheme,
            ),
            _ReasonTile(
              label: l10n.reasonWrongAnswer,
              isSelected: state.selectedReason == ReportReason.wrongAnswer,
              onTap: () => notifier.setReason(ReportReason.wrongAnswer),
              quizTheme: quizTheme,
            ),
            _ReasonTile(
              label: l10n.reasonUnclear,
              isSelected: state.selectedReason == ReportReason.unclear,
              onTap: () => notifier.setReason(ReportReason.unclear),
              quizTheme: quizTheme,
            ),
            _ReasonTile(
              label: l10n.reasonOther,
              isSelected: state.selectedReason == ReportReason.other,
              onTap: () => notifier.setReason(ReportReason.other),
              quizTheme: quizTheme,
            ),
            if (state.selectedReason == ReportReason.other) ...[
              const SizedBox(height: 16),
              TextField(
                onChanged: notifier.setCustomDescription,
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
              onPressed: state.selectedReason == null || state.isSending
                  ? null
                  : () => notifier.sendReport(questionId),
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
              child: state.isSending
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
