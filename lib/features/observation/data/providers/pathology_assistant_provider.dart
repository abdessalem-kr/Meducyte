import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meducyte_app/features/observation/data/models/specialty_config.dart';
import 'package:meducyte_app/features/observation/data/services/pathology_data_service.dart';

///Provider to track the manually selected pathology for diagnostic focus.
final selectedPathologyProvider = StateProvider<PathologyGuide?>((ref) => null);

///Provider to track the focused form field key for real-time coaching.
final focusedExamFieldProvider = StateProvider<String?>((ref) => null);

///Provider that asynchronously loads all available pathologies for a specialty.
final suggestedPathologiesProvider =
    FutureProvider.family<List<PathologyGuide>, SpecialtyFormConfig>((
      ref,
      config,
    ) async {
      return await PathologyDataService.loadPathologies(config.specialty);
    });

///Provider to determine the current guidance mode(General or Pathology Specific).
final currentCoachStepProvider =
    Provider.family<ExaminationStep?, SpecialtyFormConfig>((ref, config) {
      final focusedField = ref.watch(focusedExamFieldProvider);
      final activePathology = ref.watch(selectedPathologyProvider);

      if (focusedField == null) return null;

      //1.Check if the active pathology focus has specific guidance for this field
      if (activePathology != null && activePathology.focusedExam != null) {
        for (final step in activePathology.focusedExam!) {
          if (step.relatedFieldKeys?.contains(focusedField) ?? false) {
            return step;
          }
        }
      }

      //2.Fallback to general examination guide
      if (config.examinationGuide != null) {
        for (final step in config.examinationGuide!) {
          if (step.relatedFieldKeys?.contains(focusedField) ?? false) {
            return step;
          }
        }
      }

      return null;
    });
