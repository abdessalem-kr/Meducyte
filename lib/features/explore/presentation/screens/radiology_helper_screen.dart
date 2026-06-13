import 'package:meducyte_app/export.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../domain/models/radiology_mapping.dart';

class RadiologyHelperScreen extends StatefulWidget {
  const RadiologyHelperScreen({super.key});
  @override
  State<RadiologyHelperScreen> createState() => _RadiologyHelperScreenState();
}

class _RadiologyHelperScreenState extends State<RadiologyHelperScreen> {
  //Checklist State
  final Map<String, bool?> _checklistState = {};
  final Set<String> _selectedFindings = {};
  //Radiology Image Source
  Uint8List? _radImageBytes;
  final ImagePicker _picker = ImagePicker();
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _radImageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _showDrawingDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Uint8List? resultBytes = await showDialog<Uint8List>(
      context: context,
      builder: (context) => _RadDrawingDialog(isDark: isDark),
    );
    if (resultBytes != null) {
      setState(() {
        _radImageBytes = resultBytes;
      });
    }
  }

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
          _buildAppBar(isDark, primaryColor, l10n),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSourceSelector(isDark, primaryColor, l10n),
                  if (_radImageBytes != null) _buildImagePreview(isDark, l10n),
                  _buildGuidedInterpretations(isDark, primaryColor, l10n),
                  _buildSyndromesReference(isDark, primaryColor, l10n),
                  const SizedBox(height: 32),
                  _buildActionButtons(isDark, primaryColor, l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark, Color primaryColor, AppLocalizations l10n) {
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
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.radiologyHelper,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              l10n.radAnalysisReport,
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
                Icons.settings_overscan,
                size: 160,
                color: primaryColor.withOpacity(0.05),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceSelector(
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
                child: Icon(Icons.image_search, color: primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.radSourceTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _sourceButton(
                Icons.camera_alt_outlined,
                l10n.radSourceCamera,
                () => _pickImage(ImageSource.camera),
                isDark,
                primaryColor,
              ),
              const SizedBox(width: 12),
              _sourceButton(
                Icons.photo_library_outlined,
                l10n.radSourceGallery,
                () => _pickImage(ImageSource.gallery),
                isDark,
                primaryColor,
              ),
              const SizedBox(width: 12),
              _sourceButton(
                Icons.edit_outlined,
                l10n.radSourceDraw,
                _showDrawingDialog,
                isDark,
                primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sourceButton(
    IconData icon,
    String label,
    VoidCallback onTap,
    bool isDark,
    Color primaryColor,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isDark ? Colors.white70 : Colors.black87,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, top: 16),
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: MemoryImage(_radImageBytes!),
          fit: BoxFit.contain,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => setState(() => _radImageBytes = null),
              style: IconButton.styleFrom(backgroundColor: Colors.black45),
            ),
          ),
        ],
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
          _buildTechnicalQualityCheck(isDark, primaryColor, l10n),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.radGuidedInterpretation,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              if (_selectedFindings.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => _selectedFindings.clear()),
                  child: Text(
                    l10n.radResetFindings,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _buildExpansionCard(
            l10n.radChapterAirway,
            Icons.air,
            [
              _checkItem(
                "airway_trachea",
                l10n.radCheckTracheaCentral,
                l10n.radCheckTracheaCentralDesc,
                isDark,
                primaryColor,
              ),
              ..._buildCategoryFindings(
                RadiologyCategory.A,
                isDark,
                primaryColor,
              ),
            ],
            isDark,
            primaryColor,
            tipTitle: l10n.radTipAirwayTitle,
            tipDesc: l10n.radTipAirwayDesc,
          ),
          _buildExpansionCard(
            l10n.radChapterBreathing,
            Icons.speed,
            [
              _checkItem(
                "breathing_expansion",
                l10n.radCheckLungsExpanded,
                l10n.radCheckLungsExpandedDesc,
                isDark,
                primaryColor,
              ),
              _checkItem(
                "breathing_angles",
                l10n.radCheckCostophrenicAngles,
                l10n.radCheckCostophrenicAnglesDesc,
                isDark,
                primaryColor,
              ),
              ..._buildCategoryFindings(
                RadiologyCategory.B,
                isDark,
                primaryColor,
              ),
            ],
            isDark,
            primaryColor,
            tipTitle: l10n.radTipBreathingTitle,
            tipDesc: l10n.radTipBreathingDesc,
          ),
          _buildExpansionCard(
            l10n.radChapterCirculation,
            Icons.favorite_outline,
            [
              _checkItem(
                "circulation_heart_size",
                l10n.radCheckHeartSize,
                l10n.radCheckHeartSizeDesc,
                isDark,
                primaryColor,
              ),
              ..._buildCategoryFindings(
                RadiologyCategory.C,
                isDark,
                primaryColor,
              ),
            ],
            isDark,
            primaryColor,
            tipTitle: l10n.radTipCirculationTitle,
            tipDesc: l10n.radTipCirculationDesc,
          ),
          _buildExpansionCard(
            l10n.radChapterDiaphragm,
            Icons.horizontal_rule,
            [
              _checkItem(
                "diaphragm_position",
                l10n.radCheckDiaphragmPosition,
                l10n.radCheckDiaphragmPositionDesc,
                isDark,
                primaryColor,
              ),
              ..._buildCategoryFindings(
                RadiologyCategory.D,
                isDark,
                primaryColor,
              ),
            ],
            isDark,
            primaryColor,
            tipTitle: l10n.radTipDiaphragmTitle,
            tipDesc: l10n.radTipDiaphragmDesc,
          ),
          _buildExpansionCard(
            l10n.radChapterEverythingElse,
            Icons.more_horiz,
            [
              _checkItem(
                "everything_bones",
                l10n.radCheckBonesSoftTissues,
                l10n.radCheckBonesSoftTissuesDesc,
                isDark,
                primaryColor,
              ),
              ..._buildCategoryFindings(
                RadiologyCategory.E,
                isDark,
                primaryColor,
              ),
            ],
            isDark,
            primaryColor,
            tipTitle: l10n.radTipEverythingElseTitle,
            tipDesc: l10n.radTipEverythingElseDesc,
          ),
          if (_selectedFindings.isNotEmpty) ...[
            _buildDifferentialDiagnosis(isDark, primaryColor, l10n),
            const SizedBox(height: 32),
            Text(
              l10n.radSyndromeProbabilityAnalysis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildSuggestedSyndromesList(isDark, primaryColor, l10n),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildCategoryFindings(
    RadiologyCategory category,
    bool isDark,
    Color primaryColor,
  ) {
    return RadiologyMapping.findings
        .where((f) => f.category == category)
        .map((finding) => _findingItem(finding, isDark, primaryColor))
        .toList();
  }

  void _showFindingDetail(RadiologyFinding finding) {
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
                        l10n.radCommonEtiologies,
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
                    if (finding.imagePath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark
                                  ? Colors.white10
                                  : Colors.black.withOpacity(0.05),
                            ),
                          ),
                          child: Image.asset(
                            finding.imagePath!,
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    const SizedBox(height: 32),
                    Text(
                      l10n.radRelatedSyndromes,
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
                            _getSyndromeLabel(s, AppLocalizations.of(context)!),
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

  Widget _findingItem(
    RadiologyFinding finding,
    bool isDark,
    Color primaryColor,
  ) {
    final isSelected = _selectedFindings.contains(finding.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
          padding: const EdgeInsets.all(12),
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
              IconButton(
                onPressed: () => _showFindingDetail(finding),
                icon: Icon(
                  Icons.info_outline,
                  size: 20,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      finding.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isSelected
                            ? primaryColor
                            : (isDark ? Colors.white : Colors.black),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      finding.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
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

  Widget _buildSuggestedSyndromesList(
    bool isDark,
    Color primaryColor,
    AppLocalizations l10n,
  ) {
    final Map<RadiologySyndrome, int> scores = {};
    for (final findingId in _selectedFindings) {
      final finding = RadiologyMapping.findings.firstWhere(
        (f) => f.id == findingId,
      );
      for (final syndrome in finding.relatedSyndromes) {
        scores[syndrome] = (scores[syndrome] ?? 0) + 1;
      }
    }
    //Map scores to syndromes with counts
    final syndromeCounts = {
      RadiologySyndrome.alveolar: RadiologyMapping.findings
          .where((f) => f.relatedSyndromes.contains(RadiologySyndrome.alveolar))
          .length,
      RadiologySyndrome.interstitial: RadiologyMapping.findings
          .where(
            (f) => f.relatedSyndromes.contains(RadiologySyndrome.interstitial),
          )
          .length,
      RadiologySyndrome.bronchial: RadiologyMapping.findings
          .where(
            (f) => f.relatedSyndromes.contains(RadiologySyndrome.bronchial),
          )
          .length,
      RadiologySyndrome.pleural: RadiologyMapping.findings
          .where((f) => f.relatedSyndromes.contains(RadiologySyndrome.pleural))
          .length,
      RadiologySyndrome.cavitary: RadiologyMapping.findings
          .where((f) => f.relatedSyndromes.contains(RadiologySyndrome.cavitary))
          .length,
      RadiologySyndrome.mediastinal: RadiologyMapping.findings
          .where(
            (f) => f.relatedSyndromes.contains(RadiologySyndrome.mediastinal),
          )
          .length,
      RadiologySyndrome.parietal: RadiologyMapping.findings
          .where((f) => f.relatedSyndromes.contains(RadiologySyndrome.parietal))
          .length,
    };
    final sortedSyndromes = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Column(
      children: sortedSyndromes.map((entry) {
        final syndrome = entry.key;
        final score = entry.value;
        final total = syndromeCounts[syndrome]!;
        final percentage = (score / total).clamp(0.0, 1.0);
        final syndromeLabel = _getSyndromeLabel(syndrome, l10n);
        final info = RadiologyMapping.syndromeInfo.firstWhere(
          (i) => i.syndrome == syndrome,
          orElse: () => RadiologySyndromeInfo(
            syndrome: syndrome,
            title: syndromeLabel,
            definition: "",
            signs: [],
            etiologies: [],
          ),
        );
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: percentage > 0.5
                  ? primaryColor.withOpacity(0.3)
                  : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    syndromeLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () =>
                        _showSyndromeDetail(info, isDark, primaryColor, l10n),
                    icon: Icon(
                      Icons.info_outline,
                      size: 18,
                      color: primaryColor,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.radSignsCount(score, total),
                    style: TextStyle(
                      fontSize: 11,
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                        : (percentage > 0.4 ? primaryColor : Colors.orange),
                  ),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTechnicalQualityCheck(
    bool isDark,
    Color primaryColor,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.settings_overscan,
                color: Colors.amber,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.radTechnicalQuality,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.withOpacity(0.2)),
          ),
          child: Column(
            children: RadiologyMapping.technicalCriteria.map((criterion) {
              final isLast =
                  RadiologyMapping.technicalCriteria.last == criterion;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.amber.withOpacity(0.5),
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            criterion.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            criterion.description,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.radObjective(criterion.target),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDifferentialDiagnosis(
    bool isDark,
    Color primaryColor,
    AppLocalizations l10n,
  ) {
    final activeDifferentials = RadiologyMapping.differentials.where((diff) {
      return diff.triggerFindingIds.any((id) => _selectedFindings.contains(id));
    }).toList();
    if (activeDifferentials.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.compare_arrows, color: primaryColor, size: 16),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.radDifferentialDiagnosis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...activeDifferentials.map(
          (diff) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  diff.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  diff.logic,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getSyndromeLabel(RadiologySyndrome syndrome, AppLocalizations l10n) {
    switch (syndrome) {
      case RadiologySyndrome.alveolar:
        return l10n.radSyndromeAlveolar;
      case RadiologySyndrome.interstitial:
        return l10n.radSyndromeInterstitial;
      case RadiologySyndrome.bronchial:
        return l10n.radSyndromeBronchial;
      case RadiologySyndrome.pleural:
        return l10n.radSyndromePleural;
      case RadiologySyndrome.cavitary:
        return l10n.radSyndromeCavitary;
      case RadiologySyndrome.mediastinal:
        return l10n.radSyndromeMediastinal;
      case RadiologySyndrome.parietal:
        return l10n.radSyndromeParietal;
    }
  }

  Widget _buildSyndromesReference(
    bool isDark,
    Color primaryColor,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.radChapterDiagnosisGuide,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.school_outlined, color: primaryColor, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      l10n.radSemiologyCourse,
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSyndromeExpandable(
            l10n.radSyndromeAlveolar,
            l10n.radSyndromeAlveolarDesc,
            Icons.bubble_chart_outlined,
            isDark,
            primaryColor,
          ),
          _buildSyndromeExpandable(
            l10n.radSyndromeInterstitial,
            l10n.radSyndromeInterstitialDesc,
            Icons.grain_outlined,
            isDark,
            primaryColor,
          ),
          _buildSyndromeExpandable(
            l10n.radSyndromeBronchial,
            l10n.radSyndromeBronchialDesc,
            Icons.reorder_outlined,
            isDark,
            primaryColor,
          ),
          _buildSyndromeExpandable(
            l10n.radSyndromePleural,
            l10n.radSyndromePleuralDesc,
            Icons.water_drop_outlined,
            isDark,
            primaryColor,
          ),
          _buildSyndromeExpandable(
            l10n.radSyndromeCavitary,
            l10n.radSyndromeCavitaryDesc,
            Icons.trip_origin_outlined,
            isDark,
            primaryColor,
          ),
          _buildSyndromeExpandable(
            l10n.radSyndromeMediastinal,
            l10n.radSyndromeMediastinalDesc,
            Icons.vertical_split_outlined,
            isDark,
            primaryColor,
          ),
          _buildSyndromeExpandable(
            l10n.radSyndromeParietal,
            l10n.radSyndromeParietalDesc,
            Icons.line_weight_outlined,
            isDark,
            primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSyndromeExpandable(
    String title,
    String desc,
    IconData icon,
    bool isDark,
    Color primaryColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: Icon(icon, color: primaryColor, size: 24),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          MarkdownBody(
            data: desc,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.6,
              ),
              listBullet: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          childrenPadding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
          ),
          children: [
            ...children,
            if (tipTitle != null && tipDesc != null)
              _buildEducationalTip(tipTitle, tipDesc, isDark, primaryColor),
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
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: primaryColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkItem(
    String id,
    String title,
    String desc,
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
              _checklistState[id] = null;
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.03)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildCheckStatus(status, primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckStatus(bool? status, Color primaryColor) {
    if (status == null) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.withOpacity(0.3), width: 2),
        ),
      );
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: status ? AppColors.success : AppColors.errorLight,
      ),
      child: Icon(
        status ? Icons.check : Icons.close,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildActionButtons(
    bool isDark,
    Color primaryColor,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => _generateAndSharePdf(isDark, primaryColor, l10n),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.share_outlined, size: 20),
                const SizedBox(width: 12),
                Text(
                  l10n.radShareReport,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: primaryColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      l10n.radEducationalTool,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.radEducationalToolDesc,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.black54,
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

  Future<void> _generateAndSharePdf(
    bool isDark,
    Color primaryColor,
    AppLocalizations l10n,
  ) async {
    final pdf = pw.Document();
    pw.MemoryImage? pdfImage;
    if (_radImageBytes != null) {
      pdfImage = pw.MemoryImage(_radImageBytes!);
    }
    final headersMap = {
      l10n.radChapterAirway: ["airway_trachea"],
      l10n.radChapterBreathing: ["breathing_expansion", "breathing_angles"],
      l10n.radChapterCirculation: ["circulation_heart_size"],
      l10n.radChapterDiaphragm: ["diaphragm_position"],
      l10n.radChapterEverythingElse: ["everything_bones"],
    };
    final labelsMap = {
      "airway_trachea": l10n.radCheckTracheaCentral,
      "breathing_expansion": l10n.radCheckLungsExpanded,
      "breathing_angles": l10n.radCheckCostophrenicAngles,
      "circulation_heart_size": l10n.radCheckHeartSize,
      "diaphragm_position": l10n.radCheckDiaphragmPosition,
      "everything_bones": l10n.radCheckBonesSoftTissues,
    };
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        l10n.radInterpretationReport,
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text(
                        "MEDUCYTE- ${l10n.radAnalysisReport}",
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.blue700,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "${l10n.radCase} #${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        DateTime.now().toString().substring(0, 16),
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            if (pdfImage != null) ...[
              pw.Center(
                child: pw.Container(
                  height: 300,
                  child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
                ),
              ),
              pw.SizedBox(height: 20),
            ],
            pw.Text(
              l10n.ecgPdfResponses,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        l10n.ecgPdfCriteria,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        l10n.ecgPdfEvaluation,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ...headersMap.entries.expand((entry) {
                  final header = entry.key;
                  final ids = entry.value;
                  return [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey50,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            header,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue700,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(""),
                        ),
                      ],
                    ),
                    ...ids.map((id) {
                      final label = labelsMap[id] ?? id;
                      final status = _checklistState[id];
                      String statusText = l10n.ecgPdfUnanswered;
                      PdfColor statusColor = PdfColors.grey700;
                      if (status == true) {
                        statusText = l10n.ecgPdfYes;
                        statusColor = PdfColors.green700;
                      } else if (status == false) {
                        statusText = l10n.ecgPdfNo;
                        statusColor = PdfColors.red700;
                      }
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(label),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              statusText,
                              style: pw.TextStyle(
                                color: statusColor,
                                fontWeight: status != null
                                    ? pw.FontWeight.bold
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ];
                }),
              ],
            ),
            pw.SizedBox(height: 40),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 10),
            pw.Text(
              l10n.ecgPdfDisclaimer,
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
          ];
        },
      ),
    );
    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'radiology_interpretation_report.pdf',
    );
  }

  void _showSyndromeDetail(
    RadiologySyndromeInfo info,
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
                    _buildCourseSectionHeader(
                      l10n.radSemiologySigns,
                      Icons.visibility,
                      primaryColor,
                    ),
                    const SizedBox(height: 12),
                    ...info.signs.map(
                      (s) => _buildCourseBulletPoint(s, isDark),
                    ),
                    const SizedBox(height: 32),
                    _buildCourseSectionHeader(
                      l10n.radCommonEtiologies,
                      Icons.category,
                      primaryColor,
                    ),
                    const SizedBox(height: 12),
                    ...info.etiologies.map(
                      (e) => _buildCourseBulletPoint(e, isDark),
                    ),
                    if (info.clinicalPearls != null) ...[
                      const SizedBox(height: 32),
                      _buildCourseSectionHeader(
                        l10n.radClinicalPearls,
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

  Widget _buildCourseSectionHeader(String title, IconData icon, Color color) {
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

  Widget _buildCourseBulletPoint(String text, bool isDark) {
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
}

class _RadDrawingDialog extends StatefulWidget {
  final bool isDark;
  const _RadDrawingDialog({required this.isDark});
  @override
  State<_RadDrawingDialog> createState() => _RadDrawingDialogState();
}

class _RadDrawingDialogState extends State<_RadDrawingDialog> {
  final List<Offset?> _points = [];
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).primaryColor;
    return AlertDialog(
      backgroundColor: widget.isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Icon(Icons.edit_note, color: primaryColor),
          const SizedBox(width: 12),
          Text(l10n.radSourceDraw),
        ],
      ),
      content: Container(
        width: double.maxFinite,
        height: 300,
        decoration: BoxDecoration(
          color: widget.isDark ? Colors.black : Colors.white,
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              final RenderBox renderBox =
                  context.findRenderObject() as RenderBox;
              _points.add(renderBox.globalToLocal(details.globalPosition));
            });
          },
          onPanEnd: (details) => _points.add(null),
          child: CustomPaint(
            painter: _RadPainter(
              _points,
              widget.isDark ? Colors.white : Colors.black,
            ),
            size: Size.infinite,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () => setState(() => _points.clear()),
          child: Text(
            l10n.ecgClear,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            final bytes = await _captureDrawing();
            if (context.mounted) Navigator.pop(context, bytes);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(l10n.confirm),
        ),
      ],
    );
  }

  Future<Uint8List?> _captureDrawing() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 500, 300));
    final paint = Paint()
      ..color = widget.isDark ? Colors.black : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(const Rect.fromLTWH(0, 0, 500, 300), paint);
    final drawingPaint = Paint()
      ..color = widget.isDark ? Colors.white : Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;
    for (int i = 0; i < _points.length - 1; i++) {
      if (_points[i] != null && _points[i + 1] != null) {
        canvas.drawLine(_points[i]!, _points[i + 1]!, drawingPaint);
      }
    }
    final picture = recorder.endRecording();
    final img = await picture.toImage(500, 300);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}

class _RadPainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;
  _RadPainter(this.points, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_RadPainter oldDelegate) => true;
}
