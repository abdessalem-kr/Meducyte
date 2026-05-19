import 'package:meducyte_app/export.dart';

class GlasgowCalculatorScreen extends StatefulWidget {
  const GlasgowCalculatorScreen({super.key});

  @override
  State<GlasgowCalculatorScreen> createState() =>
      _GlasgowCalculatorScreenState();
}

class _GlasgowCalculatorScreenState extends State<GlasgowCalculatorScreen> {
  int? _eyeOpening;
  int? _verbalResponse;
  int? _motorResponse;

  final Map<int, String> _eyeOptions = {
    4: 'Spontaneous opening',
    3: 'To speech',
    2: 'To pain',
    1: 'None',
  };

  final Map<int, String> _verbalOptions = {
    5: 'Oriented',
    4: 'Confused',
    3: 'Inappropriate words',
    2: 'Incomprehensible sounds',
    1: 'None',
  };

  final Map<int, String> _motorOptions = {
    6: 'Obeys commands',
    5: 'Localizes to pain',
    4: 'Withdraws from pain',
    3: 'Abnormal flexion(decorticate)',
    2: 'Abnormal extension(decerebrate)',
    1: 'None',
  };

  int? get _totalScore {
    if (_eyeOpening == null ||
        _verbalResponse == null ||
        _motorResponse == null) {
      return null;
    }
    return _eyeOpening! + _verbalResponse! + _motorResponse!;
  }

  String _getInterpretation(int score) {
    if (score >= 13) return 'Mild Brain Injury(Léger)';
    if (score >= 9) return 'Moderate Brain Injury(Modéré)';
    return 'Severe Brain Injury(Sévère/Coma)';
  }

  Color _getScoreColor(int score) {
    if (score >= 13) return Colors.green;
    if (score >= 9) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Glasgow Coma Scale(GCS)'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_totalScore != null) _buildResultCard(),
            const SizedBox(height: 16),
            _buildSection(
              'Eye Opening(E)',
              _eyeOptions,
              _eyeOpening,
              (val) => setState(() => _eyeOpening = val),
            ),
            const SizedBox(height: 12),
            _buildSection(
              'Verbal Response(V)',
              _verbalOptions,
              _verbalResponse,
              (val) => setState(() => _verbalResponse = val),
            ),
            const SizedBox(height: 12),
            _buildSection(
              'Motor Response(M)',
              _motorOptions,
              _motorResponse,
              (val) => setState(() => _motorResponse = val),
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
              'GCS Total Score(E+V+M)',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$score/15',
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
              '•Severe:GCS≤8(Intubate?)',
              style: TextStyle(
                fontSize: 13,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '•Moderate:GCS 9-12',
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '•Mild:GCS 13-15',
              style: TextStyle(
                fontSize: 13,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
