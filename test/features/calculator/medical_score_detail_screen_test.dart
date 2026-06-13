import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meducyte_app/features/calculator/domain/models/medical_score_model.dart';
import 'package:meducyte_app/features/calculator/presentation/screens/medical_score_detail_screen.dart';

Widget _wrap(MedicalScore score) => ProviderScope(
      child: MaterialApp(
        home: MedicalScoreDetailScreen(score: score),
      ),
    );

void main() {
  group('MedicalScoreDetailScreen — formula engine', () {
    final cockcroft = MedicalScore.fromJson(1, {
      'name': 'Clearance (Cockcroft)',
      'specialty': 'Néphrologie',
      'engine': 'formula',
      'formula_spec': {
        'expression': '((140 - age) * weight * K) / creat',
        'result_unit': 'ml/min',
        'result_decimals': 1,
        'inputs': [
          {'key': 'age', 'label': 'Âge', 'unit': 'ans', 'default': 65},
          {'key': 'weight', 'label': 'Poids', 'unit': 'kg', 'default': 70},
          {
            'key': 'creat',
            'label': 'Créatininémie',
            'default': 100,
            'units': [
              {'label': 'µmol/l', 'factor': 1},
              {'label': 'mg/dl', 'factor': 88.4},
            ],
          },
          {
            'key': 'K',
            'label': 'Sexe',
            'type': 'toggle',
            'options': [
              {'label': 'Homme', 'value': 1.23},
              {'label': 'Femme', 'value': 1.04},
            ],
          },
        ],
      },
      'interpretations': [
        {'min': 0, 'max': 60, 'label': 'Insuffisance rénale', 'color': 'red'},
        {'min': 60, 'max': 200, 'label': 'Fonction normale', 'color': 'green'},
      ],
    });

    testWidgets('renders the live result from default inputs', (tester) async {
      await tester.pumpWidget(_wrap(cockcroft));
      await tester.pump();

      expect(find.text('Résultat du Calcul'), findsOneWidget);
      // ((140-65)*70*1.23)/100 = 64.6 ml/min
      expect(find.text('64.6 ml/min'), findsOneWidget);
      expect(find.text('Fonction normale'), findsOneWidget);
      // Inputs are rendered.
      expect(find.text('Âge'), findsOneWidget);
      expect(find.text('Sexe'), findsOneWidget);
    });

    testWidgets('recomputes when an input changes', (tester) async {
      await tester.pumpWidget(_wrap(cockcroft));
      await tester.pump();

      final ageField = find.byType(TextField).first;
      await tester.enterText(ageField, '40');
      await tester.pump();

      // ((140-40)*70*1.23)/100 = 86.1 ml/min
      expect(find.text('86.1 ml/min'), findsOneWidget);
    });

    testWidgets('toggling sex changes the result', (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(cockcroft));
      await tester.pump();

      await tester.tap(find.text('Femme'));
      await tester.pump();

      // ((140-65)*70*1.04)/100 = 54.6 → red band
      expect(find.text('54.6 ml/min'), findsOneWidget);
      expect(find.text('Insuffisance rénale'), findsOneWidget);
    });
  });

  group('MedicalScoreDetailScreen — points engine', () {
    final score = MedicalScore.fromJson(2, {
      'name': 'Test Score',
      'specialty': 'Cardiologie',
      'scoring_logic': [
        {
          'title': 'Section A',
          'items': [
            {
              'question': 'Critère 1',
              'options': [
                {'label': 'Non', 'points': 0},
                {'label': 'Oui', 'points': 2},
              ],
            },
          ],
        },
      ],
      'interpretations': [
        {'min': 0, 'max': 1, 'label': 'Bas', 'color': 'green'},
        {'min': 2, 'max': 10, 'label': 'Élevé', 'color': 'red'},
      ],
    });

    testWidgets('renders criteria and updates the total on selection',
        (tester) async {
      await tester.pumpWidget(_wrap(score));
      await tester.pump();

      expect(find.text('Score Total'), findsOneWidget);
      expect(find.text('CRITÈRES DU SCORE'), findsOneWidget);
      expect(find.text('Oui'), findsOneWidget);

      await tester.tap(find.text('Oui'));
      await tester.pumpAndSettle();

      // After selecting the +2 option the interpretation flips to "Élevé".
      expect(find.text('Élevé'), findsOneWidget);
    });
  });

  group('MedicalScoreDetailScreen — info engine', () {
    final score = MedicalScore.fromJson(3, {
      'name': 'Opaque Calculator',
      'specialty': 'Divers',
      'url': 'http://example.com/x.html',
    });

    testWidgets('offers AI generation when there is no local engine',
        (tester) async {
      await tester.pumpWidget(_wrap(score));
      await tester.pump();

      expect(find.text('Version interactive non disponible'), findsOneWidget);
      expect(find.text("Générer avec l'IA"), findsOneWidget);
    });
  });
}
