// ─── Domain Model for Medical Calculators ─────────────────────────────────────
// Source: assets/data/medical_calculators.json
// Schema: { name, url, specialty, formula, scoring_logic[]{title, items[]{question, options[]{label, points}}} }

/// How a calculator is rendered and computed.
///   - [points]  : interactive point-sum from `scoring_logic` (default).
///   - [formula] : data-driven numeric formula (see [FormulaSpec]).
///   - [info]    : no local engine; offers AI generation as a fallback.
enum CalculatorEngine { points, formula, info }

class MedicalScore {
  final int id;
  final String name;
  final String url;
  final String specialty;
  final String formula;
  final CalculatorEngine engine;
  final FormulaSpec? formulaSpec;
  final List<ScoreCriterion> criteria;
  final List<ScoreInterpretationRange> interpretations;

  const MedicalScore({
    required this.id,
    required this.name,
    required this.url,
    required this.specialty,
    required this.formula,
    this.engine = CalculatorEngine.info,
    this.formulaSpec,
    this.criteria = const [],
    this.interpretations = const [],
  });

  /// Parse from the medical_calculators.json entry.
  factory MedicalScore.fromJson(int id, Map<String, dynamic> json) {
    final scoringLogic = json['scoring_logic'] as List<dynamic>? ?? [];

    // Flatten scoring_logic sections → ScoreCriterion list
    final List<ScoreCriterion> parsedCriteria = [];
    for (final section in scoringLogic) {
      final sectionMap = section as Map<String, dynamic>;
      final sectionTitle = sectionMap['title'] as String? ?? '';
      final items = sectionMap['items'] as List<dynamic>? ?? [];
      for (final item in items) {
        final itemMap = item as Map<String, dynamic>;
        final question = itemMap['question'] as String? ?? '';
        final optionsJson = itemMap['options'] as List<dynamic>? ?? [];
        final options = optionsJson.map((o) {
          final oMap = o as Map<String, dynamic>;
          final rawPts = oMap['points'];
          final double pts;
          if (rawPts is num) {
            pts = rawPts.toDouble();
          } else if (rawPts is String) {
            pts = double.tryParse(rawPts) ?? 0.0;
          } else {
            pts = 0.0;
          }
          return ScoreOption(
            label: oMap['label'] as String? ?? '',
            points: pts,
          );
        }).toList();
        parsedCriteria.add(ScoreCriterion(
          section: sectionTitle,
          question: question,
          options: options,
        ));
      }
    }

    // Parse interpretations if present
    final interpList = json['interpretations'] as List<dynamic>? ?? [];
    final parsedInterpretations = interpList.map((r) {
      final rMap = r as Map<String, dynamic>;
      double parseVal(dynamic val) {
        if (val == null) return 0.0;
        if (val is num) return val.toDouble();
        if (val is String) {
          final clean = val.trim().toLowerCase();
          if (clean == 'infinity' || clean == 'inf' || clean == 'plus infini' || clean == '+infini' || clean == 'infini') {
            return double.infinity;
          }
          if (clean == '-infinity' || clean == '-inf' || clean == 'moins infini' || clean == '-infini') {
            return double.negativeInfinity;
          }
          return double.tryParse(clean) ?? 0.0;
        }
        return 0.0;
      }
      return ScoreInterpretationRange(
        min: parseVal(rMap['min']),
        max: parseVal(rMap['max']),
        label: rMap['label'] as String? ?? '',
        color: rMap['color'] as String? ?? 'green',
      );
    }).toList();

    // Parse the optional structured formula spec.
    final formulaSpec = json['formula_spec'] is Map<String, dynamic>
        ? FormulaSpec.fromJson(json['formula_spec'] as Map<String, dynamic>)
        : null;

    // Resolve the rendering engine. An explicit `engine` field wins; otherwise
    // we infer it from the data so legacy entries keep working.
    final engine = _parseEngine(
      json['engine'] as String?,
      hasSpec: formulaSpec != null,
      hasCriteria: parsedCriteria.isNotEmpty,
    );

    return MedicalScore(
      id: id,
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
      specialty: json['specialty'] as String? ?? 'Général',
      formula: json['formula'] as String? ?? '',
      engine: engine,
      formulaSpec: formulaSpec,
      criteria: parsedCriteria,
      interpretations: parsedInterpretations,
    );
  }

  static CalculatorEngine _parseEngine(
    String? raw, {
    required bool hasSpec,
    required bool hasCriteria,
  }) {
    switch (raw?.trim().toLowerCase()) {
      case 'formula':
        return CalculatorEngine.formula;
      case 'points':
        return CalculatorEngine.points;
      case 'info':
        return CalculatorEngine.info;
    }
    // No explicit engine → infer from the data.
    if (hasSpec) return CalculatorEngine.formula;
    if (hasCriteria) return CalculatorEngine.points;
    return CalculatorEngine.info;
  }

  /// Whether this calculator has interactive point-based criteria.
  bool get hasCriteria => criteria.isNotEmpty;

  /// Whether this calculator uses a formula (not a simple sum).
  bool get hasFormula =>
      formula.isNotEmpty &&
      formula != 'Sum of all items' &&
      hasCriteria == false;

  /// Total max score across all criteria.
  double get maxScore => criteria.fold(
      0.0, (sum, c) => sum + (c.maxPoints > 0 ? c.maxPoints : 0));

  /// Total min score (handles negative-point calculators).
  double get minScore =>
      criteria.fold(0.0, (sum, c) => sum + (c.minPoints < 0 ? c.minPoints : 0));
}

// ─── ScoreCriterion ───────────────────────────────────────────────────────────

