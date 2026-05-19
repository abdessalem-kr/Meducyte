import 'package:meducyte_app/export.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/models/lab_mapping.dart';
import '../../../explore/domain/models/lab_encyclopedia_data.dart';

class LabHelperScreen extends StatefulWidget {
  const LabHelperScreen({super.key});

  @override
  State<LabHelperScreen> createState() => _LabHelperScreenState();
}

class _LabHelperScreenState extends State<LabHelperScreen> {
  final Set<String> _selectedFindings = {};
  final Map<String, bool?> _checklistState = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(isDark, primaryColor, l10n, context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTechnicalQualityCheck(isDark, primaryColor, l10n),
                  const SizedBox(height: 32),
                  _buildGuidedInterpretations(isDark, primaryColor, l10n),
                  if (_selectedFindings.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildSyndromeProbability(isDark, primaryColor, l10n),
                    _buildDifferentialDiagnosis(isDark, primaryColor, l10n),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _generateReport,
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text('Générer Rapport Interpretatif'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  _buildReferenceResources(isDark, primaryColor, l10n, context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
    bool isDark,
    Color primaryColor,
    AppLocalizations l10n,
    BuildContext context,
  ) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      stretch: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: isDark ? Colors.white : Colors.black,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.picture_as_pdf_outlined, color: primaryColor),
          tooltip: 'Générer Rapport',
          onPressed: _generateReport,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.labInterpretation,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              l10n.labAnalysisReport,
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 10,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        background: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                Icons.biotech_outlined,
                size: 160,
                color: primaryColor.withOpacity(0.05),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidedInterpretations(
    bool isDark,
    Color primaryColor,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.labGuidedInterpretation,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              if (_selectedFindings.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => _selectedFindings.clear()),
                  child: Text(
                    l10n.labResetFindings,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _buildExpansionCard(
            l10n.labChapterHematology,
            Icons.water_drop_outlined,
            _buildCategoryFindings(
              LabCategory.hematology,
              isDark,
              primaryColor,
              l10n,
            ),
            isDark,
            primaryColor,
            tipTitle: l10n.labTipHematologyTitle,
            tipDesc: l10n.labTipHematologyDesc,
          ),
          _buildExpansionCard(
            l10n.labChapterElectrolytes,
            Icons.electric_bolt_outlined,
            _buildCategoryFindings(
              LabCategory.electrolytes,
              isDark,
              primaryColor,
              l10n,
            ),
            isDark,
            primaryColor,
            tipTitle: l10n.labTipElectrolytesTitle,
            tipDesc: l10n.labTipElectrolytesDesc,
          ),
          _buildExpansionCard(
            l10n.labChapterGasometry,
            Icons.air_outlined,
            _buildCategoryFindings(
              LabCategory.gasometry,
              isDark,
              primaryColor,
              l10n,
            ),
            isDark,
            primaryColor,
            tipTitle: l10n.labTipGasometryTitle,
            tipDesc: l10n.labTipGasometryDesc,
          ),
          _buildExpansionCard(
            l10n.labChapterHepatorenal,
            Icons.monitor_heart_outlined,
            _buildCategoryFindings(
              LabCategory.hepatorenal,
              isDark,
              primaryColor,
              l10n,
            ),
            isDark,
            primaryColor,
            tipTitle: l10n.labTipInflammatoryTitle,
            tipDesc: l10n.labTipInflammatoryDesc,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryFindings(
    LabCategory category,
    bool isDark,
    Color primaryColor,
    AppLocalizations l10n,
  ) {
    return LabMapping.findings
        .where((f) => f.category == category)
        .map((finding) => _findingItem(finding, isDark, primaryColor, l10n))
        .toList();
  }

  Widget _findingItem(
    LabFinding finding,
    bool isDark,
    Color primaryColor,
    AppLocalizations l10n,
  ) {
    final isSelected = _selectedFindings.contains(finding.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedFindings.remove(finding.id);
            } else {
              _selectedFindings.add(finding.id);
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withOpacity(0.05)
                : (isDark
                      ? Colors.white.withOpacity(0.03)
                      : Colors.grey.shade50),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? primaryColor.withOpacity(0.2)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            finding.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isSelected
                                  ? primaryColor
                                  : (isDark ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                        if (finding.fullDescription != null ||
                            finding.encyclopediaId != null) ...[
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _showFindingDetail(finding),
                            child: Icon(
                              Icons.menu_book_outlined,
                              size: 14,
                              color: primaryColor.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      finding.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    Text(
                      'VN: ${finding.normalRange}',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? primaryColor : Colors.grey.withOpacity(0.3),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEncyclopediaEntry(
    String encyclopediaId,
    String findingName,
    AppLocalizations l10n,
  ) async {
    final entries = await LabEncyclopediaData.loadEntries();

    //First try exact ID match
    var entry = entries.where((e) => e.id == encyclopediaId).firstOrNull;

    //Fallback to fuzzy match
    entry ??= entries.where((e) {
      return e.id.toLowerCase().contains(encyclopediaId.toLowerCase()) ||
          e.name.toLowerCase().contains(encyclopediaId.toLowerCase());
    }).firstOrNull;

    if (!mounted) return;

    if (entry != null) {
      context.push('${AppRoutes.labEncyclopedia}/${entry.id}', extra: entry);
    } else {
      //Fallback:open encyclopedia search
      context.push(AppRoutes.labEncyclopedia);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Détails pour'$findingName'non trouvés"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildExpansionCard(
    String title,
    IconData icon,
    List<Widget> children,
    bool isDark,
    Color primaryColor, {
    String? tipTitle,
    String? tipDesc,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryColor, size: 18),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          shape: const RoundedRectangleBorder(),
          collapsedShape: const RoundedRectangleBorder(),
          children: [
            if (tipTitle != null && tipDesc != null)
              _buildEducationalTip(tipTitle, tipDesc, isDark, primaryColor),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: Column(children: children),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationalTip(
    String title,
    String desc,
    bool isDark,
    Color primaryColor,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryColor.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: primaryColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyndromeProbability(
    bool isDark,
    Color primaryColor,
    AppLocalizations l10n,
  ) {
    final Map<LabSyndrome, int> scores = {};
    for (final findingId in _selectedFindings) {
      final finding = LabMapping.findings.firstWhere((f) => f.id == findingId);
      for (final syndrome in finding.relatedSyndromes) {
        scores[syndrome] = (scores[syndrome] ?? 0) + 1;
      }
    }

    final Map<LabSyndrome, int> syndromeTotals = {};
    for (final s in LabSyndrome.values) {
      syndromeTotals[s] = LabMapping.findings
          .where((f) => f.relatedSyndromes.contains(s))
          .length;
    }

    final sortedSyndromes = scores.keys.toList()
      ..sort((a, b) => scores[b]!.compareTo(scores[a]!));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.labSyndromeProbability,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedSyndromes.map((syndrome) {
            final score = scores[syndrome]!;
            final total = syndromeTotals[syndrome]!;
            final percentage = (score / total).clamp(0.0, 1.0);
            final label = _getSyndromeLabel(syndrome, l10n);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  final info = LabMapping.syndromeInfo
                      .where((i) => i.syndrome == syndrome)
                      .firstOrNull;
                  if (info != null) {
                    _showSyndromeDetail(info, isDark, primaryColor, l10n);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: percentage > 0.5
                          ? primaryColor.withOpacity(0.3)
                          : (isDark
                                ? Colors.white10
                                : Colors.black.withOpacity(0.05)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$score/$total signes',
                            style: TextStyle(
                              fontSize: 11,
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.05),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            percentage > 0.7
                                ? Colors.green
                                : (percentage > 0.4
                                      ? primaryColor
                                      : Colors.orange),
                          ),
                          minHeight: 5,
                        ),
                      ),
                      if (percentage > 0) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedFindings
                              .map(
                                (fid) => LabMapping.findings.firstWhere(
                                  (f) => f.id == fid,
                                ),
                              )
                              .where(
                                (f) =>
                                    f.relatedSyndromes.contains(syndrome) &&
                                    f.encyclopediaId != null,
                              )
                              .map(
                                (f) => InkWell(
                                  onTap: () => _showEncyclopediaEntry(
                                    f.encyclopediaId!,
                                    f.name,
                                    l10n,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: primaryColor.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.menu_book_outlined,
                                          size: 10,
                                          color: primaryColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          f.name,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: primaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTechnicalQualityCheck(
    bool isDark,
    Color primaryColor,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
            blurRadius: 20,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.fact_check_outlined,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Vérification Pré-analitique',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...LabMapping.technicalCriteria.map((criteria) {
            return _checkItem(
              criteria.id,
              criteria.name,
              criteria.description,
              isDark,
              primaryColor,
            );
          }),
        ],
      ),
    );
  }

  Widget _checkItem(
    String id,
    String title,
    String subtitle,
    bool isDark,
    Color primaryColor,
  ) {
    final status = _checklistState[id];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            if (status == null) {
              _checklistState[id] = true;
            } else if (status == true) {
              _checklistState[id] = false;
            } else {
              _checklistState.remove(id);
            }
          });
        },
        child: Row(
          children: [
            Icon(
              status == true
                  ? Icons.check_circle
                  : (status == false ? Icons.cancel : Icons.circle_outlined),
              color: status == true
                  ? Colors.green
                  : (status == false
                        ? Colors.red
                        : Colors.grey.withOpacity(0.3)),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFindingDetail(LabFinding finding) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      finding.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      finding.fullDescription ?? finding.description,
                      style: const TextStyle(fontSize: 16, height: 1.6),
                    ),
                    if (finding.etiologies != null &&
                        finding.etiologies!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        l10n.labCommonEtiologies,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: finding.etiologies!
                            .map(
                              (e) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  e,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 32),
                    if (finding.encyclopediaId != null) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showEncyclopediaEntry(
                              finding.encyclopediaId!,
                              finding.name,
                              l10n,
                            );
                          },
                          icon: const Icon(Icons.menu_book_outlined),
                          label: Text(l10n.viewInEncyclopedia),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    Text(
                      l10n.labRelatedSyndromes,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: finding.relatedSyndromes.map((s) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getSyndromeLabel(s, l10n),
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSyndromeDetail(
    LabSyndromeInfo info,
    bool isDark,
    Color primaryColor,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      info.definition,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader(
                      'Signes Biologiques',
                      Icons.visibility,
                      primaryColor,
                    ),
                    const SizedBox(height: 12),
                    ...info.signs.map((s) => _buildBulletPoint(s, isDark)),
                    const SizedBox(height: 32),
                    _buildSectionHeader(
                      l10n.labCommonEtiologies,
                      Icons.category,
                      primaryColor,
                    ),
                    const SizedBox(height: 12),
                    ...info.etiologies.map((e) => _buildBulletPoint(e, isDark)),
                    if (info.clinicalPearls != null) ...[
                      const SizedBox(height: 32),
                      _buildSectionHeader(
                        'Perles Cliniques',
                        Icons.lightbulb_outline,
                        Colors.amber,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          info.clinicalPearls!,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSyndromeLabel(LabSyndrome syndrome, AppLocalizations l10n) {
    switch (syndrome) {
      case LabSyndrome.inflammatory:
        return l10n.labSyndromeInflammatory;
      case LabSyndrome.anemia:
        return l10n.labSyndromeAnemia;
      case LabSyndrome.thrombopenia:
        return l10n.labSyndromeThrombopenia;
      case LabSyndrome.hyperkalemia:
        return l10n.labSyndromeHyperkalemia;
      case LabSyndrome.hypokalemia:
        return l10n.labSyndromeHypokalemia;
      case LabSyndrome.acuteRenalFailure:
        return l10n.labSyndromeIRA;
      case LabSyndrome.metabolicAcidosis:
        return l10n.labSyndromeAcidosis;
      case LabSyndrome.dehydration:
        return l10n.labSyndromeDehydration;
      case LabSyndrome.cholestasis:
        return l10n.labSyndromeCholestasis;
      case LabSyndrome.liverCytolysis:
        return l10n.labSyndromeCytolysis;
    }
  }

  Widget _buildDifferentialDiagnosis(
    bool isDark,
    Color primaryColor,
    AppLocalizations l10n,
  ) {
    final activeDiffs = LabMapping.differentials.where((diff) {
      return diff.triggerFindingIds.every(
        (id) => _selectedFindings.contains(id),
      );
    }).toList();

    if (activeDiffs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Row(
            children: [
              Icon(Icons.compare_arrows, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Diagnostics Différentiels',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
        ...activeDiffs.map((diff) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(isDark ? 0.1 : 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  diff.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  diff.logic,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Future<void> _generateReport() async {
    final doc = pw.Document();

    final selectedFindingsObjects = _selectedFindings
        .map((id) => LabMapping.findings.firstWhere((f) => f.id == id))
        .toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Aide Bio-Rapport Interpretatif',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  pw.Text(DateTime.now().toString().split(' ')[0]),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Anomalies détectées:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Bullet(
              text: selectedFindingsObjects.map((f) => f.name).join(', '),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Analyse Syndromique:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            //Simplified for now
            ...selectedFindingsObjects.map(
              (f) => pw.Text('- ${f.name} : ${f.description}'),
            ),
            pw.SizedBox(height: 30),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text(
              'Note:Ce rapport est généré àtitre indicatif et ne remplace pas une expertise médicale.',
              style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  Widget _buildReferenceResources(
    bool isDark,
    Color primaryColor,
    AppLocalizations l10n,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'RESSOURCES&RÉFÉRENCES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildResourceCard(
                    title: 'Valeurs Normales',
                    subtitle: 'SI&Trad.',
                    icon: Icons.table_chart_outlined,
                    color: const Color(0xFFF9A825),
                    isDark: isDark,
                    onTap: () => context.push(AppRoutes.labNormalValues),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildResourceCard(
                    title: l10n.labEncyclopedia,
                    subtitle: '250+Examens',
                    icon: Icons.library_books_outlined,
                    color: const Color(0xFF0091EA),
                    isDark: isDark,
                    onTap: () => context.push(AppRoutes.labEncyclopedia),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResourceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
          ),
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? Colors.white.withOpacity(0.3)
                    : Colors.black.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
