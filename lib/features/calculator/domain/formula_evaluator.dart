import 'dart:math' as math;

/// A tiny, dependency-free arithmetic expression evaluator used by the
/// data-driven formula calculators.
///
/// Supported syntax:
///   - numbers:        `1`, `2.5`, `.5`
///   - variables:      any identifier resolved from the [variables] map
///   - operators:      `+  -  *  /  %  ^`  (with unary `-` / `+`)
///   - parentheses:    `( ... )`
///   - functions:      sqrt, cbrt, abs, exp, ln, log10, log (base-10),
///                     pow(x, y), min(a, b), max(a, b), round(x), floor(x),
///                     ceil(x)
///
/// Example:
///   FormulaEvaluator.eval('((140 - age) * weight * K) / creat',
///       {'age': 65, 'weight': 70, 'K': 1.23, 'creat': 100});
///
/// Throws [FormulaException] on malformed input or unknown identifiers so the
/// UI can show a clean error instead of crashing.
class FormulaEvaluator {
  final String _src;
  final Map<String, double> _vars;
  int _pos = 0;

  FormulaEvaluator._(this._src, this._vars);

  static double eval(String expression, Map<String, double> variables) {
    final evaluator = FormulaEvaluator._(expression, variables);
    final result = evaluator._parseExpression(0);
    evaluator._skipWhitespace();
    if (evaluator._pos != evaluator._src.length) {
      throw FormulaException(
          'Unexpected character at position ${evaluator._pos}');
    }
    return result;
  }

  // ─── Precedence climbing ──────────────────────────────────────────────────

  static const Map<String, int> _binaryPrecedence = {
    '+': 1,
    '-': 1,
    '*': 2,
    '/': 2,
    '%': 2,
    '^': 3,
  };

  double _parseExpression(int minPrecedence) {
    double left = _parseUnary();

    while (true) {
      _skipWhitespace();
      final op = _peekOperator();
      if (op == null) break;
      final precedence = _binaryPrecedence[op]!;
      if (precedence < minPrecedence) break;
      _pos += op.length;

      // `^` is right-associative, everything else is left-associative.
      final nextMin = op == '^' ? precedence : precedence + 1;
      final right = _parseExpression(nextMin);
      left = _applyBinary(op, left, right);
    }
    return left;
  }

  double _parseUnary() {
    _skipWhitespace();
    if (_pos < _src.length) {
      final ch = _src[_pos];
      if (ch == '-') {
        _pos++;
        return -_parseUnary();
      }
      if (ch == '+') {
        _pos++;
        return _parseUnary();
      }
    }
    return _parsePrimary();
  }

  double _parsePrimary() {
    _skipWhitespace();
    if (_pos >= _src.length) {
      throw FormulaException('Unexpected end of expression');
    }

    final ch = _src[_pos];

    if (ch == '(') {
      _pos++;
      final value = _parseExpression(0);
      _expect(')');
      return value;
    }

    if (_isDigit(ch) || ch == '.') {
      return _parseNumber();
    }

    if (_isIdentStart(ch)) {
      return _parseIdentifierOrCall();
    }

    throw FormulaException('Unexpected character "$ch" at position $_pos');
  }

  double _parseNumber() {
    final start = _pos;
    while (_pos < _src.length && (_isDigit(_src[_pos]) || _src[_pos] == '.')) {
      _pos++;
    }
    final text = _src.substring(start, _pos);
    final value = double.tryParse(text);
    if (value == null) {
      throw FormulaException('Invalid number "$text"');
    }
    return value;
  }

  double _parseIdentifierOrCall() {
    final start = _pos;
    while (_pos < _src.length && _isIdentPart(_src[_pos])) {
      _pos++;
    }
    final name = _src.substring(start, _pos);

    _skipWhitespace();
    if (_pos < _src.length && _src[_pos] == '(') {
      _pos++;
      final args = <double>[];
      _skipWhitespace();
      if (_pos < _src.length && _src[_pos] != ')') {
        args.add(_parseExpression(0));
        _skipWhitespace();
        while (_pos < _src.length && _src[_pos] == ',') {
          _pos++;
          args.add(_parseExpression(0));
          _skipWhitespace();
        }
      }
      _expect(')');
      return _applyFunction(name, args);
    }

    // Plain variable.
    final value = _vars[name];
    if (value == null) {
      throw FormulaException('Unknown variable "$name"');
    }
    return value;
  }

  // ─── Operators & functions ────────────────────────────────────────────────

  double _applyBinary(String op, double a, double b) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '/':
        if (b == 0) throw FormulaException('Division by zero');
        return a / b;
      case '%':
        return a % b;
      case '^':
        return math.pow(a, b).toDouble();
      default:
        throw FormulaException('Unknown operator "$op"');
    }
  }

  double _applyFunction(String name, List<double> args) {
    double one() {
      if (args.length != 1) {
        throw FormulaException('$name expects 1 argument');
      }
      return args[0];
    }

    switch (name) {
      case 'sqrt':
        return math.sqrt(one());
      case 'cbrt':
        final x = one();
        return x < 0 ? -math.pow(-x, 1 / 3).toDouble() : math.pow(x, 1 / 3).toDouble();
      case 'abs':
        return one().abs();
      case 'exp':
        return math.exp(one());
      case 'ln':
        return math.log(one());
      case 'log10':
      case 'log':
        return math.log(one()) / math.ln10;
      case 'round':
        return one().roundToDouble();
      case 'floor':
        return one().floorToDouble();
      case 'ceil':
        return one().ceilToDouble();
      case 'pow':
        if (args.length != 2) throw FormulaException('pow expects 2 arguments');
        return math.pow(args[0], args[1]).toDouble();
      case 'min':
        if (args.length != 2) throw FormulaException('min expects 2 arguments');
        return math.min(args[0], args[1]);
      case 'max':
        if (args.length != 2) throw FormulaException('max expects 2 arguments');
        return math.max(args[0], args[1]);
      default:
        throw FormulaException('Unknown function "$name"');
    }
  }

  // ─── Lexer helpers ────────────────────────────────────────────────────────

  String? _peekOperator() {
    if (_pos >= _src.length) return null;
    final ch = _src[_pos];
    if (_binaryPrecedence.containsKey(ch)) return ch;
    return null;
  }

  void _expect(String ch) {
    _skipWhitespace();
    if (_pos >= _src.length || _src[_pos] != ch) {
      throw FormulaException('Expected "$ch" at position $_pos');
    }
    _pos++;
  }

  void _skipWhitespace() {
    while (_pos < _src.length && _src[_pos].trim().isEmpty) {
      _pos++;
    }
  }

  bool _isDigit(String ch) => ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;

  bool _isIdentStart(String ch) {
    final c = ch.codeUnitAt(0);
    return (c >= 65 && c <= 90) || (c >= 97 && c <= 122) || ch == '_';
  }

  bool _isIdentPart(String ch) => _isIdentStart(ch) || _isDigit(ch);
}

class FormulaException implements Exception {
  final String message;
  FormulaException(this.message);
  @override
  String toString() => 'FormulaException: $message';
}