class ScoreCriterion {
  final String section;
  final String question;
  final List<ScoreOption> options;

  const ScoreCriterion({
    required this.section,
    required this.question,
    required this.options,
  });

  /// Max points from this criterion's options.
  double get maxPoints => options.isEmpty
      ? 0
      : options.map((o) => o.points).reduce((a, b) => a > b ? a : b);

  /// Min points (for negative-scoring criteria).
  double get minPoints => options.isEmpty
      ? 0
      : options.map((o) => o.points).reduce((a, b) => a < b ? a : b);
}

// ─── ScoreOption ──────────────────────────────────────────────────────────────

class ScoreOption {
  final String label;
  final double points;

  const ScoreOption({required this.label, required this.points});
}

// ─── ScoreInterpretationRange ─────────────────────────────────────────────────

class ScoreInterpretationRange {
  final double min;
  final double max;
  final String label;
  final String color; // 'green' | 'orange' | 'red'

  const ScoreInterpretationRange({
    required this.min,
    required this.max,
    required this.label,
    required this.color,
  });
}

// ─── FormulaSpec ──────────────────────────────────────────────────────────────
// Structured, data-driven definition of a numeric calculator. Lives under the
// `formula_spec` key of a medical_calculators.json entry.
//
// {
//   "engine": "formula",
//   "formula_spec": {
//     "expression": "((140 - age) * weight * K) / creat",
//     "result_unit": "ml/min",
//     "result_decimals": 1,
//     "inputs": [
//       {"key": "age",    "label": "Âge",    "unit": "ans", "default": 65},
//       {"key": "weight", "label": "Poids",  "unit": "kg",  "default": 70},
//       {"key": "creat",  "label": "Créatininémie", "default": 100,
//         "units": [
//           {"label": "µmol/l", "factor": 1},
//           {"label": "mg/dl",  "factor": 88.4}
//         ]},
//       {"key": "K", "label": "Sexe", "type": "toggle",
//         "options": [
//           {"label": "Homme", "value": 1.23},
//           {"label": "Femme", "value": 1.04}
//         ]}
//     ]
//   }
// }
//
// The `expression` is evaluated by FormulaEvaluator using each input `key` as a
// variable. Interpretation/coloring reuses the entry's `interpretations` ranges.

class FormulaSpec {
  /// Arithmetic expression referencing each input's `key` as a variable.
  final String expression;

  /// Unit appended to the displayed result (e.g. "ml/min").
  final String resultUnit;

  /// Number of decimals shown in the result (default 1).
  final int resultDecimals;

  final List<FormulaInput> inputs;

  const FormulaSpec({
    required this.expression,
    this.resultUnit = '',
    this.resultDecimals = 1,
    this.inputs = const [],
  });

  factory FormulaSpec.fromJson(Map<String, dynamic> json) {
    final inputsJson = json['inputs'] as List<dynamic>? ?? [];
    return FormulaSpec(
      expression: json['expression'] as String? ?? '',
      resultUnit: json['result_unit'] as String? ?? '',
      resultDecimals: (json['result_decimals'] as num?)?.toInt() ?? 1,
      inputs: inputsJson
          .whereType<Map>()
          .map((i) => FormulaInput.fromJson(Map<String, dynamic>.from(i)))
          .toList(),
    );
  }
}

enum FormulaInputType { number, unit, toggle }

class FormulaInput {
  /// Variable name used inside [FormulaSpec.expression].
  final String key;
  final String label;
  final FormulaInputType type;

  /// For [FormulaInputType.number] / [FormulaInputType.unit].
  final String unit; // static suffix label for plain number fields
  final double defaultValue;

  /// For [FormulaInputType.unit] — selectable units; the entered value is
  /// multiplied by the chosen unit's `factor` before evaluation.
  final List<FormulaUnit> units;

  /// For [FormulaInputType.toggle] — choices, each contributing a numeric
  /// `value` to the variable (e.g. a sex-dependent coefficient).
  final List<FormulaInputOption> options;

  const FormulaInput({
    required this.key,
    required this.label,
    required this.type,
    this.unit = '',
    this.defaultValue = 0,
    this.units = const [],
    this.options = const [],
  });

  factory FormulaInput.fromJson(Map<String, dynamic> json) {
    final unitsJson = json['units'] as List<dynamic>? ?? [];
    final optionsJson = json['options'] as List<dynamic>? ?? [];

    FormulaInputType resolveType() {
      switch ((json['type'] as String?)?.trim().toLowerCase()) {
        case 'toggle':
        case 'select':
          return FormulaInputType.toggle;
        case 'unit':
          return FormulaInputType.unit;
        case 'number':
          return FormulaInputType.number;
      }
      if (optionsJson.isNotEmpty) return FormulaInputType.toggle;
      if (unitsJson.isNotEmpty) return FormulaInputType.unit;
      return FormulaInputType.number;
    }

    double parseNum(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0;
      return 0;
    }

    return FormulaInput(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      type: resolveType(),
      unit: json['unit'] as String? ?? '',
      defaultValue: parseNum(json['default']),
      units: unitsJson
          .whereType<Map>()
          .map((u) => FormulaUnit(
                label: u['label'] as String? ?? '',
                factor: parseNum(u['factor']),
              ))
          .toList(),
      options: optionsJson
          .whereType<Map>()
          .map((o) => FormulaInputOption(
                label: o['label'] as String? ?? '',
                value: parseNum(o['value']),
              ))
          .toList(),
    );
  }
}

class FormulaUnit {
  final String label;
  final double factor;
  const FormulaUnit({required this.label, required this.factor});
}

class FormulaInputOption {
  final String label;
  final double value;
  const FormulaInputOption({required this.label, required this.value});
}
