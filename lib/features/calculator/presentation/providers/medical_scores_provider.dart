import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/calculator/domain/models/medical_score_model.dart';
import 'package:meducyte_app/features/calculator/data/repositories/calculator_ai_repository.dart';

final calculatorAiRepositoryProvider = Provider<CalculatorAiRepository>((ref) {
  return CalculatorAiRepository(Dio());
});

/// Session cache of AI-generated calculator schemas, keyed by calculator name,
/// so a schema is only generated once per app session.
final generatedSchemaCacheProvider =
    Provider<Map<String, CalculatorEngineSchema>>((ref) => {});

// ─── Providers ────────────────────────────────────────────────────────────────

final medicalScoresProvider = FutureProvider<List<MedicalScore>>((ref) async {
  final String response =
      await rootBundle.loadString('assets/data/medical_calculators.json');
  final List<dynamic> data = json.decode(response);

  int seqId = 0;
  return data
      .whereType<Map>()
      .map((j) {
        seqId++;
        return MedicalScore.fromJson(seqId, Map<String, dynamic>.from(j));
      })
      .where((s) => s.name.isNotEmpty)
      .toList();
});

final scoreSearchQueryProvider = StateProvider<String>((ref) => '');
final scoreSpecialtyFilterProvider = StateProvider<String>((ref) => 'Tous');

final filteredScoresProvider =
    Provider<AsyncValue<List<MedicalScore>>>((ref) {
  final scoresAsync = ref.watch(medicalScoresProvider);
  final query = ref.watch(scoreSearchQueryProvider).toLowerCase().trim();
  final specialty = ref.watch(scoreSpecialtyFilterProvider);

  return scoresAsync.whenData((scores) {
    return scores.where((s) {
      final matchQuery = query.isEmpty ||
          s.name.toLowerCase().contains(query) ||
          s.specialty.toLowerCase().contains(query);
      final matchSpecialty =
          specialty == 'Tous' || s.specialty == specialty;
      return matchQuery && matchSpecialty;
    }).toList();
  });
});

final scoreSpecialtiesProvider =
    Provider<AsyncValue<List<String>>>((ref) {
  final scoresAsync = ref.watch(medicalScoresProvider);
  return scoresAsync.whenData((scores) {
    final specialties = scores.map((s) => s.specialty).toSet().toList()
      ..sort();
    return ['Tous', ...specialties];
  });
});
