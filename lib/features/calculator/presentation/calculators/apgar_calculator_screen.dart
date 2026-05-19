import 'package:meducyte_app/export.dart';

class ApgarCalculatorScreen extends StatefulWidget {
  const ApgarCalculatorScreen({super.key});

  @override
  State<ApgarCalculatorScreen> createState() => _ApgarCalculatorScreenState();
}

class _ApgarCalculatorScreenState extends State<ApgarCalculatorScreen> {
  int? _heartRate;
  int? _respiration;
  int? _tone;
  int? _reflex;
  int? _color;

  final Map<int, String> _heartOptions = {
    2: '≥100/min',
    1: '<100/min',
    0: 'Absent',
  };

  final Map<int, String> _respirationOptions = {
    2: 'Strong cry',
    1: 'Weak,irregular',
    0: 'Absent',
  };

  final Map<int, String> _toneOptions = {
    2: 'Active motion',
    1: 'Some flexion',
    0: 'Limp',
  };

  final Map<int, String> _reflexOptions = {
    2: 'Cough,sneeze,cry',
    1: 'Grimace',
    0: 'No response',
  };

  final Map<int, String> _colorOptions = {
    2: 'Completely pink',
    1: 'Pink body,blue limbs(Acrocyanosis)',
    0: 'Blue,pale',
  };

  int? get _totalScore {
    if (_heartRate == null ||
        _respiration == null ||
        _tone == null ||
        _reflex == null ||
        _color == null) {
      return null;
    }
    return _heartRate! + _respiration! + _tone! + _reflex! + _color!;
  }

  String _getInterpretation(int score) {
    if (score >= 7) return 'Normal(Excellente condition)';
    if (score >= 4) return 'Moderate Depression(Condition moyenne)';
    return 'Severe Depression(Condition critique)';
  }

  Color _getScoreColor(int score) {
    if (score >= 7) return Colors.green;
    if (score >= 4) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('APGAR Score'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_totalScore != null) _buildResultCard(),
            const SizedBox(height: 16),
            _buildSection(
              'Heart Rate',
              _heartOptions,
              _heartRate,
              (val) => setState(() => _heartRate = val),
            ),
            const SizedBox(height: 12),
            _buildSection(
              'Respiratory Effort',
              _respirationOptions,
              _respiration,
              (val) => setState(() => _respiration = val),
            ),
            const SizedBox(height: 12),
            _buildSection(
              'Muscle Tone',
              _toneOptions,
              _tone,
              (val) => setState(() => _tone = val),
            ),
            const SizedBox(height: 12),
            _buildSection(
              'Reflex Irritability',
              _reflexOptions,
              _reflex,
              (val) => setState(() => _reflex = val),
            ),
            const SizedBox(height: 12),
            _buildSection(
              'Color',
              _colorOptions,
              _color,
              (val) => setState(() => _color = val),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final score = _totalScore!;
    final color = _getScoreColor(score);
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
              'APGAR Total Score',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$score/10',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getInterpretation(score),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    Map<int, String> options,
    int? selectedValue,
    ValueChanged<int?> onChanged,
  ) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
          ),
          ...options.entries.map((entry) {
            return RadioListTile<int>(
              value: entry.key,
              groupValue: selectedValue,
              onChanged: onChanged,
              title: Text(entry.value, style: const TextStyle(fontSize: 14)),
              secondary: Text(
                '${entry.key}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              dense: true,
              activeColor: AppColors.primary,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Reference',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '•7-10:Low risk,routine care.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '•4-6:Resuscitation(stimulation,O2).',
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '•0-3:Emergency Resuscitation(CPR).',
              style: TextStyle(
                fontSize: 13,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
