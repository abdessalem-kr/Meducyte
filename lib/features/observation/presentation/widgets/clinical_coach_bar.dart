import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:meducyte_app/features/observation/data/models/specialty_config.dart';
import 'package:meducyte_app/features/observation/data/providers/pathology_assistant_provider.dart';
import 'package:meducyte_app/features/observation/presentation/widgets/examination_helper_sheet.dart';
import 'package:meducyte_app/features/observation/presentation/widgets/pathology_detail_sheet.dart';

class ClinicalCoachBar extends ConsumerWidget {
  final SpecialtyFormConfig config;

  const ClinicalCoachBar({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final coachStep = ref.watch(currentCoachStepProvider(config));
    final activePathology = ref.watch(selectedPathologyProvider);
    final isPathologyMode = activePathology != null;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: InkWell(
          onTap: () {
            if (isPathologyMode) {
              PathologyDetailSheet.show(context, activePathology);
            } else {
              ExaminationHelperSheet.show(context, config);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isPathologyMode
                      ? Colors.purple.withOpacity(0.12)
                      : coachStep != null
                      ? theme.primaryColor.withOpacity(0.08)
                      : theme.dividerColor.withOpacity(0.05),
                  isPathologyMode
                      ? Colors.purple.withOpacity(0.06)
                      : coachStep != null
                      ? theme.primaryColor.withOpacity(0.04)
                      : theme.dividerColor.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPathologyMode
                    ? Colors.purple.withOpacity(0.2)
                    : coachStep != null
                    ? theme.primaryColor.withOpacity(0.1)
                    : theme.dividerColor.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        (isPathologyMode
                                ? Colors.purple
                                : (coachStep != null
                                      ? Colors.amber
                                      : Colors.blue))
                            .withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPathologyMode
                        ? Iconsax.radar
                        : (coachStep != null
                              ? Iconsax.teacher
                              : Iconsax.info_circle),
                    color: isPathologyMode
                        ? Colors.purple
                        : (coachStep != null ? Colors.amber : Colors.blue),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPathologyMode
                            ? "ASSISTANT DIAGNOSTIQUE: ${activePathology.name.toUpperCase()}"
                            : coachStep != null
                            ? "CONSEIL DU COACH"
                            : "COACH CLINIQUE",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isPathologyMode
                              ? Colors.purple
                              : coachStep != null
                              ? theme.primaryColor
                              : theme.hintColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPathologyMode
                            ? (activePathology.redFlags?.first ??
                                  "Consultez les signes cliniques clés et scores.")
                            : coachStep != null
                            ? (coachStep.clinicalPearl ??
                                  coachStep.steps.first.action)
                            : "Appuyez sur un champ pour recevoir des conseils de l'enseignant.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: (coachStep != null || isPathologyMode)
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontStyle:
                              (coachStep?.clinicalPearl != null ||
                                  isPathologyMode)
                              ? FontStyle.italic
                              : FontStyle.normal,
                          color: (coachStep != null || isPathologyMode)
                              ? null
                              : theme.hintColor.withOpacity(0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Iconsax.arrow_right_3,
                  color: theme.primaryColor.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
