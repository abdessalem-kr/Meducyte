import 'package:meducyte_app/export.dart';

class Cha2ds2vascCalculatorScreen extends StatefulWidget {
  const Cha2ds2vascCalculatorScreen({super.key});

  @override
  State<Cha2ds2vascCalculatorScreen> createState() =>
      _Cha2ds2vascCalculatorScreenState();
}

class _Cha2ds2vascCalculatorScreenState
    extends State<Cha2ds2vascCalculatorScreen> {
  final Map<int, bool> _selections = {
    0: false,
    1: false,
    2: false,
    3: false,
    4: false,
    5: false,
    6: false,
    7: false,
  };

  final List<Map<String, dynamic>> _criteria = [
    {'label': 'Congestive Heart Failure', 'points': 1},
    {'label': 'Hypertension', 'points': 1},
    {'label': 'Age≥75 years', 'points': 2},
    {'label': 'Diabetes Mellitus', 'points': 1},
    {'label': 'Stroke/TIA/Thromboembolism history', 'points': 2},
    {'label': 'Vascular Disease(prior MI,PAD,or aortic plaque)', 'points': 1},
    {'label': 'Age 65-74 years', 'points': 1},
    {'label': 'Sex Category(Female)', 'points': 1},
  ];

  int get _totalScore {
    int total = 0;
    _selections.forEach((index, isSelected) {
      if (isSelected) total += _criteria[index]['points'] as int;
    });
    return total;
  }

  String _getInterpretation(int score) {
    if (score == 0) return 'Low Risk(Risque faible)';
    if (score == 1) return 'Low-Moderate Risk(Risque modéré)';
    return 'Moderate-High Risk(Risqueélevé)';
  }

  String _getRecommendation(int score) {
    if (score == 0) return 'No antithrombotic therapy recommended.';
    if (score == 1) return 'Consider oral anticoagulation(OAC).';
    return 'Oral anticoagulation(OAC)recommended.';
  }

  Color _getScoreColor(int score) {
    if (score == 0) return Colors.green;
    if (score == 1) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('CHA2DS2-VASc Score'),
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
                    onChanged: (val) {
                      setState(() {
                        //Mutually exclusive age categories check
                        if (index == 2 && val == true) _selections[6] = false;
                        if (index == 6 && val == true) _selections[2] = false;
                        _selections[index] = val ?? false;
                      });
                    },
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
              'CHA2DS2-VASc Score',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$score',
              style: TextStyle(
                fontSize: 48,
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
            const SizedBox(height: 16),
            Text(
              _getRecommendation(score),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
                fontStyle: FontStyle.italic,
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estimated Stroke Risk',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildRiskRow('0', '0%'),
            _buildRiskRow('1', '1.3%'),
            _buildRiskRow('2', '2.2%'),
            _buildRiskRow('3', '3.2%'),
            _buildRiskRow('4', '4.0%'),
            _buildRiskRow('5', '6.7%'),
            _buildRiskRow('6', '9.8%'),
            _buildRiskRow('7-9', '9.6-15.2%'),
            const SizedBox(height: 12),
            Text(
              'Note:These are estimated annual riscos base on the original validation study.',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskRow(String score, String risk) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Score$score', style: const TextStyle(fontSize: 12)),
          Text(
            risk,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
