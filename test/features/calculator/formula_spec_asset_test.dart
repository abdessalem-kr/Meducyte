import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meducyte_app/features/calculator/domain/formula_evaluator.dart';
import 'package:meducyte_app/features/calculator/domain/models/medical_score_model.dart';

/// Validates that every `formula_spec` in the bundled asset is internally
/// consistent and evaluable by the Dart [FormulaEvaluator] — so a calculator
/// authored in JSON can never ship with an expression the engine chokes on.
void main() {
  group('formula_spec entries in medical_calculators.json', () {
    late List<MedicalScore> formulaScores;

    setUpAll(() {
      final data = json.decode(
        File('assets/data/medical_calculators.json').readAsStringSync(),
      ) as List<dynamic>;
      int id = 0;
      formulaScores = data
          .whereType<Map>()
          .map((e) => MedicalScore.fromJson(++id, Map<String, dynamic>.from(e)))
          .where((s) => s.engine == CalculatorEngine.formula)
          .toList();
    });

    test('there is a healthy number of formula calculators', () {
      expect(formulaScores.length, greaterThanOrEqualTo(20));
    });

    test('every formula_spec evaluates with its default inputs', () {
      for (final score in formulaScores) {
        final spec = score.formulaSpec;
        expect(spec, isNotNull, reason: '"${score.name}" missing formula_spec');
        expect(spec!.expression, isNotEmpty,
            reason: '"${score.name}" has an empty expression');

        // Build the variable map exactly as the screen does.
        final vars = <String, double>{};
        for (final input in spec.inputs) {
          switch (input.type) {
            case FormulaInputType.number:
              vars[input.key] = input.defaultValue;
              break;
            case FormulaInputType.unit:
              final factor =
                  input.units.isNotEmpty ? input.units.first.factor : 1.0;
              vars[input.key] = input.defaultValue * factor;
              break;
            case FormulaInputType.toggle:
              vars[input.key] =
                  input.options.isNotEmpty ? input.options.first.value : 0;
              break;
          }
        }

        double result;
        try {
          result = FormulaEvaluator.eval(spec.expression, vars);
        } on FormulaException catch (e) {
          fail('"${score.name}" failed to evaluate: ${e.message}\n'
              'expression: ${spec.expression}\nvars: $vars');
        }
        expect(result.isFinite, isTrue,
            reason: '"${score.name}" produced a non-finite result');
      }
    });

    test('every input key is a valid identifier and referenced by the '
        'expression', () {
      final identifier = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');
      for (final score in formulaScores) {
        final spec = score.formulaSpec!;
        for (final input in spec.inputs) {
          expect(identifier.hasMatch(input.key), isTrue,
              reason: '"${score.name}" input key "${input.key}" is invalid');
          expect(spec.expression.contains(input.key), isTrue,
              reason:
                  '"${score.name}" expression never uses input "${input.key}"');
        }
      }
    });
  });
}
