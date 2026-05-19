import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/explore/domain/models/game_models.dart';
import 'package:meducyte_app/features/explore/data/providers/game_content_provider.dart';

class PharmaMatchScreen extends ConsumerStatefulWidget {
  const PharmaMatchScreen({super.key});

  @override
  ConsumerState<PharmaMatchScreen> createState() => _PharmaMatchScreenState();
}

class _PharmaMatchScreenState extends ConsumerState<PharmaMatchScreen> {
  String? _selectedDrug;
  String? _selectedClass;
  final Set<String> _matchedIds = {};
  List<String> _shuffledDrugs = [];
  List<String> _shuffledClasses = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pairs = ref.read(pharmaPairsProvider);
      setState(() {
        _shuffledDrugs = pairs.map((p) => p.drug).toList()..shuffle();
        _shuffledClasses = pairs.map((p) => p.drugClass).toList()..shuffle();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<PharmaPair> pairs = ref.watch(pharmaPairsProvider);
    final theme = Theme.of(context);

    if (_shuffledDrugs.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_matchedIds.length == pairs.length) {
      return _buildSuccessScreen(theme);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "PHARMA CONNECT",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.withOpacity(0.05),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Text(
                "CONNECTEZ LA MOLÉCULEÀSA CLASSE THÉRAPEUTIQUE",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Row(
                  children: [
                    //Drugs Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "MOLÉCULE",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView(
                              children: _shuffledDrugs.map((drugName) {
                                final pair = pairs.firstWhere(
                                  (p) => p.drug == drugName,
                                );
                                final isMatched = _matchedIds.contains(pair.id);
                                final isSelected = _selectedDrug == drugName;
                                return _buildItem(
                                  drugName,
                                  isSelected,
                                  isMatched,
                                  true,
                                  Colors.green,
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    //Classes Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "CLASSE",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView(
                              children: _shuffledClasses.map((className) {
                                final pair = pairs.firstWhere(
                                  (p) => p.drugClass == className,
                                );
                                final isMatched = _matchedIds.contains(pair.id);
                                final isSelected = _selectedClass == className;
                                return _buildItem(
                                  className,
                                  isSelected,
                                  isMatched,
                                  false,
                                  Colors.blue,
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    String title,
    bool isSelected,
    bool isMatched,
    bool isDrug,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: isMatched ? null : () => _onTap(title, isDrug),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isMatched
                ? Colors.grey.withOpacity(0.05)
                : (isSelected
                      ? color.withOpacity(0.1)
                      : Theme.of(context).cardColor),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isMatched
                  ? Colors.grey.withOpacity(0.2)
                  : (isSelected ? color : Colors.grey.withOpacity(0.1)),
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: isMatched ? Colors.grey : (isSelected ? color : null),
                decoration: isMatched ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(String title, bool isDrug) {
    setState(() {
      if (isDrug) {
        _selectedDrug = title;
      } else {
        _selectedClass = title;
      }

      if (_selectedDrug != null && _selectedClass != null) {
        final List<PharmaPair> pairs = ref.read(pharmaPairsProvider);
        try {
          final pair = pairs.firstWhere(
            (p) => p.drug == _selectedDrug && p.drugClass == _selectedClass,
          );
          _matchedIds.add(pair.id);
          _showCorrectMatch(pair);
        } catch (_) {
          //Vibrer ou autre feedback d'erreur
        }
        _selectedDrug = null;
        _selectedClass = null;
      }
    });
  }

  void _showCorrectMatch(PharmaPair pair) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "MATCH RÉUSSI: ${pair.drug}",
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              pair.mechanism,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSuccessScreen(ThemeData theme) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.judge, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            const Text(
              "PHARMACOLOGUE CERTIFIÉ",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Toutes les molécules sont appairées.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text("RETOUR AU HUB"),
            ),
          ],
        ),
      ),
    );
  }
}
