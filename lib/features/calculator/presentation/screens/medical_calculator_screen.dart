import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/calculator/domain/models/medical_score_model.dart';
import 'package:meducyte_app/features/calculator/presentation/providers/medical_scores_provider.dart';
import 'package:meducyte_app/features/calculator/presentation/screens/medical_score_detail_screen.dart';

class MedicalCalculatorScreen extends ConsumerStatefulWidget {
  const MedicalCalculatorScreen({super.key});

  @override
  ConsumerState<MedicalCalculatorScreen> createState() =>
      _MedicalCalculatorScreenState();
}

class _MedicalCalculatorScreenState extends ConsumerState<MedicalCalculatorScreen> {
  final TextEditingController _scoreSearchController = TextEditingController();

  @override
  void dispose() {
    _scoreSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final scoresAsync = ref.watch(filteredScoresProvider);
    final specialtiesAsync = ref.watch(scoreSpecialtiesProvider);
    final selectedSpecialty = ref.watch(scoreSpecialtyFilterProvider);
    final searchQuery = ref.watch(scoreSearchQueryProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          l10n.medicalCalculator,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isDark ? [] : [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6),
                  ],
                ),
                child: TextField(
                  controller: _scoreSearchController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un score ou calculateur...',
                    hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 14),
                    prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.primary, size: 20),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _scoreSearchController.clear();
                              ref.read(scoreSearchQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (value) =>
                      ref.read(scoreSearchQueryProvider.notifier).state = value,
                ),
              ),
            ),
          ),

          // Specialty filter chips
          SliverToBoxAdapter(
            child: specialtiesAsync.when(
              data: (specialties) => SizedBox(
                height: 46,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: specialties.length,
                  itemBuilder: (context, index) {
                    final sp = specialties[index];
                    final isSelected = selectedSpecialty == sp;
                    final color = sp == 'Tous' ? AppColors.primary : _specialtyColor(sp);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => ref.read(scoreSpecialtyFilterProvider.notifier).state = sp,
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? color : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? color : (isDark ? Colors.white12 : Colors.black.withOpacity(0.07)),
                              ),
                            ),
                            child: Text(
                              sp,
                              style: TextStyle(
                                color: isSelected ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              loading: () => const SizedBox(height: 46),
              error: (_, __) => const SizedBox(height: 46),
            ),
          ),

          // Scores & Calculators list
          scoresAsync.when(
            data: (scores) {
              if (scores.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.search_status, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "Aucun élément trouvé.",
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildScoreTile(scores[index], isDark),
                    childCount: scores.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(child: Text("Erreur de chargement: $err")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreTile(MedicalScore score, bool isDark) {
    final color = _specialtyColor(score.specialty);
    final icon = _specialtyIcon(score.specialty);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.12)),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MedicalScoreDetailScreen(score: score),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        score.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              score.specialty,
                              style: TextStyle(
                                color: color,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                           if (score.engine == CalculatorEngine.points ||
                              score.engine == CalculatorEngine.formula) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Iconsax.calculator, size: 9, color: Color(0xFF10B981)),
                                  const SizedBox(width: 3),
                                  Text(
                                    score.engine == CalculatorEngine.formula
                                        ? "Calcul"
                                        : "Interactif",
                                    style: const TextStyle(
                                      color: Color(0xFF10B981),
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Iconsax.arrow_right_3, size: 14, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _specialtyColor(String specialty) {
    final colors = [
      const Color(0xFF3B82F6), const Color(0xFFEF4444), const Color(0xFF10B981),
      const Color(0xFF8B5CF6), const Color(0xFFF59E0B), const Color(0xFF06B6D4),
      const Color(0xFFEC4899), const Color(0xFF6366F1), const Color(0xFF84CC16),
    ];
    return colors[specialty.hashCode.abs() % colors.length];
  }

  IconData _specialtyIcon(String specialty) {
    final lower = specialty.toLowerCase();
    if (lower.contains('cardio')) return Iconsax.heart;
    if (lower.contains('urgence') || lower.contains('urgenc')) return Iconsax.danger;
    if (lower.contains('neuro')) return Iconsax.activity;
    if (lower.contains('réa') || lower.contains('rea')) return Iconsax.flash_1;
    if (lower.contains('pédiat') || lower.contains('pediat')) return Iconsax.people;
    if (lower.contains('trauma')) return Iconsax.warning_2;
    if (lower.contains('pulmon') || lower.contains('pneumo')) return Iconsax.wind;
    if (lower.contains('gastro') || lower.contains('hepato')) return Iconsax.health;
    if (lower.contains('infect')) return Iconsax.microscope;
    return Iconsax.document;
  }
}
