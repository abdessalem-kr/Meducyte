import 'package:meducyte_app/export.dart';

class WellsPeCalculatorScreen extends StatefulWidget {
  const WellsPeCalculatorScreen({super.key});

  @override
  State<WellsPeCalculatorScreen> createState() =>
      _WellsPeCalculatorScreenState();
}

class _WellsPeCalculatorScreenState extends State<WellsPeCalculatorScreen> {
  final Map<int, bool> _selections = {
    0: false,
    1: false,
    2: false,
    3: false,
    4: false,
    5: false,
    6: false,
  };

  final List<Map<String, dynamic>> _criteria = [
    {'label': 'Clinical signs and symptoms of DVT', 'points': 3.0},
    {'label': 'PE is#1 diagnosis OR equally likely', 'points': 3.0},
    {'label': 'Heart rate>100 beats/min', 'points': 1.5},
    {
      'label': 'Immobilization≥3 days OR surgery in previous 4 weeks',
      'points': 1.5,
    },
    {'label': 'Previous objective diagnosis of PE or DVT', 'points': 1.5},
    {'label': 'Hemoptysis', 'points': 1.0},
    {'label': 'Malignancy(treated within 6 mo or palliative)', 'points': 1.0},
  ];

  double get _totalScore {
    double total = 0;
    _selections.forEach((index, isSelected) {
      if (isSelected) total += _criteria[index]['points'];
    });
    return total;
  }

  String _getInterpretation(double score) {
    if (score > 6.0) return 'High Probability(Probabilitéforte)';
    if (score >= 2.0) return 'Moderate Probability(Probabilitémoyenne)';
    return 'Low Probability(Probabilitéfaible)';
  }

  Color _getScoreColor(double score) {
    if (score > 6.0) return Colors.red;
    if (score >= 2.0) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Wells Criteria for PE'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildResultCard(),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _criteria.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.grey[100],
                ),
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    value: _selections[index],
                    onChanged: (val) =>
                        setState(() => _selections[index] = val ?? false),
                    title: Text(
                      _criteria[index]['label'],
                      style: const TextStyle(fontSize: 14),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+${_criteria[index]['points']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    activeColor: AppColors.primary,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final score = _totalScore;
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
              'Wells Total Score',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              score % 1 == 0 ? score.toInt().toString() : score.toString(),
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
              'Probability(3 levels)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '•0-1.5:Low(1.3-3.4%)',
              style: TextStyle(
                fontSize: 13,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '•2.0-6.0:Moderate(16.2%)',
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '• >6.0:High(37.5-40.6%)',
              style: TextStyle(
                fontSize: 13,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Alternative(PE unlikely/likely)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              '•0-4:PE Unlikely(D-Dimer indicated)',
              style: TextStyle(fontSize: 13),
            ),
            Text(
              '• >4:PE Likely(Imaging indicated)',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
