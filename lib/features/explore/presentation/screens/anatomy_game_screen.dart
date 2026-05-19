import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/explore/domain/models/game_models.dart';
import 'package:meducyte_app/features/explore/data/providers/game_content_provider.dart';

class AnatomyGameScreen extends ConsumerStatefulWidget {
  const AnatomyGameScreen({super.key});

  @override
  ConsumerState<AnatomyGameScreen> createState() => _AnatomyGameScreenState();
}

class _AnatomyGameScreenState extends ConsumerState<AnatomyGameScreen> {
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _showResult = false;
  int _score = 0;

  @override
  Widget build(BuildContext context) {
    final List<AnatomyQuestion> questions = ref.watch(anatomyGamesProvider);
    final theme = Theme.of(context);

    if (_currentIndex >= questions.length) {
      return _buildScoreScreen(theme);
    }

    final question = questions[_currentIndex];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "ANATOMY SCAN",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 2,
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
              AppColors.primary.withOpacity(0.05),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //Minimalist Progress
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (_currentIndex + 1) / questions.length,
                          backgroundColor: Colors.grey.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "${_currentIndex + 1} / ${questions.length}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                //Question Card(The"Scan"View)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "EXAMEN MACROSCOPIQUE",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        question.question,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                const Text(
                  "IDENTIFIEZ LA STRUCTURE:",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                //Options
                Expanded(
                  child: ListView.separated(
                    itemCount: question.options.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final isCorrect = index == question.correctIndex;
                      final isSelected = index == _selectedIndex;

                      Color borderColor = Colors.grey.withOpacity(0.1);
                      Color bgColor = theme.cardColor;
                      IconData? icon;

                      if (_showResult) {
                        if (isCorrect) {
                          borderColor = Colors.green;
                          bgColor = Colors.green.withOpacity(0.05);
                          icon = Icons.check_circle;
                        } else if (isSelected) {
                          borderColor = Colors.red;
                          bgColor = Colors.red.withOpacity(0.05);
                          icon = Icons.cancel;
                        }
                      } else if (isSelected) {
                        borderColor = AppColors.primary;
                        bgColor = AppColors.primary.withOpacity(0.05);
                      }

                      return GestureDetector(
                        onTap: _showResult
                            ? null
                            : () => setState(() => _selectedIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: Row(
                            children: [
                              Text(
                                String.fromCharCode(65 + index),
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                  question.options[index],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (icon != null)
                                Icon(
                                  icon,
                                  color: icon == Icons.check_circle
                                      ? Colors.green
                                      : Colors.red,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _selectedIndex == null
                      ? null
                      : (_showResult ? _nextQuestion : _checkAnswer),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _showResult
                        ? "CONTINUER LE SCAN"
                        : "CONFIRMER L'IDENTIFICATION",
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

  void _checkAnswer() {
    setState(() {
      _showResult = true;
      final questions = ref.read(anatomyGamesProvider);
      if (_selectedIndex == questions[_currentIndex].correctIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentIndex++;
      _selectedIndex = null;
      _showResult = false;
    });
  }

  Widget _buildScoreScreen(ThemeData theme) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.medal, color: Colors.white, size: 120),
            const SizedBox(height: 40),
            const Text(
              "ANATOMISTE CERTIFIÉ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Score final: $_score/ ${ref.read(anatomyGamesProvider).length}",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 64),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "TERMINER LA SESSION",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
