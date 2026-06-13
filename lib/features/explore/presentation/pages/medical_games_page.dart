import 'package:meducyte_app/export.dart';

class MedicalGamesPage extends ConsumerStatefulWidget {
  const MedicalGamesPage({super.key});

  @override
  ConsumerState<MedicalGamesPage> createState() => _MedicalGamesPageState();
}

class _MedicalGamesPageState extends ConsumerState<MedicalGamesPage> {
  String _selectedCategory = "Tous";

  final List<Map<String, dynamic>> _gameData = [
    {
      "id": "1",
      "title": "Scrabble Médical",
      "category": "Vocabulary",
      "subtitle": "Rassemblez les lettres pour épeler les termes cliniques.",
      "icon": Iconsax.edit,
      "difficulty": "Facile",
      "xp": 100,
      "progress": "100%",
      "gradient": [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      "route": AppRoutes.medicalCrossword,
    },
    {
      "id": "2",
      "title": "Mots Mêlés",
      "category": "Vocabulary",
      "subtitle": "Repérez les termes cachés dans la grille.",
      "icon": Iconsax.search_status,
      "difficulty": "Facile",
      "xp": 100,
      "progress": "2/3 Réussi",
      "gradient": [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
      "route": AppRoutes.wordAssociation,
    },
    {
      "id": "3",
      "title": "Case Detective",
      "category": "Clinique",
      "subtitle": "Enquêtez, achetez des indices et diagnostiquez.",
      "icon": Iconsax.radar,
      "difficulty": "Difficile",
      "xp": 250,
      "progress": "Record: 85 pts",
      "gradient": [const Color(0xFF10B981), const Color(0xFF047857)],
      "route": AppRoutes.diagnosisMystery,
    },
    {
      "id": "4",
      "title": "Physiology Flow",
      "category": "Physio",
      "subtitle": "Reconstituez les cascades causales.",
      "icon": Iconsax.diagram,
      "difficulty": "Moyen",
      "xp": 150,
      "progress": "1/3 Résolu",
      "gradient": [const Color(0xFF06B6D4), const Color(0xFF0891B2)],
      "route": AppRoutes.labMaster,
    },
    {
      "id": "5",
      "title": "Pathology Spot",
      "category": "Imagerie",
      "subtitle": "Localisez les anomalies cliniques.",
      "icon": Iconsax.heart_tick,
      "difficulty": "Moyen",
      "xp": 150,
      "progress": "2/3 Trouvé",
      "gradient": [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
      "route": AppRoutes.ecgHero,
    },
    {
      "id": "6",
      "title": "Drug Duel",
      "category": "Pharma",
      "subtitle": "Sprint de flashcards contre le chrono.",
      "icon": Iconsax.award,
      "difficulty": "Difficile",
      "xp": 200,
      "progress": "Non tenté",
      "gradient": [const Color(0xFFF43F5E), const Color(0xFFBE123C)],
      "route": AppRoutes.pharmaMatch,
    },
    {
      "id": "7",
      "title": "Terminology Blitz",
      "category": "Vocabulary",
      "subtitle": "Déchiffrez l'étymologie médicale.",
      "icon": Iconsax.flash_1,
      "difficulty": "Facile",
      "xp": 100,
      "progress": "Record: 30 pts",
      "gradient": [const Color(0xFFEC4899), const Color(0xFFBE185D)],
      "route": AppRoutes.anatomyQuiz,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final user = ref.watch(authControllerProvider).value;
    final String displayName = (user?.name ?? "Étudiant Médical").toUpperCase();
    final String displaySubtitle = user != null
        ? "${user.specialty.isEmpty ? 'Étudiant' : user.specialty} • Niv. ${user.year}"
        : "Campus de Jeux";

    final filteredGames = _selectedCategory == "Tous"
        ? _gameData
        : _gameData.where((g) => g["category"] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top HUD Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(Iconsax.arrow_left_2),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            splashRadius: 20,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          const SizedBox(width: 12),
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.primary.withOpacity(0.15),
                            child: const Icon(Iconsax.user, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : Colors.black87,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  displaySubtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.amber.withOpacity(0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Iconsax.coin, color: Colors.amber, size: 14),
                              SizedBox(width: 4),
                              Text(
                                "350 G",
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Iconsax.flash, color: Colors.orange, size: 14),
                              SizedBox(width: 4),
                              Text(
                                "5 Jours",
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Featured Hero Card Carousel
            SliverToBoxAdapter(
              child: _buildFeaturedHero(context, isDark),
            ),

            // Category Horizontal Filters
            SliverToBoxAdapter(
              child: _buildCategoryFilters(isDark),
            ),

            // Games Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.74,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final game = filteredGames[index];
                    return _buildGameConsoleCard(context, game, isDark);
                  },
                  childCount: filteredGames.length,
                ),
              ),
            ),

            // Clinical Achievements Section
            SliverToBoxAdapter(
              child: _buildAchievementsSection(isDark),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedHero(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1D4ED8),
            Color(0xFF3B82F6),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Iconsax.radar5, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      "ÉVÉNEMENT DE LA SEMAINE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "DUEL PHARMA",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Relevez le défi de la semaine sur le co-transporteur Na+/K+/2Cl- et gagnez un boost de +150 XP !",
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12.5,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => context.push(AppRoutes.pharmaMatch),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  children: [
                    Icon(Iconsax.play5, size: 16),
                    SizedBox(width: 6),
                    Text("JOUER MAINTENANT", style: TextStyle(fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.info_circle, color: Colors.white, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(bool isDark) {
    final categories = ["Tous", "Vocabulary", "Clinique", "Physio", "Imagerie", "Pharma"];
    return Container(
      height: 42,
      margin: const EdgeInsets.only(top: 24, bottom: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: categories.length,
        itemBuilder: (context, idx) {
          final cat = categories[idx];
          final isSelected = cat == _selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedCategory = cat),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? const Color(0xFF1E293B) : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? Colors.white10 : Colors.grey.shade200),
                  ),
                ),
                child: Center(
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameConsoleCard(BuildContext context, Map<String, dynamic> game, bool isDark) {
    final List<Color> gradientColors = game["gradient"];
    final IconData icon = game["icon"];

    return GestureDetector(
      onTap: () => context.push(game["route"]),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.15 : 0.03),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    game["difficulty"].toString().toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 8,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              game["title"],
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14.5,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              game["subtitle"],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                height: 1.35,
              ),
            ),
            const Spacer(),
            Container(
              height: 1,
              color: isDark ? Colors.white10 : Colors.grey.shade200,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  game["progress"],
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade300 : Colors.black87,
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                  ),
                ),
                Text(
                  "+${game["xp"]} XP",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(bool isDark) {
    final achievements = [
      {"name": "Diagnosticien Pro", "icon": Iconsax.status_up, "desc": "10 diagnostics d'affilée sans faute.", "color": Colors.green},
      {"name": "Cardiologue Certifié", "icon": Iconsax.heart_tick, "desc": "100% de réussite sur Pathology Spot.", "color": Colors.blue},
      {"name": "Pharmacien d'élite", "icon": Iconsax.award, "desc": "Battre le chrono de Drug Duel en moins de 15s.", "color": Colors.amber},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 28, 24, 12),
          child: Text(
            "SUCCÈS D'APPRENTISSAGE",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: Colors.grey,
            ),
          ),
        ),
        Container(
          height: 110,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: achievements.length,
            itemBuilder: (context, idx) {
              final ach = achievements[idx];
              final Color color = ach["color"] as Color;

              return Container(
                width: 250,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(ach["icon"] as IconData, color: color, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ach["name"].toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            ach["desc"].toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
