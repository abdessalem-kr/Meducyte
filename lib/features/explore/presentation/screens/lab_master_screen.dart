import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/explore/domain/models/game_models.dart';
import 'package:meducyte_app/features/explore/data/providers/game_content_provider.dart';

class LabMasterScreen extends ConsumerStatefulWidget {
  const LabMasterScreen({super.key});

  @override
  ConsumerState<LabMasterScreen> createState() => _LabMasterScreenState();
}

class _LabMasterScreenState extends ConsumerState<LabMasterScreen> {
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _showResult = false;

  @override
  Widget build(BuildContext context) {
    final List<LabResult> results = ref.watch(labResultsProvider);
    final theme = Theme.of(context);

    if (_currentIndex >= results.length) {
      return _buildFinalSuccess(theme);
    }

    final current = results[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA), //Bio-teal background
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "LAB BIOLOGY v3.1",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 2,
            color: Colors.teal,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [Colors.teal.withOpacity(0.1), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "ANALYSE DU BILAN BIOLOGIQUE",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 32),
                //Laboratory Result Card
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.05),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.teal.withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          current.parameter.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${current.value}",
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              letterSpacing: -2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              current.unit,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text(
                        "VALEURS DE RÉFÉRENCE",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${current.minNormal} - ${current.maxNormal} ${current.unit}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                const Text(
                  "INTERPRÉTATION:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildOption(
                      0,
                      "Normal",
                      Iconsax.tick_circle,
                      Colors.green,
                    ),
                    const SizedBox(width: 12),
                    _buildOption(
                      1,
                      "Diminué",
                      Iconsax.arrow_down,
                      Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _buildOption(2, "Augmenté", Iconsax.arrow_up, Colors.red),
                  ],
                ),
                const Spacer(),
                if (_showResult) ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "NOTE CLINIQUE",
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          current.interpretation,
                          style: const TextStyle(
                            color: Colors.white,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                ElevatedButton(
                  onPressed: _selectedIndex == null
                      ? null
                      : (_showResult
                            ? _next
                            : () => setState(() => _showResult = true)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _showResult ? "PROCHAIN BILAN" : "VÉRIFIER L'ANALYSE",
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(int index, String label, IconData icon, Color color) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: _showResult
            ? null
            : () => setState(() => _selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : Colors.grey.withOpacity(0.1),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? color : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _next() {
    setState(() {
      _currentIndex++;
      _selectedIndex = null;
      _showResult = false;
    });
  }

  Widget _buildFinalSuccess(ThemeData theme) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.radar_2, color: Colors.teal, size: 100),
            const SizedBox(height: 24),
            const Text(
              "LAB DIRECTOR",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Retour"),
            ),
          ],
        ),
      ),
    );
  }
}
