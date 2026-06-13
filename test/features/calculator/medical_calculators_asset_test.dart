import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meducyte_app/features/calculator/domain/models/medical_score_model.dart';

void main() {
  group('medical_calculators.json asset', () {
    late List<dynamic> data;

    setUpAll(() {
      final file = File('assets/data/medical_calculators.json');
      data = json.decode(file.readAsStringSync()) as List<dynamic>;
    });

    test('every entry parses into a MedicalScore without throwing', () {
      int id = 0;
      for (final entry in data.whereType<Map>()) {
        id++;
        final score =
            MedicalScore.fromJson(id, Map<String, dynamic>.from(entry));
        expect(score.name, isNotEmpty,
            reason: 'Entry #$id has an empty name');
      }
      expect(id, greaterThan(300));
    });

    test('interpretation ranges use known colors', () {
      const allowed = {'green', 'orange', 'yellow', 'red'};
      int id = 0;
      for (final entry in data.whereType<Map>()) {
        id++;
        final score =
            MedicalScore.fromJson(id, Map<String, dynamic>.from(entry));
        for (final r in score.interpretations) {
          expect(allowed.contains(r.color.toLowerCase()), isTrue,
              reason: '"${score.name}" uses unknown color "${r.color}"');
        }
      }
    });

    test('criteria options always carry a label', () {
      int id = 0;
      for (final entry in data.whereType<Map>()) {
        id++;
        final score =
            MedicalScore.fromJson(id, Map<String, dynamic>.from(entry));
        for (final c in score.criteria) {
          for (final o in c.options) {
            expect(o.label, isNotEmpty,
                reason: '"${score.name}" has an option without a label');
          }
        }
      }
    });
  });
}
