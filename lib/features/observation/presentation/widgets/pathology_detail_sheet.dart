import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:meducyte_app/features/observation/data/models/specialty_config.dart';

class PathologyDetailSheet extends ConsumerWidget {
  final PathologyGuide pathology;
  final VoidCallback? onStartExam;

  const PathologyDetailSheet({
    super.key,
    required this.pathology,
    this.onStartExam,
  });

  static Future<void> show(
    BuildContext context,
    PathologyGuide pathology, {
    VoidCallback? onStartExam,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PathologyDetailSheet(
        pathology: pathology,
        onStartExam: onStartExam,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          //Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          //Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Iconsax.radar, color: Colors.purple),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Guide pour Internes",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        pathology.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Iconsax.close_circle),
                ),
              ],
            ),
          ),
          const Divider(height: 32),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                if (pathology.description != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      pathology.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                //Red Flags-Must Not Miss
                if (pathology.redFlags != null)
                  _buildSection(
                    context,
                    "RED FLAGS/SIGNES D'URGENCE",
                    Iconsax.danger,
                    Colors.red,
                    pathology.redFlags!
                        .map((f) => _buildPoint(context, f, Colors.red))
                        .toList(),
                  ),

                //Diagnostic Scores/Criteria
                if (pathology.scores != null)
                  _buildSection(
                    context,
                    "CRITÈRES DIAGNOSTIQUES & SCORES INTERACTIFS",
                    Iconsax.judge,
                    Colors.blue,
                    pathology.scores!
                        .map((s) => _ScoreCalculatorWidget(score: s))
                        .toList(),
                  ),

                //Management Hints
                if (pathology.immediateManagement != null)
                  _buildSection(
                    context,
                    "CONDUITEÀTENIR IMMÉDIATE",
                    Iconsax.flash,
                    Colors.green,
                    pathology.immediateManagement!
                        .map((m) => _buildPoint(context, m, Colors.green))
                        .toList(),
                  ),

                //Differential Diagnosis
                if (pathology.differentialDiagnosis != null)
                  _buildSection(
                    context,
                    "DIAGNOSTICS DIFFÉRENTIELS",
                    Iconsax.hierarchy,
                    Colors.orange,
                    pathology.differentialDiagnosis!
                        .map((d) => _buildPoint(context, d, Colors.orange))
                        .toList(),
                  ),

                const SizedBox(height: 40),
              ],
            ),
          ),
          if (onStartExam != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onStartExam,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.play, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        "Démarrer l'examen clinique",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPoint(BuildContext context, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCalculatorWidget extends StatefulWidget {
  final DiagnosticScore score;

  const _ScoreCalculatorWidget({required this.score});

  @override
  State<_ScoreCalculatorWidget> createState() => _ScoreCalculatorWidgetState();
}

class _ScoreCalculatorWidgetState extends State<_ScoreCalculatorWidget> {
  final Set<int> _selectedIndices = {};

  int _getPoints(String criterion) {
    final regExp = RegExp(r'\(\+(\d+)\)');
    final match = regExp.firstMatch(criterion);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 1; // default to 1 point
  }

  String _getCleanText(String criterion) {
    return criterion.replaceAll(RegExp(r'\s*\(\+\d+\)'), '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Calculate total points and max points
    int totalScore = 0;
    int maxScore = 0;
    for (int i = 0; i < widget.score.criteria.length; i++) {
      final pts = _getPoints(widget.score.criteria[i]);
      maxScore += pts;
      if (_selectedIndices.contains(i)) {
        totalScore += pts;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.score.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.score.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "$totalScore",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      " / $maxScore",
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...List.generate(widget.score.criteria.length, (index) {
            final criterion = widget.score.criteria[index];
            final cleanText = _getCleanText(criterion);
            final points = _getPoints(criterion);
            final isSelected = _selectedIndices.contains(index);

            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedIndices.remove(index);
                  } else {
                    _selectedIndices.add(index);
                  }
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSelected ? theme.primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? theme.primaryColor : theme.hintColor.withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        cleanText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected ? null : theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                          fontWeight: isSelected ? FontWeight.w600 : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "+$points pt${points > 1 ? 's' : ''}",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.hintColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Iconsax.info_circle,
                  color: Colors.green,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Interprétation Clinique",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.score.interpretation,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w500,
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
    );
  }
}
