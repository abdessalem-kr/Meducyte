import 'package:flutter_test/flutter_test.dart';
import 'package:meducyte_app/features/calculator/data/repositories/calculator_ai_repository.dart';
import 'package:meducyte_app/features/calculator/domain/models/medical_score_model.dart';

void main() {
  group('MedicalScore.fromJson', () {
    test('parses scoring_logic into flattened criteria', () {
      final score = MedicalScore.fromJson(1, {
        'name': 'Test Score',
        'url': 'http://example.com',
        'specialty': 'Cardiologie',
        'formula': 'Sum of all items',
        'scoring_logic': [
          {
            'title': 'Section A',
            'items': [
              {
                'question': 'Question 1',
                'options': [
                  {'label': 'Non', 'points': 0},
                  {'label': 'Oui', 'points': 2},
                ],
              },
              {
                'question': 'Question 2',
                'options': [
                  {'label': 'Absent', 'points': 0},
                  {'label': 'Présent', 'points': -1},
                ],
              },
            ],
          },
        ],
      });

      expect(score.hasCriteria, isTrue);
      expect(score.criteria.length, equals(2));
      expect(score.criteria[0].section, equals('Section A'));
      expect(score.criteria[0].options[1].points, equals(2.0));
      expect(score.maxScore, equals(2.0));
      expect(score.minScore, equals(-1.0));
    });

    test('parses string points and ignores unparseable values', () {
      final score = MedicalScore.fromJson(1, {
        'name': 'String Points',
        'scoring_logic': [
          {
            'title': 'S',
            'items': [
              {
                'question': 'Q',
                'options': [
                  {'label': 'A', 'points': '3'},
                  {'label': 'B', 'points': 'n/a'},
                ],
              },
            ],
          },
        ],
      });

      expect(score.criteria[0].options[0].points, equals(3.0));
      expect(score.criteria[0].options[1].points, equals(0.0));
    });

    test('parses Infinity bounds in interpretations', () {
      final score = MedicalScore.fromJson(1, {
        'name': 'Infinity Score',
        'interpretations': [
          {'min': '-Infinity', 'max': 0, 'label': 'Bas', 'color': 'green'},
          {'min': 1, 'max': 'Infinity', 'label': 'Haut', 'color': 'red'},
        ],
      });

      expect(score.interpretations[0].min, equals(double.negativeInfinity));
      expect(score.interpretations[1].max, equals(double.infinity));
    });

    test('handles missing fields with safe defaults', () {
      final score = MedicalScore.fromJson(1, {'name': 'Bare'});

      expect(score.hasCriteria, isFalse);
      expect(score.interpretations, isEmpty);
      expect(score.specialty, equals('Général'));
    });
  });

  group('CalculatorEngineSchema.fromJson', () {
    test('parses radio, checkbox and numeric criteria', () {
      final schema = CalculatorEngineSchema.fromJson({
        'criteria': [
          {
            'label': 'Pression artérielle',
            'type': 'radio',
            'options': [
              {'label': '< 90 mmHg', 'points': 3},
              {'label': '≥ 90 mmHg', 'points': 0},
            ],
          },
          {'label': 'Cancer actif', 'type': 'checkbox', 'points': 1},
          {'label': 'Poids', 'type': 'numeric', 'unit': 'kg', 'default_value': 70},
        ],
        'interpretations': [
          {'min': 0, 'max': 1, 'label': 'Risque faible', 'color': 'green'},
          {'min': 2, 'max': 4, 'label': 'Risque élevé', 'color': 'red'},
        ],
        'interpretation_text': 'À utiliser avec prudence.',
      });

      expect(schema.criteria.length, equals(3));
      expect(schema.criteria[0].options!.length, equals(2));
      expect(schema.criteria[0].options![0].points, equals(3.0));
      expect(schema.criteria[1].points, equals(1.0));
      expect(schema.criteria[2].unit, equals('kg'));
      expect(schema.criteria[2].defaultValue, equals(70.0));
      expect(schema.interpretations.length, equals(2));
      expect(schema.interpretationText, equals('À utiliser avec prudence.'));
    });

    test('parses integer points as doubles', () {
      final schema = CalculatorEngineSchema.fromJson({
        'criteria': [
          {
            'label': 'X',
            'type': 'radio',
            'options': [
              {'label': 'A', 'points': 2},
            ],
          },
        ],
        'interpretations': [],
      });

      expect(schema.criteria[0].options![0].points, equals(2.0));
    });
  });
}
