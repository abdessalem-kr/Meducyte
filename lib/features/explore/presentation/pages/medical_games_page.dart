import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:meducyte_app/core/routes/routes.dart';
import 'package:meducyte_app/core/themes/app_colors.dart';

class MedicalGamesPage extends StatelessWidget {
  const MedicalGamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "STUDY GAMES",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    "Pratiquez vos connaissances",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -20,
                      child: Icon(
                        Iconsax.computing,
                        size: 200,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildListDelegate([
                _buildGameCard(
                  context,
                  title: "ANATOMIE",
                  desc: "Identification précise des structures.",
                  icon: Iconsax.mask,
                  color: Colors.orange,
                  players: "12k jouent",
                  onTap: () => context.push(AppRoutes.anatomyQuiz),
                ),
                _buildGameCard(
                  context,
                  title: "DIAGNOSTIC",
                  desc: "Analyse d'archives et de cas cliniques.",
                  icon: Iconsax.search_status,
                  color: Colors.blue,
                  players: "8k jouent",
                  onTap: () => context.push(AppRoutes.diagnosisMystery),
                ),
                _buildGameCard(
                  context,
                  title: "CHIRURGIE",
                  desc: "Simulation de gestes en bloc opératoire.",
                  icon: Iconsax.scissor,
                  color: Colors.red,
                  players: "5k jouent",
                  onTap: () => context.push(AppRoutes.surgicalSim),
                ),
                _buildGameCard(
                  context,
                  title: "PHARMACO",
                  desc: "Maîtrise des molécules et des classes.",
                  icon: Iconsax.glass,
                  color: Colors.green,
                  players: "15k jouent",
                  onTap: () => context.push(AppRoutes.pharmaMatch),
                ),
                _buildGameCard(
                  context,
                  title: "ECG MONITOR",
                  desc: "Interprétation rapide de tracés ECG.",
                  icon: Iconsax.heart,
                  color: Colors.pink,
                  players: "2k jouent",
                  onTap: () => context.push(AppRoutes.ecgHero),
                ),
                _buildGameCard(
                  context,
                  title: "MOTS CROISÉS",
                  desc: "Terminologie et lexique clinique.",
                  icon: Iconsax.edit,
                  color: Colors.deepPurple,
                  players: "9k jouent",
                  onTap: () => context.push(AppRoutes.medicalCrossword),
                ),
                _buildGameCard(
                  context,
                  title: "LOGIQUE",
                  desc: "Réseaux de concepts médicaux.",
                  icon: Iconsax.link,
                  color: Colors.indigo,
                  players: "7k jouent",
                  onTap: () => context.push(AppRoutes.wordAssociation),
                ),
                _buildGameCard(
                  context,
                  title: "LAB ANALYSE",
                  desc: "Analyse de bilans biologiques.",
                  icon: Iconsax.filter,
                  color: Colors.teal,
                  players: "4k jouent",
                  onTap: () => context.push(AppRoutes.labMaster),
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                "PLUS DE CONTENU EN PRÉPARATION...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required String players,
    bool isLocked = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLocked ? null : onTap,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withOpacity(0.2),
                            color.withOpacity(0.05),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    if (isLocked)
                      const Icon(Iconsax.lock, size: 16, color: Colors.grey)
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "ACTIF",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(Iconsax.user, size: 10, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      players,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
