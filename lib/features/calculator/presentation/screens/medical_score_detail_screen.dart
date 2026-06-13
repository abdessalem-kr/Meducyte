import 'package:flutter/services.dart';
import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/calculator/data/repositories/calculator_ai_repository.dart';
import 'package:meducyte_app/features/calculator/domain/formula_evaluator.dart';
import 'package:meducyte_app/features/calculator/domain/models/medical_score_model.dart';
import 'package:meducyte_app/features/calculator/presentation/providers/medical_scores_provider.dart';

class MedicalScoreDetailScreen extends ConsumerStatefulWidget {
  final MedicalScore score;

  const MedicalScoreDetailScreen({super.key, required this.score});

  @override
  ConsumerState<MedicalScoreDetailScreen> createState() => _MedicalScoreDetailScreenState();
}

class _MedicalScoreDetailScreenState extends ConsumerState<MedicalScoreDetailScreen>
    with SingleTickerProviderStateMixin {
  // For point-based scores
  late List<int> _selectedOptions;
  late List<ScoreCriterion> _criteria;
  late List<ScoreInterpretationRange> _interpretations;
  late AnimationController _scoreAnimController;
  double _displayedScore = 0;

  // AI Clinical Insight
  String? _aiInsight;
  bool _isInsightLoading = false;

  // AI-generated schema (fallback for calculators without local criteria)
  bool _isSchemaLoading = false;
  String? _schemaError;
  bool _aiGenerated = false;
  String? _aiInterpretationText;

  // For formula-based calculators (data-driven from FormulaSpec)
  FormulaSpec? _spec;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, int> _selectedUnitIndex = {}; // key → index into input.units
  final Map<String, int> _selectedToggleIndex = {}; // key → index into options
  String _formulaResultString = '';
  String _formulaResultColor = 'green'; // green, orange, red
  String _formulaInterpretation = '';
  String? _formulaError;

  @override
  void initState() {
    super.initState();
    // A formula-engine entry ignores any stray `scoring_logic`; the formula
    // spec is the single source of truth for how it computes.
    _criteria = widget.score.engine == CalculatorEngine.formula
        ? const []
        : widget.score.criteria;
    _selectedOptions = List.filled(_criteria.length, -1);
    _interpretations = widget.score.interpretations;
    _scoreAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _initFormula();

    // Restore a previously AI-generated schema from the session cache.
    if (_criteria.isEmpty && _spec == null) {
      final cached =
          ref.read(generatedSchemaCacheProvider)[widget.score.name];
      if (cached != null) {
        _applyGeneratedSchema(cached);
      }
    }
  }

  /// Convert an AI-generated schema into the interactive criteria model.
  /// Returns false if the schema contains no usable interactive criteria.
  bool _applyGeneratedSchema(CalculatorEngineSchema schema) {
    final criteria = <ScoreCriterion>[];
    for (final c in schema.criteria) {
      if (c.type == 'radio' && (c.options?.isNotEmpty ?? false)) {
        criteria.add(ScoreCriterion(
          section: c.label,
          question: '',
          options: c.options!
              .map((o) => ScoreOption(label: o.label, points: o.points))
              .toList(),
        ));
      } else if (c.type == 'checkbox') {
        criteria.add(ScoreCriterion(
          section: c.label,
          question: '',
          options: [
            const ScoreOption(label: 'Non', points: 0),
            ScoreOption(label: 'Oui', points: c.points ?? 1),
          ],
        ));
      }
      // 'numeric' criteria are skipped: the sum-based engine cannot evaluate them.
    }
    if (criteria.isEmpty) return false;

    _criteria = criteria;
    _selectedOptions = List.filled(criteria.length, -1);
    if (schema.interpretations.isNotEmpty) {
      _interpretations = schema.interpretations
          .map((i) => ScoreInterpretationRange(
                min: i.min,
                max: i.max,
                label: i.label,
                color: i.color ?? 'green',
              ))
          .toList();
    }
    _aiInterpretationText = schema.interpretationText;
    _aiGenerated = true;
    return true;
  }

  Future<void> _generateInteractiveSchema() async {
    setState(() {
      _isSchemaLoading = true;
      _schemaError = null;
    });
    try {
      final aiRepo = ref.read(calculatorAiRepositoryProvider);
      final schema = await aiRepo.generateSchemaForCalculator(
        calculatorName: widget.score.name,
        url: widget.score.url,
      );
      if (!mounted) return;
      setState(() {
        _isSchemaLoading = false;
        if (_applyGeneratedSchema(schema)) {
          ref.read(generatedSchemaCacheProvider)[widget.score.name] = schema;
        } else {
          _schemaError =
              "L'IA n'a pas pu produire de version interactive pour ce calculateur.";
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSchemaLoading = false;
        _schemaError = "Génération impossible. Vérifiez votre connexion et réessayez.";
      });
    }
  }

  @override
  void dispose() {
    _scoreAnimController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initFormula() {
    if (widget.score.engine != CalculatorEngine.formula) return;
    final spec = widget.score.formulaSpec;
    if (spec == null || spec.expression.isEmpty) return;

    _spec = spec;
    for (final input in spec.inputs) {
      switch (input.type) {
        case FormulaInputType.number:
        case FormulaInputType.unit:
          _controllers[input.key] =
              TextEditingController(text: _trimNum(input.defaultValue));
          if (input.type == FormulaInputType.unit && input.units.isNotEmpty) {
            _selectedUnitIndex[input.key] = 0;
          }
          break;
        case FormulaInputType.toggle:
          _selectedToggleIndex[input.key] = 0;
          break;
      }
    }
    _calculateFormula();
  }

  String _trimNum(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  /// Evaluate the data-driven [FormulaSpec] expression against current inputs.
  /// Result color and interpretation come from the entry's interpretation
  /// ranges, so everything is driven by the JSON.
  void _calculateFormula() {
    final spec = _spec;
    if (spec == null) return;

    final vars = <String, double>{};
    for (final input in spec.inputs) {
      switch (input.type) {
        case FormulaInputType.number:
          vars[input.key] =
              double.tryParse(_controllers[input.key]?.text.trim() ?? '') ?? 0;
          break;
        case FormulaInputType.unit:
          final raw =
              double.tryParse(_controllers[input.key]?.text.trim() ?? '') ?? 0;
          final idx = _selectedUnitIndex[input.key] ?? 0;
          final factor = (idx >= 0 && idx < input.units.length)
              ? input.units[idx].factor
              : 1.0;
          vars[input.key] = raw * factor;
          break;
        case FormulaInputType.toggle:
          final idx = _selectedToggleIndex[input.key] ?? 0;
          vars[input.key] = (idx >= 0 && idx < input.options.length)
              ? input.options[idx].value
              : 0;
          break;
      }
    }

    double? value;
    String error = '';
    try {
      value = FormulaEvaluator.eval(spec.expression, vars);
    } on FormulaException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Calcul impossible';
    }

    String resString = '';
    String resColor = 'green';
    String interp = '';
    if (value != null && value.isFinite) {
      final unitSuffix = spec.resultUnit.isNotEmpty ? ' ${spec.resultUnit}' : '';
      resString = '${value.toStringAsFixed(spec.resultDecimals)}$unitSuffix';
      final range = _getCurrentInterpretationRange(value);
      if (range != null) {
        resColor = range.color;
        interp = range.label;
      }
    } else if (error.isEmpty) {
      error = 'Calcul impossible';
    }

    setState(() {
      _formulaResultString = resString;
      _formulaResultColor = resColor;
      _formulaInterpretation = interp;
      _formulaError = error.isEmpty ? null : error;
    });
  }

  ScoreInterpretationRange? _getCurrentInterpretationRange(double score) {
    final ranges = _interpretations;
    if (ranges.isEmpty) return null;
    for (final r in ranges) {
      if (score >= r.min && score <= r.max) {
        return r;
      }
    }
    return null;
  }

  Color _colorFromRangeString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return const Color(0xFFEF4444);
      case 'orange':
      case 'yellow':
        return const Color(0xFFF59E0B);
      case 'green':
      default:
        return const Color(0xFF10B981);
    }
  }

  double get _totalScore {
    double total = 0;
    for (int i = 0; i < _criteria.length; i++) {
      final selected = _selectedOptions[i];
      if (selected >= 0 && selected < _criteria[i].options.length) {
        total += _criteria[i].options[selected].points;
      }
    }
    return total;
  }

  Color _scoreColor(double score) {
    final range = _getCurrentInterpretationRange(score);
    if (range != null) {
      return _colorFromRangeString(range.color);
    }
    if (score < 0) return const Color(0xFF6366F1);
    if (score <= 2) return const Color(0xFF10B981);
    if (score <= 5) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Color _resColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'orange':
      case 'yellow':
        return const Color(0xFFF59E0B);
      case 'red':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasCriteria = _criteria.isNotEmpty;
    final isFormula = _spec != null;

    // Choose theme accent color
    Color themeAccent = const Color(0xFF6366F1);
    if (hasCriteria) {
      themeAccent = _scoreColor(_totalScore);
    } else if (isFormula) {
      themeAccent = _resColor(_formulaResultColor);
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            floating: false,
            elevation: 0,
            backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
            leading: IconButton(
              icon: Icon(Iconsax.arrow_left_2, color: isDark ? Colors.white : Colors.black87),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [themeAccent, themeAccent.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Icon(Iconsax.calculator, size: 200, color: Colors.white.withOpacity(0.06)),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 44, 24, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.score.specialty.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.score.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.score.specialty.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.score.specialty,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Case 1: Point-Based Interactive Score ───────────────────
                if (hasCriteria) ...[
                  _buildScoreCard(_totalScore, themeAccent, isDark),
                  const SizedBox(height: 16),
                  if (_aiGenerated) ...[
                    _buildAiGeneratedDisclaimer(isDark),
                    const SizedBox(height: 16),
                  ],
                  _buildAiInsightCard(isDark, themeAccent),
                  _sectionLabel(
                      _aiGenerated
                          ? "CRITÈRES DU SCORE (GÉNÉRÉS PAR IA)"
                          : "CRITÈRES DU SCORE",
                      isDark),
                  const SizedBox(height: 10),
                  ..._buildCriteriaCards(isDark, themeAccent),
                  const SizedBox(height: 16),
                ],

                // ── Case 0: No local criteria/formula → AI generation ────────
                if (!hasCriteria && !isFormula) ...[
                  _buildAiGenerateCard(isDark),
                  const SizedBox(height: 16),
                ],

                // ── Case 2: Formula-Based Live Calculator ────────────────────
                if (isFormula) ...[
                  _buildFormulaOutputCard(isDark),
                  const SizedBox(height: 16),
                  _sectionLabel("PARAMÈTRES DE CALCUL", isDark),
                  const SizedBox(height: 10),
                  _buildFormulaInputForm(isDark),
                  const SizedBox(height: 16),
                ],

                // ── Interpretation Ranges (if available) ───────────────────
                if (_interpretations.isNotEmpty) ...[
                  _sectionLabel("INTERPRÉTATION CLINIQUE", isDark),
                  const SizedBox(height: 10),
                  _buildInterpretationCard(isDark),
                  const SizedBox(height: 16),
                ],

                // ── AI usage notes (from generated schema) ─────────────────
                if (_aiInterpretationText != null &&
                    _aiInterpretationText!.isNotEmpty) ...[
                  _sectionLabel("NOTES D'UTILISATION", isDark),
                  const SizedBox(height: 10),
                  _buildUsageNotesCard(isDark),
                  const SizedBox(height: 16),
                ],

                // ── Source link ─────────────────────────────────────────────
                if (widget.score.url.isNotEmpty) ...[
                  _buildSourceCard(isDark),
                  const SizedBox(height: 32),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Score Live Card Widget ───────────────────────────────────────────────

  Widget _buildScoreCard(double score, Color color, bool isDark) {
    final answered = _selectedOptions.where((s) => s >= 0).length;
    final total = _criteria.length;
    final progress = total == 0 ? 0.0 : answered / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Score Total",
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: _displayedScore, end: score),
                      duration: const Duration(milliseconds: 300),
                      builder: (_, v, __) {
                        _displayedScore = v;
                        final disp = v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);
                        return Text(
                          disp,
                          style: TextStyle(
                            color: color,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    Builder(
                      builder: (context) {
                        final range = _getCurrentInterpretationRange(score);
                        if (range != null && range.label.isNotEmpty) {
                          return Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              range.label,
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.3), width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  "$answered/$total",
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showAiAutoFillBottomSheet(context, color, isDark),
                icon: const Icon(Iconsax.magicpen, size: 14),
                label: const Text("Remplir avec l'IA", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              if (answered > 0)
                TextButton.icon(
                  onPressed: () => setState(() {
                    for (int i = 0; i < _selectedOptions.length; i++) {
                      _selectedOptions[i] = -1;
                    }
                    _aiInsight = null;
                  }),
                  icon: Icon(Iconsax.rotate_left, size: 14, color: color),
                  label: Text(
                    "Réinitialiser",
                    style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Criteria Cards (Point-Based UI) ──────────────────────────────────────

  List<Widget> _buildCriteriaCards(bool isDark, Color accentColor) {
    String? lastSection;
    final widgets = <Widget>[];

    for (int i = 0; i < _criteria.length; i++) {
      final criterion = _criteria[i];

      // Add section headers
      if (criterion.section != lastSection) {
        lastSection = criterion.section;
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  criterion.section,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
        ));
      }

      // Add question (if present)
      if (criterion.question.isNotEmpty) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 11),
          child: Text(
            criterion.question,
            style: TextStyle(
              fontSize: 12.5,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.white54 : Colors.black54,
              height: 1.4,
            ),
          ),
        ));
      }

      // Add options list
      widgets.add(_buildCriterionOptions(i, criterion, isDark, accentColor));
      widgets.add(const SizedBox(height: 8));
    }

    return widgets;
  }

  Widget _buildCriterionOptions(
      int criterionIndex, ScoreCriterion criterion, bool isDark, Color accentColor) {
    return Column(
      children: criterion.options.asMap().entries.map((entry) {
        final optIndex = entry.key;
        final option = entry.value;
        final isSelected = _selectedOptions[criterionIndex] == optIndex;
        final pts = option.points;
        final ptsColor = pts > 0
            ? const Color(0xFFEF4444)
            : pts < 0
                ? const Color(0xFF3B82F6)
                : const Color(0xFF10B981);

        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Material(
            color: isSelected ? accentColor.withOpacity(0.08) : (isDark ? Colors.white.withOpacity(0.03) : Colors.white),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() {
                _selectedOptions[criterionIndex] = isSelected ? -1 : optIndex;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? accentColor : (isDark ? Colors.white10 : Colors.black.withOpacity(0.06)),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? accentColor : Colors.grey,
                          width: 2,
                        ),
                        color: isSelected ? accentColor : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 10, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        option.label,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: ptsColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        pts == 0 ? "0 pt" : "${pts > 0 ? '+' : ''}${pts % 1 == 0 ? pts.toInt() : pts} pt",
                        style: TextStyle(
                          color: ptsColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Case 2: Formula-Based Widgets ────────────────────────────────────────

  Widget _buildFormulaOutputCard(bool isDark) {
    final color = _resColor(_formulaResultColor);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(
            "Résultat du Calcul",
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formulaResultString.isNotEmpty ? _formulaResultString : "--",
            style: TextStyle(
              color: color,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          if (_formulaError != null) ...[
            const SizedBox(height: 8),
            Text(
              _formulaError!,
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (_formulaInterpretation.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formulaInterpretation,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormulaInputForm(bool isDark) {
    final spec = _spec;
    if (spec == null) return const SizedBox.shrink();

    final children = <Widget>[];
    for (int i = 0; i < spec.inputs.length; i++) {
      if (i > 0) children.add(const SizedBox(height: 12));
      final input = spec.inputs[i];
      switch (input.type) {
        case FormulaInputType.number:
          children.add(_buildNumberField(input, isDark));
          break;
        case FormulaInputType.unit:
          children.add(_buildUnitField(input, isDark));
          break;
        case FormulaInputType.toggle:
          children.add(_buildToggleInput(input, isDark));
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildToggleInput(FormulaInput input, bool isDark) {
    final selected = _selectedToggleIndex[input.key] ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          input.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: input.options.asMap().entries.map((entry) {
            final idx = entry.key;
            final opt = entry.value;
            final isSelected = selected == idx;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedToggleIndex[input.key] = idx);
                  _calculateFormula();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF6366F1)
                        : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    opt.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNumberField(FormulaInput input, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          input.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controllers[input.key],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (_) => _calculateFormula(),
                ),
              ),
              if (input.unit.isNotEmpty)
                Text(
                  input.unit,
                  style: const TextStyle(
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnitField(FormulaInput input, bool isDark) {
    final selectedIdx = _selectedUnitIndex[input.key] ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          input.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controllers[input.key],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (_) => _calculateFormula(),
                ),
              ),
              DropdownButton<int>(
                value: selectedIdx < input.units.length ? selectedIdx : 0,
                items: input.units.asMap().entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(
                      entry.value.label,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedUnitIndex[input.key] = val);
                    _calculateFormula();
                  }
                },
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6366F1), size: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── General Info Cards ───────────────────────────────────────────────────

  Widget _buildInterpretationCard(bool isDark) {
    final ranges = _interpretations;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Iconsax.info_circle, size: 16, color: Color(0xFF6366F1)),
              SizedBox(width: 8),
              Text(
                "Interprétation clinique",
                style: TextStyle(
                  color: Color(0xFF6366F1),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...ranges.map((r) {
            final rangeColor = _colorFromRangeString(r.color);
            
            String formatVal(double val) {
              if (val.isInfinite) return val.isNegative ? '-∞' : '∞';
              if (val == val.roundToDouble()) return val.toInt().toString();
              return val.toStringAsFixed(1);
            }

            String rangeText;
            if (r.min.isInfinite && r.max.isInfinite) {
              rangeText = 'Tous les scores  ';
            } else if (r.min.isInfinite) {
              rangeText = '≤ ${formatVal(r.max)}  ';
            } else if (r.max.isInfinite) {
              rangeText = '≥ ${formatVal(r.min)}  ';
            } else if (r.min == r.max) {
              rangeText = '${formatVal(r.min)}  ';
            } else {
              rangeText = '${formatVal(r.min)} – ${formatVal(r.max)}  ';
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 3, right: 10),
                    decoration: BoxDecoration(
                       color: rangeColor,
                       shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: rangeText,
                            style: TextStyle(
                              color: rangeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: r.label,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSourceCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Icon(Iconsax.global, size: 16, color: isDark ? Colors.white38 : Colors.black38),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.score.url,
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            "medicalcul",
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Case 0: AI Schema Generation Widgets ─────────────────────────────────

  Widget _buildAiGenerateCard(bool isDark) {
    const accent = Color(0xFF6366F1);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.magicpen, color: accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Version interactive non disponible",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Ce calculateur n'a pas encore de version interactive intégrée. "
            "Meducyte AI peut analyser sa source de référence et générer les critères et l'interprétation.",
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          if (_isSchemaLoading)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(accent),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  "Analyse de la source et génération...",
                  style: TextStyle(fontSize: 12, color: accent),
                ),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: _generateInteractiveSchema,
              icon: const Icon(Iconsax.cpu, size: 16),
              label: const Text(
                "Générer avec l'IA",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          if (_schemaError != null) ...[
            const SizedBox(height: 10),
            Text(
              _schemaError!,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFFEF4444)),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAiGeneratedDisclaimer(bool isDark) {
    const warn = Color(0xFFF59E0B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: warn.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: warn.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.warning_2, size: 16, color: warn),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Critères générés par l'IA — vérifiez-les avec la source de référence avant tout usage clinique.",
              style: TextStyle(
                fontSize: 11,
                height: 1.4,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageNotesCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Text(
        _aiInterpretationText!,
        style: TextStyle(
          fontSize: 12.5,
          height: 1.5,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        color: isDark ? Colors.white54 : Colors.black54,
        fontWeight: FontWeight.bold,
        fontSize: 11,
        letterSpacing: 1,
      ),
    );
  }

  String _getSampleNote() {
    final name = widget.score.name.toLowerCase();
    if (name.contains('wells') || name.contains('tvp') || name.contains('phlébite')) {
      return "Patient de 65 ans présentant une douleur et un oedème unilatéral du mollet gauche depuis 2 jours (circonférence augmentée de 4 cm par rapport au côté droit). Pas de cancer actif ni d'alitement récent. Sensibilité le long du trajet veineux profond. Le diagnostic de thrombose veineuse profonde est retenu comme le plus probable.";
    }
    if (name.contains('glasgow') || name.contains('gcs')) {
      return "Patient admis aux urgences après traumatisme crânien. À l'évaluation, le patient n'ouvre les yeux qu'à la pression douloureuse. Il émet des sons incompréhensibles et présente une flexion réflexe (décortication) lors de la stimulation douloureuse.";
    }
    if (name.contains('curb') || name.contains('crb') || name.contains('pneumonie')) {
      return "Patiente de 78 ans admise pour pneumopathie. Elle présente une confusion temporelle. Sa tension artérielle est de 85/50 mmHg. Sa fréquence respiratoire est de 32 cycles par minute.";
    }
    if (name.contains('apgar')) {
      return "Nouveau-né à 1 minute de vie. Fréquence cardiaque à 110 bpm, cri vigoureux et bonne respiration. Les membres sont légèrement fléchis, réactivité grimace lors de l'aspiration nasale. Le corps est rose mais les extrémités sont cyanosées.";
    }
    if (name.contains('nihss') || name.contains('avc') || name.contains('stroke')) {
      return "Patient suspect d'AVC aigu. À l'examen, vigilance normale, répond correctement aux deux questions, obéit aux deux ordres. Pas d'hémianopsie. Paralysie faciale partielle mineure. Parésie modérée du bras droit (chute à 5 secondes). Pas de déficit de la jambe droite. Pas d'ataxie. Hypoesthésie légère à droite. Aphasie légère. Dysarthrie modérée. Pas d'extinction.";
    }
    return "Patient de 72 ans se présentant avec des symptômes évocateurs. Pas de signes de gravité immédiats. Les paramètres vitaux sont dans les normes, absence de dyspnée ou de douleur thoracique.";
  }

  void _showAiAutoFillBottomSheet(BuildContext context, Color themeAccent, bool isDark) {
    final sampleNote = _getSampleNote();
    final textController = TextEditingController();
    bool isLoading = false;
    String loadingStatus = "Lecture de la note clinique...";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white24 : Colors.black12,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: themeAccent.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Iconsax.magicpen, color: themeAccent, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Remplissage IA",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  "Extraction clinique par Llama 3.3",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.white54 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, size: 20, color: isDark ? Colors.white54 : Colors.black54),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Sample note action card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: themeAccent.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: themeAccent.withOpacity(0.15)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Tester avec un exemple",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Insérer un cas clinique type pour ce calculateur.",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark ? Colors.white54 : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                textController.text = sampleNote;
                                setModalState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeAccent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Insérer", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Text area
                      TextField(
                        controller: textController,
                        maxLines: 6,
                        minLines: 4,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: "Saisissez ou collez l'observation clinique du patient ici...",
                          hintStyle: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.08),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: themeAccent, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.all(14),
                        ),
                        onChanged: (_) => setModalState(() {}),
                      ),
                      const SizedBox(height: 16),
                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text(
                                "Annuler",
                                style: TextStyle(
                                  color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: textController.text.trim().isEmpty
                                  ? null
                                  : () async {
                                      setModalState(() {
                                        isLoading = true;
                                        loadingStatus = "Lecture de la note clinique...";
                                      });
                                      
                                      // Cycle status messages to look extremely high-tech
                                      Future.delayed(const Duration(milliseconds: 700), () {
                                        if (context.mounted && isLoading) {
                                          setModalState(() => loadingStatus = "Extraction des signes physiques...");
                                        }
                                      });
                                      Future.delayed(const Duration(milliseconds: 1400), () {
                                        if (context.mounted && isLoading) {
                                          setModalState(() => loadingStatus = "Analyse et scoring des critères...");
                                        }
                                      });

                                      try {
                                        final aiRepo = ref.read(calculatorAiRepositoryProvider);
                                        final result = await aiRepo.autoFillFromClinicalNote(
                                          calculatorName: widget.score.name,
                                          criteria: _criteria,
                                          clinicalNote: textController.text.trim(),
                                        );

                                        if (context.mounted) {
                                          int filledCount = 0;
                                          setState(() {
                                            result.forEach((key, val) {
                                              if (key >= 0 && key < _selectedOptions.length) {
                                                final criterion = _criteria[key];
                                                if (val >= 0 && val < criterion.options.length) {
                                                  _selectedOptions[key] = val;
                                                  filledCount++;
                                                }
                                              }
                                            });
                                          });

                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  const Icon(Icons.check_circle, color: Colors.white, size: 18),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    "Remplissage réussi ! $filledCount critères analysés.",
                                                    style: const TextStyle(fontSize: 12.5),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor: const Color(0xFF10B981),
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              margin: const EdgeInsets.all(12),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          setModalState(() => isLoading = false);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Erreur d'extraction par l'IA : $e",
                                                style: const TextStyle(fontSize: 12.5),
                                              ),
                                              backgroundColor: const Color(0xFFEF4444),
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              margin: const EdgeInsets.all(12),
                                            ),
                                          );
                                        }
                                      }
                                    },
                              icon: const Icon(Iconsax.cpu, size: 16),
                              label: const Text(
                                "Analyser",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeAccent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Loading Overlay
                  if (isLoading)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B).withOpacity(0.92) : Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: CircularProgressIndicator(
                                strokeWidth: 3.5,
                                valueColor: AlwaysStoppedAnimation(themeAccent),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              loadingStatus,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Extraction en cours...",
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAiInsightCard(bool isDark, Color color) {
    if (_criteria.isEmpty) return const SizedBox.shrink();
    
    final answered = _selectedOptions.where((s) => s >= 0).length;
    final total = _criteria.length;
    if (answered < total) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Iconsax.cpu, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Meducyte AI Insight",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_aiInsight == null && !_isInsightLoading) ...[
            Text(
              "Tous les critères sont remplis. Générez une analyse clinique approfondie de ce résultat par l'IA.",
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _isInsightLoading = true;
                });
                try {
                  final aiRepo = ref.read(calculatorAiRepositoryProvider);
                  String formatBound(double v) {
                    if (v.isInfinite) return v.isNegative ? '-inf' : '+inf';
                    return v == v.roundToDouble()
                        ? v.toInt().toString()
                        : v.toStringAsFixed(1);
                  }
                  String interpretation = "";
                  if (_interpretations.isNotEmpty) {
                    interpretation = _interpretations
                        .map((r) =>
                            '${formatBound(r.min)}-${formatBound(r.max)}: ${r.label}')
                        .join(', ');
                  }
                  
                  final insight = await aiRepo.getClinicalInsight(
                    calculatorName: widget.score.name,
                    score: _totalScore,
                    interpretation: interpretation,
                    lang: 'fr',
                  );
                  setState(() {
                    _aiInsight = insight;
                    _isInsightLoading = false;
                  });
                } catch (e) {
                  setState(() {
                    _isInsightLoading = false;
                    _aiInsight = "Erreur de génération : $e";
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text("Générer l'analyse clinique", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ] else if (_isInsightLoading) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(color)),
                ),
                const SizedBox(width: 12),
                Text(
                  "Génération de l'analyse clinique par l'IA...",
                  style: TextStyle(fontSize: 11.5, color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7)),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ] else ...[
            Text(
              _aiInsight!,
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _aiInsight!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Analyse copiée dans le presse-papiers !", style: TextStyle(fontSize: 12)),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: color,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: Icon(Iconsax.copy, size: 14, color: color),
                  label: Text("Copier", style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _aiInsight = null;
                    });
                  },
                  icon: Icon(Iconsax.refresh, size: 14, color: color),
                  label: Text("Réinitialiser", style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
