import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/explore/domain/models/game_models.dart';
import 'package:meducyte_app/features/explore/data/providers/game_content_provider.dart';

class WordAssociationScreen extends ConsumerStatefulWidget {
  const WordAssociationScreen({super.key});

  @override
  ConsumerState<WordAssociationScreen> createState() =>
      _WordAssociationScreenState();
}

class _WordAssociationScreenState extends ConsumerState<WordAssociationScreen> {
  int _currentIndex = 0;
  final TextEditingController _controller = TextEditingController();
  bool _showSuccess = false;

  @override
  Widget build(BuildContext context) {
    final List<WordAssociationPair> pairs = ref.watch(wordAssociationProvider);
    final theme = Theme.of(context);

    if (_currentIndex >= pairs.length) {
      return _buildFinalSuccess(theme);
    }

    final current = pairs[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "LOGIC CHAIN",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
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
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.indigo.withOpacity(0.05), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text(
                  "TROUVEZ LE CONCEPT MÉDICAL LIÉ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                //Association Node
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.1),
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Iconsax.link, color: Colors.indigo, size: 32),
                      const SizedBox(height: 16),
                      Text(
                        current.word.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E1B4B),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                const Icon(Iconsax.arrow_down, color: Colors.indigo, size: 32),
                const SizedBox(height: 48),
                //Input Field
                TextField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: "Concept associé...",
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: Colors.indigo,
                        width: 2,
                      ),
                    ),
                  ),
                  onSubmitted: (_) => _checkAnswer(current.relatedWord),
                ),
                if (_showSuccess) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      "LOGIQUE: ${current.logic}",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _checkAnswer(current.relatedWord),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    _showSuccess ? "MAILLON SUIVANT" : "LIER LES CONCEPTS",
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _checkAnswer(String correct) {
    if (_showSuccess) {
      setState(() {
        _currentIndex++;
        _controller.clear();
        _showSuccess = false;
      });
      return;
    }

    if (_controller.text.trim().toLowerCase() == correct.toLowerCase()) {
      setState(() => _showSuccess = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lien non valide.Réessayez."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildFinalSuccess(ThemeData theme) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.link_1, color: Colors.indigo, size: 100),
            const SizedBox(height: 24),
            const Text(
              "CHAÎNE PARFAITE",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E1B4B),
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
