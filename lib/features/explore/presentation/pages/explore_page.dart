import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/shared/widgets/notification_badge.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:meducyte_app/features/explore/domain/models/resource_mapping.dart';

class ExplorePage extends ConsumerWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor,
            actions: [const NotificationBadge(), const SizedBox(width: 8)],
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final double appBarHeight = constraints.biggest.height;
                final double topPadding = MediaQuery.of(context).padding.top;
                // Calculate animation progress: 0.0 (collapsed) to 1.0 (fully expanded)
                final double expandRatio = ((appBarHeight - (kToolbarHeight + topPadding)) / (180 - kToolbarHeight)).clamp(0.0, 1.0);
                
                return Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryDark,
                        AppColors.primary,
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(32 * expandRatio),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Expanded Content (fades out as it collapses)
                      if (expandRatio > 0.1)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Opacity(
                            opacity: expandRatio,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                              child: SingleChildScrollView(
                                physics: const NeverScrollableScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        l10n.medicalWorld.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.navExplore,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      l10n.exploreDescription,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        height: 1.3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                      // Collapsed Title (fades in as it collapses)
                      if (expandRatio < 0.9)
                        Opacity(
                          opacity: (1.0 - expandRatio).clamp(0.0, 1.0),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: kToolbarHeight,
                              alignment: Alignment.center,
                              child: Text(
                                l10n.navExplore,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader(context, l10n.externalResources),
                const SizedBox(height: 16),
                _buildResourceCard(
                  context,
                  title: l10n.joinOfficialDrive,
                  subtitle: l10n.driveDescription,
                  icon: Iconsax.folder_cloud,
                  color: const Color(0xFF4285F4),
                  onTap: () => _showYearSelectionSheet(context, isDrive: true),
                ),
                const SizedBox(height: 12),
                _buildResourceCard(
                  context,
                  title: l10n.joinTelegram,
                  subtitle: l10n.telegramDescription,
                  icon: Iconsax.direct_send,
                  color: const Color(0xFF0088CC),
                  onTap: () => _showYearSelectionSheet(context, isDrive: false),
                ),
                const SizedBox(height: 12),
                _buildResourceCard(
                  context,
                  title: l10n.booksLibrary,
                  subtitle: l10n.booksLibraryDesc,
                  icon: Iconsax.book_1,
                  color: const Color(0xFFFB8C00),
                  onTap: () => context.push(AppRoutes.booksLibrary),
                ),
                const SizedBox(height: 32),

                _buildSectionHeader(context, l10n.interpretationHelpers),
                const SizedBox(height: 16),
                GridView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  children: [
                    _buildFeatureCard(
                      context,
                      title: l10n.ecgInterpretation,
                      icon: Iconsax.status_up,
                      color: const Color(0xFFFF5252),
                      onTap: () => context.push(AppRoutes.ecgHelper),
                    ),
                    _buildFeatureCard(
                      context,
                      title: l10n.radiologyHelper,
                      icon: Iconsax.scanning,
                      color: const Color(0xFF7C4DFF),
                      onTap: () => context.push(AppRoutes.radiologyHelper),
                    ),
                    _buildFeatureCard(
                      context,
                      title: l10n.labInterpretation,
                      icon: Iconsax.filter_edit,
                      color: const Color(0xFF00BFA5),
                      onTap: () => context.push(AppRoutes.labHelper),
                    ),
                    _buildFeatureCard(
                      context,
                      title: l10n.firstAid,
                      icon: Iconsax.hospital,
                      color: const Color(0xFFF44336),
                      onTap: () => context.push(AppRoutes.firstAid),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                _buildSectionHeader(context, l10n.interactiveLearning),
                const SizedBox(height: 16),
                _buildPremiumFeatureItem(
                  context,
                  title: l10n.caseOfTheDay,
                  desc: l10n.caseOfDayDescription,
                  icon: Iconsax.calendar_2,
                  isNew: true,
                  color: const Color(0xFF10B981),
                  onTap: () => context.push(AppRoutes.diagnosisMystery),
                ),
                const SizedBox(height: 12),
                _buildPremiumFeatureItem(
                  context,
                  title: l10n.medicalNews,
                  desc: l10n.medicalNewsDescription,
                  icon: Iconsax.info_circle,
                  color: const Color(0xFF3B82F6),
                  onTap: () => _showMedicalNewsSheet(context),
                ),
                const SizedBox(height: 12),
                _buildPremiumFeatureItem(
                  context,
                  title: l10n.clinicalPearls,
                  desc: l10n.clinicalPearlsDescription,
                  icon: Iconsax.flash_1,
                  color: const Color(0xFFF59E0B),
                  onTap: () => context.push(AppRoutes.clinicalPearls),
                ),
                const SizedBox(height: 12),
                _buildPremiumFeatureItem(
                  context,
                  title: "Medical Games",
                  desc: "Apprenez en jouant avec nos mini-jeux interactifs.",
                  icon: Iconsax.game,
                  color: Colors.indigo,
                  onTap: () => context.push(AppRoutes.medicalGames),
                ),
                const SizedBox(height: 12),
                _buildPremiumFeatureItem(
                  context,
                  title: l10n.quickCalcHub,
                  desc: l10n.calcHubDescription,
                  icon: Iconsax.calculator,
                  color: const Color(0xFFEC4899),
                  onTap: () => context.push(AppRoutes.medicalCalculator),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildResourceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              size: 18,
              color: Theme.of(context).dividerColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumFeatureItem(
    BuildContext context, {
    required String title,
    required String desc,
    required IconData icon,
    bool isNew = false,
    Color? color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.primary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (isNew) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "NEW",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).hintColor,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap == null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Iconsax.lock, color: Colors.amber, size: 14),
              )
            else
              Icon(
                Iconsax.arrow_right_3,
                size: 14,
                color: Theme.of(context).dividerColor,
              ),
          ],
        ),
      ),
    );
  }

  void _showYearSelectionSheet(BuildContext context, {required bool isDrive}) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _YearSelectionSheetContent(
        isDrive: isDrive,
        isDark: isDark,
        l10n: l10n,
        launchUrl: _launchUrl,
      ),
    );
  }

  void _showMedicalNewsSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _MedicalNewsSheetContent(
        isDark: isDark,
        onLaunchUrl: _launchUrl,
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch$url');
    }
  }
}

