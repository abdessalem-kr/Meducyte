import 'package:flutter_test/flutter_test.dart';
import 'package:meducyte_app/features/calculator/domain/formula_evaluator.dart';

void main() {
  double ev(String expr, [Map<String, double> vars = const {}]) =>
      FormulaEvaluator.eval(expr, vars);

  group('FormulaEvaluator arithmetic', () {
    test('basic precedence and associativity', () {
      expect(ev('1 + 2 * 3'), equals(7));
      expect(ev('(1 + 2) * 3'), equals(9));
      expect(ev('10 - 2 - 3'), equals(5)); // left-associative
      expect(ev('2 ^ 3 ^ 2'), equals(512)); // right-associative: 2^9
    });

    test('unary minus and plus', () {
      expect(ev('-5 + 3'), equals(-2));
      expect(ev('3 * -2'), equals(-6));
      expect(ev('2 ^ -1'), equals(0.5));
    });

    test('decimals and modulo', () {
      expect(ev('.5 + 0.25'), equals(0.75));
      expect(ev('7 % 3'), equals(1));
    });

    test('functions', () {
      expect(ev('sqrt(16)'), equals(4));
      expect(ev('pow(2, 10)'), equals(1024));
      expect(ev('min(3, 8)'), equals(3));
      expect(ev('max(3, 8)'), equals(8));
      expect(ev('abs(-4)'), equals(4));
      expect(ev('round(2.6)'), equals(3));
      expect(ev('log10(1000)'), closeTo(3, 1e-9));
    });
  });

  group('FormulaEvaluator variables', () {
    test('resolves variables from the map', () {
      expect(ev('a + b * c', {'a': 1, 'b': 2, 'c': 3}), equals(7));
    });

    test('Cockcroft clearance formula', () {
      final result = ev('((140 - age) * weight * K) / creat',
          {'age': 65, 'weight': 70, 'K': 1.23, 'creat': 100});
      expect(result, closeTo(64.575, 1e-3));
    });

    test('QTc Bazett formula', () {
      final result = ev('qt / sqrt(60 / fc)', {'qt': 400, 'fc': 75});
      expect(result, closeTo(447.21, 1e-2));
    });

    test('MDRD with negative exponents', () {
      final result = ev(
          '186 * (creat ^ -1.154) * (age ^ -0.203) * sexF * ethn',
          {'creat': 1, 'age': 60, 'sexF': 1, 'ethn': 1});
      expect(result, closeTo(81.01, 0.1));
    });
  });

  group('FormulaEvaluator errors', () {
    test('unknown variable throws FormulaException', () {
      expect(() => ev('x + 1'), throwsA(isA<FormulaException>()));
    });

    test('division by zero throws', () {
      expect(() => ev('1 / 0'), throwsA(isA<FormulaException>()));
    });

    test('malformed input throws', () {
      expect(() => ev('1 +'), throwsA(isA<FormulaException>()));
      expect(() => ev('(1 + 2'), throwsA(isA<FormulaException>()));
      expect(() => ev('1 2'), throwsA(isA<FormulaException>()));
    });

    test('unknown function throws', () {
      expect(() => ev('frobnicate(2)'), throwsA(isA<FormulaException>()));
    });
  });
}
