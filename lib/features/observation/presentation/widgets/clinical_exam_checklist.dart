import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:meducyte_app/features/observation/data/models/specialty_config.dart';
import 'package:meducyte_app/features/observation/data/providers/observation_providers.dart';

class ClinicalExamChecklist extends ConsumerStatefulWidget {
  final SpecialtyFormConfig config;

  const ClinicalExamChecklist({super.key, required this.config});

  @override
  ConsumerState<ClinicalExamChecklist> createState() => _ClinicalExamChecklistState();
}

class _ClinicalExamChecklistState extends ConsumerState<ClinicalExamChecklist> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final guide = widget.config.examinationGuide;
    if (guide == null || guide.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final checklistState = ref.watch(examChecklistProvider);

    // Calculate progress
    int totalManeuvers = guide.fold(0, (sum, step) => sum + step.steps.length);
    int completedManeuvers = 0;
    for (final step in guide) {
      for (final subStep in step.steps) {
        final key = '${widget.config.specialty.name}_${step.title}_${subStep.action}';
        final state = checklistState[key];
        if (state == 'normal' || state == 'pathological') {
          completedManeuvers++;
        }
      }
    }
    final double progress = totalManeuvers > 0 ? completedManeuvers / totalManeuvers : 0.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.primaryColor.withOpacity(isLight ? 0.1 : 0.2),
          width: 1.5,
        ),
      ),
      color: theme.cardColor,
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Iconsax.task_square,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Check-list & Mancœuvres d'Examen",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Guide clinique de précision pour l'étudiant",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: progress == 1.0
                              ? Colors.green.withOpacity(0.15)
                              : theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "$completedManeuvers / $totalManeuvers",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: progress == 1.0 ? Colors.green : theme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _isExpanded ? Iconsax.arrow_up_11 : Iconsax.arrow_down_12,
                        size: 20,
                        color: theme.hintColor,
                      ),
                    ],
                  ),
                  if (totalManeuvers > 0) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: theme.dividerColor.withOpacity(0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress == 1.0
                              ? Colors.green
                              : theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (_isExpanded) ...[
            const Divider(height: 1),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: guide.length,
              itemBuilder: (context, stepIdx) {
                final step = guide[stepIdx];
                final isLast = stepIdx == guide.length - 1;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step Section Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: theme.dividerColor.withOpacity(0.03),
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 16,
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              step.title.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Sub-steps list
                    ...step.steps.map((subStep) {
                      final itemKey = '${widget.config.specialty.name}_${step.title}_${subStep.action}';
                      final currentStatus = checklistState[itemKey] ?? 'not_done';

                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Iconsax.info_circle,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        subStep.action,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (subStep.description != null && subStep.description!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          subStep.description!,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.hintColor,
                                          ),
                                        ),
                                      ],
                                      if (subStep.interpretation != null && subStep.interpretation!.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.amber.withOpacity(0.15),
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Iconsax.lamp_on,
                                                size: 14,
                                                color: Colors.amber,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  subStep.interpretation!,
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: Colors.amber[900],
                                                    fontSize: 11,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Status selector row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _buildStatusButton(
                                  context: context,
                                  label: "Non fait",
                                  icon: Iconsax.close_circle,
                                  isSelected: currentStatus == 'not_done',
                                  activeColor: theme.hintColor,
                                  onTap: () => _updateManeuverStatus(
                                    itemKey: itemKey,
                                    relatedKeys: step.relatedFieldKeys,
                                    status: 'not_done',
                                    actionName: subStep.action,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildStatusButton(
                                  context: context,
                                  label: "Normal",
                                  icon: Iconsax.tick_circle,
                                  isSelected: currentStatus == 'normal',
                                  activeColor: Colors.green,
                                  onTap: () => _updateManeuverStatus(
                                    itemKey: itemKey,
                                    relatedKeys: step.relatedFieldKeys,
                                    status: 'normal',
                                    actionName: subStep.action,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildStatusButton(
                                  context: context,
                                  label: "Pathologique",
                                  icon: Iconsax.warning_2,
                                  isSelected: currentStatus == 'pathological',
                                  activeColor: Colors.red,
                                  onTap: () => _updateManeuverStatus(
                                    itemKey: itemKey,
                                    relatedKeys: step.relatedFieldKeys,
                                    status: 'pathological',
                                    actionName: subStep.action,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    if (!isLast) const Divider(height: 1),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.12) : Colors.transparent,
          border: Border.all(
            color: isSelected ? activeColor.withOpacity(0.5) : theme.dividerColor.withOpacity(0.3),
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? activeColor : theme.hintColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : theme.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateManeuverStatus({
    required String itemKey,
    required List<String>? relatedKeys,
    required String status,
    required String actionName,
  }) {
    // 1. Update the checklist provider state
    final currChecklist = ref.read(observationReportProvider).examChecklist;
    ref.read(observationReportProvider.notifier).updateExamChecklist({
      ...currChecklist,
      itemKey: status,
    });

    if (relatedKeys == null || relatedKeys.isEmpty) return;

    final currExamData = ref.read(observationReportProvider).physicalExam;
    final updatedExamData = Map<String, String>.from(currExamData);

    for (final fieldKey in relatedKeys) {
      // Find normal findings text
      String normalFindings = "Normal";
      final fieldConfig = widget.config.examFields.firstWhere(
        (f) => f.key == fieldKey,
        orElse: () => SpecialtyConfigs.all
            .expand((c) => c.examFields)
            .firstWhere(
              (f) => f.key == fieldKey,
              orElse: () => ExamFieldConfig(key: fieldKey, label: fieldKey, normalText: "Normal"),
            ),
      );
      normalFindings = fieldConfig.normalText;

      final currentVal = currExamData[fieldKey] ?? '';

      if (status == 'normal') {
        // Populating "Normal" findings
        final normalVal = _formatToQuillJson(normalFindings);
        updatedExamData[fieldKey] = normalVal;
      } else if (status == 'pathological') {
        // Populating pathological template
        final pathVal = _formatToQuillJson("[$actionName]: (décrire l'anomalie ici)");
        updatedExamData[fieldKey] = pathVal;

        // Reactive focus and scroll
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(focusRequestProvider.notifier).state = fieldKey;
        });
      } else if (status == 'not_done') {
        // Clearing field if it still has the autofilled value from this maneuver to keep report clean
        final currentNormalVal = _formatToQuillJson(normalFindings);
        final currentPathVal = _formatToQuillJson("[$actionName]: (décrire l'anomalie ici)");

        if (currentVal == currentNormalVal || currentVal == currentPathVal) {
          updatedExamData[fieldKey] = '';
        }
      }
    }

    ref.read(observationReportProvider.notifier).updatePhysicalExam(updatedExamData);
  }

  String _formatToQuillJson(String text) {
    if (text.startsWith('[{')) return text;
    return jsonEncode([
      {"insert": "$text\n"},
    ]);
  }
}