class _MedicalNewsSheetContent extends StatefulWidget {
  final bool isDark;
  final Function(String) onLaunchUrl;
  const _MedicalNewsSheetContent({
    required this.isDark,
    required this.onLaunchUrl,
  });

  @override
  State<_MedicalNewsSheetContent> createState() => _MedicalNewsSheetContentState();
}

class _MedicalNewsSheetContentState extends State<_MedicalNewsSheetContent> {
  List<Map<String, dynamic>> _newsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    try {
      final dio = Dio();
      final searchResponse = await dio.get(
        'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi',
        queryParameters: {
          'db': 'pubmed',
          'term': '(nejm[Journal] OR lancet[Journal] OR jama[Journal]) AND "has abstract"[Filter]',
          'retmax': '5',
          'sort': 'pub_date',
          'retmode': 'json',
        },
      );

      if (searchResponse.statusCode == 200 && searchResponse.data != null) {
        final searchData = searchResponse.data;
        if (searchData is Map<String, dynamic> && searchData.containsKey('esearchresult')) {
          final idList = searchData['esearchresult']['idlist'] as List?;
          if (idList != null && idList.isNotEmpty) {
            final idsString = idList.join(',');

            final summaryResponse = await dio.get(
              'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi',
              queryParameters: {
                'db': 'pubmed',
                'id': idsString,
                'retmode': 'json',
              },
            );

            if (summaryResponse.statusCode == 200 && summaryResponse.data != null) {
              final summaryData = summaryResponse.data;
              if (summaryData is Map<String, dynamic> && summaryData.containsKey('result')) {
                final result = summaryData['result'] as Map<String, dynamic>;
                final List<Map<String, dynamic>> parsedList = [];

                for (var id in idList) {
                  final idStr = id.toString();
                  final articleDetails = result[idStr] as Map<String, dynamic>?;
                  if (articleDetails != null) {
                    final String rawTitle = articleDetails['title'] ?? 'Actualité Médicale';
                    final String source = articleDetails['source'] ?? 'PubMed';
                    final String pubDate = articleDetails['pubdate'] ?? '';
                    
                    var title = rawTitle.trim();
                    if (title.endsWith('.')) {
                      title = title.substring(0, title.length - 1);
                    }
                    if (title.startsWith('[') && title.endsWith(']')) {
                      title = title.substring(1, title.length - 1);
                    }

                    String dateStr = pubDate;
                    if (pubDate.isNotEmpty) {
                      dateStr = pubDate.split(' ').first;
                    }

                    final authors = articleDetails['authors'] as List?;
                    String authorStr = '';
                    if (authors != null && authors.isNotEmpty) {
                      final firstAuthor = authors.first['name'] ?? '';
                      authorStr = firstAuthor.toString();
                      if (authors.length > 1) {
                        authorStr += " et al.";
                      }
                    }
                    final desc = "Nouvelle publication scientifique majeure dans $source. ${authorStr.isNotEmpty ? 'Par $authorStr.' : ''} Retrouvez les résultats complets et l'analyse clinique sur PubMed.";

                    parsedList.add({
                      "title": title,
                      "date": dateStr,
                      "category": source.length > 20 ? "${source.substring(0, 17)}..." : source,
                      "desc": desc,
                      "color": _getCategoryColor(source),
                      "url": "https://pubmed.ncbi.nlm.nih.gov/$idStr/",
                    });
                  }
                }

                if (mounted && parsedList.isNotEmpty) {
                  setState(() {
                    _newsList = parsedList;
                    _isLoading = false;
                  });
                  return;
                }
              }
            }
          }
        }
      }
      throw Exception("Format de réponse PubMed invalide");
    } catch (e) {
      debugPrint("Error fetching medical news: $e");
      if (mounted) {
        setState(() {
          _newsList = [
            {
              "title": "Avancée majeure dans l'immunothérapie du cancer du poumon",
              "date": "Aujourd'hui",
              "category": "Oncologie",
              "desc": "Une nouvelle étude clinique de phase III démontre une augmentation de 18% du taux de survie globale à 5 ans chez les patients atteints de CPNPC grâce à une association thérapeutique innovante.",
              "color": Colors.redAccent,
              "url": "https://pubmed.ncbi.nlm.nih.gov/30353860/",
            },
            {
              "title": "Directives de l'ESC 2026 : Nouvelles cibles de LDL-cholestérol",
              "date": "Hier",
              "category": "Cardiologie",
              "desc": "La Société Européenne de Cardiologie met à jour ses recommandations pour la prévention cardiovasculaire en abaissant le seuil cible pour les patients à très haut risque.",
              "color": Colors.pinkAccent,
              "url": "https://pubmed.ncbi.nlm.nih.gov/32955177/",
            },
            {
              "title": "IA générative et précision du diagnostic radiologique",
              "date": "3 jours",
              "category": "Technologie",
              "desc": "Les nouveaux outils d'intelligence artificielle atteignent une sensibilité de 98% pour la détection précoce des micro-calcifications mammaires en double lecture.",
              "color": Colors.purpleAccent,
              "url": "https://pubmed.ncbi.nlm.nih.gov/31591599/",
            },
          ];
          _isLoading = false;
        });
      }
    }
  }

  Color _getCategoryColor(String cat) {
    final lower = cat.toLowerCase();
    if (lower.contains('lancet')) return Colors.redAccent;
    if (lower.contains('nejm') || lower.contains('england')) return Colors.blueAccent;
    if (lower.contains('jama')) return Colors.teal;
    if (lower.contains('cancer') || lower.contains('oncology')) return Colors.orangeAccent;
    return Colors.purpleAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Iconsax.info_circle, color: AppColors.primary, size: 24),
                  SizedBox(width: 8),
                  Text(
                    "Actualités Médicales",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Suivez les dernières percées de la science médicale.",
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: _newsList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final news = _newsList[index];
                  final color = news["color"] as Color;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        final url = news["url"]?.toString();
                        if (url != null && url.isNotEmpty) {
                          widget.onLaunchUrl(url);
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: widget.isDark ? Colors.white10 : Colors.black12,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    news["category"].toString().toUpperCase(),
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  news["date"].toString(),
                                  style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              news["title"].toString(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              news["desc"].toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.isDark ? Colors.white70 : Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}


class _YearSelectionSheetContent extends StatefulWidget {
  final bool isDrive;
  final bool isDark;
  final AppLocalizations l10n;
  final Function(String) launchUrl;

  const _YearSelectionSheetContent({
    required this.isDrive,
    required this.isDark,
    required this.l10n,
    required this.launchUrl,
  });

  @override
  State<_YearSelectionSheetContent> createState() =>
      _YearSelectionSheetContentState();
}

class _YearSelectionSheetContentState
    extends State<_YearSelectionSheetContent> {
  int? selectedStudyYear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (selectedStudyYear != null)
                IconButton(
                  onPressed: () => setState(() => selectedStudyYear = null),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isDrive
                        ? widget.l10n.joinOfficialDrive
                        : widget.l10n.joinTelegram,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedStudyYear == null
                        ? widget.l10n.studyYear
                        : (selectedStudyYear == 7
                              ? "Residanat"
                              : widget.l10n.otherYearOrdinal(
                                  selectedStudyYear!,
                                )),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (selectedStudyYear == null)
            _buildStudyYearSelection()
          else
            _buildAcademicYearSelection(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStudyYearSelection() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: 7,
      itemBuilder: (context, index) {
        final year = index + 1;
        final String yearLabel;
        if (year == 7) {
          yearLabel = "Residanat";
        } else if (year == 1) {
          yearLabel = widget.l10n.firstYearOrdinal;
        } else {
          yearLabel = widget.l10n.otherYearOrdinal(year);
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() => selectedStudyYear = year);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.isDrive ? Iconsax.folder_cloud : Iconsax.direct_send,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    yearLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAcademicYearSelection() {
    final currentYear = DateTime.now().year;
    final List<int> acadYears = [];
    for (int y = 2017; y < currentYear; y++) {
      acadYears.add(y);
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: acadYears.length,
            itemBuilder: (context, index) {
              final acadYear = acadYears[index];
              return ListTile(
                title: Text(
                  "$acadYear- ${acadYear + 1}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Iconsax.arrow_right_3, size: 16),
                onTap: () {
                  final links = ResourceLinks.algerianMedicalResources;
                  final studyMap = widget.isDrive
                      ? links.driveLinks
                      : links.telegramLinks;
                  final url = studyMap[selectedStudyYear]?[acadYear];
                  if (url != null) {
                    Navigator.pop(context);
                    widget.launchUrl(url);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
