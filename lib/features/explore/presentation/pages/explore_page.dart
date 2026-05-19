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
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            l10n.medicalWorld.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.exploreDescription,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              title: Text(
                l10n.navExplore,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
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
                ),
                const SizedBox(height: 12),
                _buildPremiumFeatureItem(
                  context,
                  title: l10n.medicalNews,
                  desc: l10n.medicalNewsDescription,
                  icon: Iconsax.info_circle,
                ),
                const SizedBox(height: 12),
                _buildPremiumFeatureItem(
                  context,
                  title: l10n.clinicalPearls,
                  desc: l10n.clinicalPearlsDescription,
                  icon: Iconsax.flash_1,
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch$url');
    }
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
