import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/calculator/domain/models/calculator_models.dart';
import 'package:meducyte_app/features/calculator/data/repositories/calculator_ai_repository.dart';

final medicalCalculatorsProvider = FutureProvider<List<CalculatorCategory>>((
  ref,
) async {
  final String response = await rootBundle.loadString(
    'assets/data/medical_calculators.json',
  );
  final List<dynamic> data = json.decode(response);
  return data.map((json) => CalculatorCategory.fromJson(json)).toList();
});

final calculatorSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredCalculatorsProvider =
    Provider<AsyncValue<List<CalculatorCategory>>>((ref) {
      final calculatorsAsync = ref.watch(medicalCalculatorsProvider);
      final searchQuery = ref
          .watch(calculatorSearchQueryProvider)
          .toLowerCase();

      if (searchQuery.isEmpty) return calculatorsAsync;

      return calculatorsAsync.whenData((categories) {
        return categories
            .map((category) {
              final filteredList = category.calculators.where((calc) {
                return calc.name.toLowerCase().contains(searchQuery) ||
                    calc.descriptionEn.toLowerCase().contains(searchQuery) ||
                    calc.descriptionFr.toLowerCase().contains(searchQuery);
              }).toList();

              if (filteredList.isEmpty) return null;

              return CalculatorCategory(
                id: category.id,
                name: category.name,
                calculators: filteredList,
              );
            })
            .whereType<CalculatorCategory>()
            .toList();
      });
    });

final calculatorAiRepositoryProvider = Provider<CalculatorAiRepository>((ref) {
  return CalculatorAiRepository(Dio());
});
