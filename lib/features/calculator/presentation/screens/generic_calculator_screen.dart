import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/calculator/domain/models/calculator_models.dart';
import 'package:meducyte_app/features/calculator/presentation/providers/calculator_provider.dart';

class GenericCalculatorScreen extends ConsumerStatefulWidget {
  final MedicalCalculatorMetadata calculator;

  const GenericCalculatorScreen({super.key, required this.calculator});

  @override
  ConsumerState<GenericCalculatorScreen> createState() =>
      _GenericCalculatorScreenState();
}

class _GenericCalculatorScreenState
    extends ConsumerState<GenericCalculatorScreen> {
  //Store selections:index of criterion->index of selected option(for radio)or bool(for checkbox)or double(for numeric)
  final Map<int, dynamic> _selections = {};
  final Map<int, TextEditingController> _controllers = {};

  String? _aiInsight;
  bool _isLoadingAi = false;

  @override
  void initState() {
    super.initState();
    _initializeSelections();
  }

  void _initializeSelections() {
    final schema = widget.calculator.schema;
    if (schema == null) return;

    for (int i = 0; i < schema.criteria.length; i++) {
      final criterion = schema.criteria[i];
      if (criterion.type == 'checkbox') {
        _selections[i] = false;
      } else if (criterion.type == 'radio') {
        _selections[i] = null; //No selection initially
      } else if (criterion.type == 'numeric') {
        _selections[i] = criterion.defaultValue ?? 0.0;
        _controllers[i] = TextEditingController(
          text: _selections[i].toString(),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double get _totalScore {
    final schema = widget.calculator.schema;
    if (schema == null) return 0;

    double total = 0;
    for (int i = 0; i < schema.criteria.length; i++) {
      final criterion = schema.criteria[i];
      final selection = _selections[i];

      if (criterion.type == 'checkbox' && selection == true) {
        total += criterion.points ?? 0;
      } else if (criterion.type == 'radio' && selection != null) {
        total += criterion.options![selection as int].points;
      } else if (criterion.type == 'numeric') {
        total += selection ?? 0.0;
      }
    }
    return total;
  }

  ScoreInterpretation? get _currentInterpretation {
    final schema = widget.calculator.schema;
    if (schema == null) return null;

    final score = _totalScore;
    for (final interpretation in schema.interpretations) {
      if (score >= interpretation.min && score <= interpretation.max) {
        return interpretation;
      }
    }
    return null;
  }

  Color _getInterpretationColor(String? colorStr) {
    switch (colorStr?.toLowerCase()) {
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  Future<void> _fetchAiInsight() async {
    setState(() {
      _isLoadingAi = true;
      _aiInsight = null;
    });

    try {
      final repo = ref.read(calculatorAiRepositoryProvider);
      final interpretation =
          _currentInterpretation?.label ?? "No interpretation available";

      final insight = await repo.getClinicalInsight(
        calculatorName: widget.calculator.name,
        score: _totalScore,
        interpretation: interpretation,
        lang: Localizations.localeOf(context).languageCode,
      );

      setState(() {
        _aiInsight = insight;
        _isLoadingAi = false;
      });
    } catch (e) {
      setState(() {
        _aiInsight = "Error: $e";
        _isLoadingAi = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final schema = widget.calculator.schema;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: Text(widget.calculator.name), centerTitle: true),
      body: schema == null
          ? const Center(child: Text('No schema defined for this calculator.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildResultCard(),
                  const SizedBox(height: 16),
                  ...List.generate(schema.criteria.length, (index) {
                    final criterion = schema.criteria[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildCriterionCard(criterion, index),
                    );
                  }),
                  if (schema.interpretationText != null &&
                      schema.interpretationText!.isNotEmpty)
                    _buildInterpretationCard(schema.interpretationText!),

                  const SizedBox(height: 16),
                  _buildAiInsightCard(),

                  const SizedBox(height: 16),
                  _buildSourceInfo(),
                ],
              ),
            ),
    );
  }

  Widget _buildResultCard() {
    final interpretation = _currentInterpretation;
    final color = _getInterpretationColor(interpretation?.color);
    final score = _totalScore;

    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Total Score',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              score % 1 == 0
                  ? score.toInt().toString()
                  : score.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (interpretation != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  interpretation.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInterpretationCard(String text) {
    return Card(
      elevation: 0,
      color: AppColors.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Interprétation Médicale',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiInsightCard() {
    return Card(
      elevation: 0,
      color: Colors.deepPurple.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.deepPurple.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: Colors.deepPurple,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Meducyte AI Insight',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.deepPurple,
                  ),
                ),
                const Spacer(),
                if (_aiInsight == null && !_isLoadingAi)
                  TextButton.icon(
                    onPressed: _fetchAiInsight,
                    icon: const Icon(Icons.bolt, size: 16),
                    label: const Text('Generate'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
            if (_isLoadingAi)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.deepPurple,
                      ),
                    ),
                  ),
                ),
              ),
            if (_aiInsight != null) ...[
              const SizedBox(height: 12),
              Text(
                _aiInsight!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Powered by Llama 3.3',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCriterionCard(CalculatorCriterion criterion, int index) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (criterion.label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                criterion.label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
          if (criterion.type == 'checkbox')
            CheckboxListTile(
              value: _selections[index],
              onChanged: (val) => setState(() => _selections[index] = val),
              title: const Text('Present', style: TextStyle(fontSize: 14)),
              secondary: criterion.points != null
                  ? Text(
                      '+${criterion.points}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    )
                  : null,
              activeColor: AppColors.primary,
              dense: true,
            )
          else if (criterion.type == 'radio')
            ...List.generate(criterion.options!.length, (optIndex) {
              final option = criterion.options![optIndex];
              return RadioListTile<int>(
                value: optIndex,
                groupValue: _selections[index],
                onChanged: (val) => setState(() => _selections[index] = val),
                title: Text(option.label, style: const TextStyle(fontSize: 14)),
                secondary: Text(
                  '${option.points}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                activeColor: AppColors.primary,
                dense: true,
              );
            })
          else if (criterion.type == 'numeric')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
                controller: _controllers[index],
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  suffixText: criterion.unit,
                  hintText: 'Enter value',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _selections[index] = double.tryParse(val) ?? 0.0;
                  });
                },
              ),
            )
          else if (criterion.type == 'static')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        criterion.value ?? '',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSourceInfo() {
    return Column(
      children: [
        Text(
          'Source: ${widget.calculator.url}',
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
