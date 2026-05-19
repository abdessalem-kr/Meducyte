import 'package:meducyte_app/export.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class EcgHelperScreen extends StatefulWidget {
  const EcgHelperScreen({super.key});

  @override
  State<EcgHelperScreen> createState() => _EcgHelperScreenState();
}

class _EcgHelperScreenState extends State<EcgHelperScreen> {
  //Checklist State
  final Map<String, bool?> _checklistState = {};
  final Set<String> _abnormalLeads = {};

  //ECG Image Source
  Uint8List? _ecgImageBytes;
  final ImagePicker _picker = ImagePicker();

  //Rate Calculators
  final TextEditingController _rrSquaresController = TextEditingController();
  String _calculatedHeartRate = "--";

  //Axis Check
  int _leadIStatus = 1; //1:Positive, -1:Negative,0:Equivocal/Isoelectric
  int _leadAvfStatus = 1;

  //QTc Calculator
  final TextEditingController _qtSquaresController = TextEditingController();
  String _calculatedQtc = "--";
  bool _isQtcProlonged = false;

  @override
  void dispose() {
    _rrSquaresController.dispose();
    _qtSquaresController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _ecgImageBytes = bytes;
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
      builder: (context) => _EcgDrawingDialog(isDark: isDark),
    );
    if (resultBytes != null) {
      setState(() {
        _ecgImageBytes = resultBytes;
      });
    }
  }

  void _calculateHeartRate() {
    final val = _rrSquaresController.text;
    if (val.isEmpty) {
      setState(() => _calculatedHeartRate = "--");
      return;
    }
    final squares = double.tryParse(val);
    if (squares != null && squares > 0) {
      final hr = (1500 / squares).round(); //1500/small squares
      setState(() => _calculatedHeartRate = "$hr");
    } else {
      setState(() => _calculatedHeartRate = "--");
    }
  }

  void _calculateQtc() {
    final qtSq = double.tryParse(_qtSquaresController.text);
    final hr = double.tryParse(_calculatedHeartRate.replaceAll("bpm", ""));

    if (qtSq != null && qtSq > 0 && hr != null && hr > 0) {
      //1 small square=40ms=0.04s
      final qtMs = qtSq * 40;
      final rrSeconds = 60.0 / hr;
      //Bazett's Formula:QTc=QT/sqrt(RR)
      final qtc = qtMs / sqrt(rrSeconds);
      setState(() {
        _calculatedQtc = "${qtc.round()}";
        _isQtcProlonged = qtc > 460;
      });
    } else {
      setState(() {
        _calculatedQtc = "--";
        _isQtcProlonged = false;
      });
    }
  }

  String _getAxisText(AppLocalizations l10n) {
    if (_leadIStatus == 1 && _leadAvfStatus == 1) return l10n.ecgAxisNormal;
    if (_leadIStatus == 1 && _leadAvfStatus <= 0) return l10n.ecgAxisLad;
    if (_leadIStatus <= 0 && _leadAvfStatus == 1) return l10n.ecgAxisRad;
    if (_leadIStatus == -1 && _leadAvfStatus == -1) return l10n.ecgAxisExtreme;
    return l10n.ecgAxisIndeterminate;
  }

  Color _getAxisColor(bool isDark) {
    if (_leadIStatus == 1 && _leadAvfStatus == 1) {
      return AppColors.secondaryLight;
    }
    if (_leadIStatus == 1 && _leadAvfStatus <= 0 ||
        _leadIStatus <= 0 && _leadAvfStatus == 1) {
      return isDark ? AppColors.warningDark : AppColors.warningLight;
    }
    if (_leadIStatus == -1 && _leadAvfStatus == -1) {
      return isDark ? AppColors.errorDark : AppColors.errorLight;
    }
    return isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _generateAndSharePdf(isDark, primaryColor, l10n),
        backgroundColor: primaryColor,
        icon: const Icon(Iconsax.document_download, color: Colors.white),
        label: Text(
          l10n.ecgShareReport,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, isDark, l10n),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildDisclaimerCard(isDark, l10n),
                const SizedBox(height: 24),
                _buildImageSourceCard(context, isDark, primaryColor, l10n),
                const SizedBox(height: 24),
                _buildSectionTitle(
                  context,
                  l10n.ecgGuidedInterpretation,
                  isDark,
                ),
                _buildAnalysisSummary(isDark, primaryColor, l10n),
                _buildTerritoryGrid(isDark, l10n),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildExpansionCard(
                        title: l10n.ecgChapterRateRhythm,
                        icon: Iconsax.heart,
                        color: primaryColor,
                        isDark: isDark,
                        status: l10n.ecgStatusNormal,
                        children: [
                          _buildSubHeader(l10n.ecgRrCalculator),
                          Row(
                            children: [
                              Expanded(
                                child: _buildCalculationField(
                                  l10n.ecgSmallSquares,
                                  _rrSquaresController,
                                  isDark,
                                  onChanged: (_) => _calculateHeartRate(),
                                ),
                              ),
                              const SizedBox(width: 16),
                              _buildResultBubble(
                                "$_calculatedHeartRate BPM",
                                isDark,
                                primaryColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildCheckItem(
                            l10n.ecgCheckRhythmRegular,
                            l10n.ecgCheckRhythmRegularDesc,
                            isDark,
                          ),
                          _buildCheckItem(
                            l10n.ecgCheckPWave,
                            l10n.ecgCheckPWaveDesc,
                            isDark,
                          ),
                        ],
                      ),
                      _buildExpansionCard(
                        title: l10n.ecgChapterAxisIntervals,
                        icon: Iconsax.ruler,
                        color: primaryColor,
                        isDark: isDark,
                        status: _getAxisText(l10n).toUpperCase(),
                        children: [
                          _buildSubHeader(l10n.ecgLeadIDirection),
                          _buildSegmentedControl(
                            value: _leadIStatus,
                            onChanged: (v) => setState(() => _leadIStatus = v),
                            isDark: isDark,
                            primaryColor: primaryColor,
                          ),
                          const SizedBox(height: 16),
                          _buildSubHeader(l10n.ecgLeadaVFDirection),
                          _buildSegmentedControl(
                            value: _leadAvfStatus,
                            onChanged: (v) =>
                                setState(() => _leadAvfStatus = v),
                            isDark: isDark,
                            primaryColor: primaryColor,
                          ),
                          const SizedBox(height: 20),
                          _buildInfoNote(
                            "${l10n.ecgCurrentAxis}: ${_getAxisText(l10n)}",
                            isDark,
                            color: _getAxisColor(isDark),
                          ),
                        ],
                      ),
                      _buildExpansionCard(
                        title: l10n.ecgChapterPWavePr,
                        icon: Iconsax.activity,
                        color: primaryColor,
                        isDark: isDark,
                        status: l10n.ecgStatusAnalyzed,
                        children: [
                          _buildSubHeader(l10n.ecgPWaveLeadII),
                          _buildCheckItem(
                            l10n.ecgCheckPMitrale,
                            l10n.ecgCheckPMitraleDesc,
                            isDark,
                          ),
                          _buildCheckItem(
                            l10n.ecgCheckPPulmonale,
                            l10n.ecgCheckPPulmonaleDesc,
                            isDark,
                          ),
                          const SizedBox(height: 12),
                          _buildSubHeader(l10n.ecgPrInterval),
                          _buildCheckItem(
                            l10n.ecgCheckPrDuration,
                            l10n.ecgCheckPrDurationDesc,
                            isDark,
                          ),
                        ],
                      ),
                      _buildExpansionCard(
                        title: l10n.ecgChapterQrs,
                        icon: Iconsax.chart_1,
                        color: primaryColor,
                        isDark: isDark,
                        status: l10n.ecgStatusStable,
                        children: [
                          _buildCheckItem(
                            l10n.ecgCheckQrsDuration,
                            l10n.ecgCheckQrsDurationDesc,
                            isDark,
                          ),
                          _buildCheckItem(
                            l10n.ecgCheckPathologicalQ,
                            l10n.ecgCheckPathologicalQDesc,
                            isDark,
                          ),
                          _buildCheckItem(
                            l10n.ecgCheckQrsAmplitude,
                            l10n.ecgCheckQrsAmplitudeDesc,
                            isDark,
                          ),
                        ],
                      ),
                      _buildExpansionCard(
                        title: l10n.ecgChapterStTWave,
                        icon: Iconsax.danger,
                        color: primaryColor,
                        isDark: isDark,
                        status: l10n.ecgStatusNoIschemia,
                        children: [
                          _buildSubHeader(l10n.ecgStSegmentIschemia),
                          _buildCheckItem(
                            l10n.ecgCheckStIsoelectric,
                            l10n.ecgCheckStIsoelectricDesc,
                            isDark,
                          ),
                          const SizedBox(height: 12),
                          _buildSubHeader(l10n.ecgTWave),
                          _buildCheckItem(
                            l10n.ecgCheckTWaveUpright,
                            l10n.ecgCheckTWaveUprightDesc,
                            isDark,
                          ),
                        ],
                      ),
                      _buildExpansionCard(
                        title: l10n.ecgChapterQtInterval,
                        icon: Iconsax.timer_1,
                        color: primaryColor,
                        isDark: isDark,
                        status: _isQtcProlonged
                            ? l10n.ecgProlonged
                            : l10n.ecgNormal,
                        children: [
                          _buildSubHeader(l10n.ecgBazettCalculator),
                          Row(
                            children: [
                              Expanded(
                                child: _buildCalculationField(
                                  l10n.ecgQtSmallSquares,
                                  _qtSquaresController,
                                  isDark,
                                  onChanged: (_) => _calculateQtc(),
                                ),
                              ),
                              const SizedBox(width: 16),
                              _buildResultBubble(
                                "$_calculatedQtc ms",
                                isDark,
                                _isQtcProlonged
                                    ? AppColors.errorLight
                                    : primaryColor,
                              ),
                            ],
                          ),
                          if (_isQtcProlonged)
                            _buildInfoNote(
                              l10n.ecgWarningQtProlonged,
                              isDark,
                              color: AppColors.errorLight,
                            ),
                          _buildCheckItem(
                            l10n.ecgCheckQtHalfRr,
                            l10n.ecgCheckQtHalfRrDesc,
                            isDark,
                          ),
                        ],
                      ),
                      _buildExpansionCard(
                        title: l10n.ecgChapterBlockHypertrophy,
                        icon: Iconsax.health,
                        color: primaryColor,
                        isDark: isDark,
                        status: l10n.ecgStatusAbsent,
                        children: [
                          _buildSubHeader(l10n.ecgBundleBranchBlocks),
                          _buildInfoNote(l10n.ecgWilliamMarrow, isDark),
                          _buildCheckItem(
                            l10n.ecgCheckV1MsShape,
                            l10n.ecgCheckV1MsShapeDesc,
                            isDark,
                          ),
                          _buildCheckItem(
                            l10n.ecgCheckV6SlurredS,
                            l10n.ecgCheckV6SlurredSDesc,
                            isDark,
                          ),
                          const SizedBox(height: 12),
                          _buildSubHeader(l10n.ecgLeftVentricularHypertrophy),
                          _buildCheckItem(
                            l10n.ecgCheckSokolowLyon,
                            l10n.ecgCheckSokolowLyonDesc,
                            isDark,
                          ),
                        ],
                      ),
                      _buildExpansionCard(
                        title: l10n.ecgChapterTerritories,
                        icon: Iconsax.heart5,
                        color: isDark
                            ? AppColors.errorDark
                            : AppColors.errorLight,
                        isDark: isDark,
                        status: l10n.ecgStatusClear,
                        children: [
                          _buildSubHeader(l10n.ecgCoronaryTerritories),
                          _buildInfoNote(l10n.ecgTerritoryMap, isDark),
                          _buildTerritoryRow(
                            "${l10n.ecgTerritoryInferior} (RCA)",
                            "II,III,aVF",
                            isDark,
                          ),
                          _buildTerritoryRow(
                            "${l10n.ecgTerritoryLateral} (LCx/LAD)",
                            "I,aVL,V5,V6",
                            isDark,
                          ),
                          _buildTerritoryRow(
                            "${l10n.ecgTerritoryAnterior} (LAD)",
                            "V1-V4",
                            isDark,
                          ),
                          _buildTerritoryRow(
                            l10n.ecgTerritorySeptal,
                            "V1,V2",
                            isDark,
                          ),
                        ],
                      ),
                      _buildExpansionCard(
                        title: l10n.ecgChapterElectrolytes,
                        icon: Iconsax.flash_1,
                        color: primaryColor,
                        isDark: isDark,
                        status: l10n.ecgStatusUnremarkable,
                        children: [
                          _buildSubHeader(l10n.ecgElectrolytesTarget),
                          _buildReferenceItem(l10n.ecgHyperkalemia, isDark),
                          _buildInfoNote(l10n.ecgHyperkalemiaDesc, isDark),
                          _buildReferenceItem(l10n.ecgHypokalemia, isDark),
                          _buildInfoNote(l10n.ecgHypokalemiaDesc, isDark),
                          const SizedBox(height: 16),
                          _buildSubHeader(l10n.ecgCalciumTitle),
                          _buildReferenceItem(l10n.ecgHypercalcemia, isDark),
                          _buildReferenceItem(l10n.ecgHypocalcemia, isDark),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.only(top: 100, left: 24, right: 24),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(32),
            ),
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
                          l10n.ecgAnalysisReport,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${l10n.ecgCase} #${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.circle,
                          color: Colors.greenAccent,
                          size: 8,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.ecgAiActive,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
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
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () => _generateAndSharePdf(isDark, primaryColor, l10n),
        ),
      ],
    );
  }

  Widget _buildAnalysisSummary(
    bool isDark,
    Color primaryColor,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                child: _buildMetricTile(
                  "HEART RATE",
                  _calculatedHeartRate,
                  "BPM",
                  Iconsax.heart,
                  isDark,
                  primaryColor,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: isDark ? Colors.white12 : Colors.black12,
              ),
              Expanded(
                child: _buildMetricTile(
                  "QTC INTERVAL",
                  _calculatedQtc,
                  "ms",
                  Iconsax.timer_1,
                  isDark,
                  _isQtcProlonged ? AppColors.errorLight : primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "RHYTHM ANALYSIS",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.ecgStatusNormal,
                        style: const TextStyle(
                          color: AppColors.secondaryLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "AI CONFIDENCE",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 80,
                    child: LinearProgressIndicator(
                      value: 0.94,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(4),
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.greenAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    String label,
    String value,
    String unit,
    IconData icon,
    bool isDark,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTerritoryGrid(bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.ecgLeadClinicalGrid,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 1.8,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _leadCell("I", l10n.ecgTerritoryLateral, isDark),
              _leadCell("aVR", l10n.ecgTerritoryReciprocal, isDark),
              _leadCell("V1", l10n.ecgTerritorySeptal, isDark),
              _leadCell("II", l10n.ecgTerritoryInferior, isDark),
              _leadCell("aVL", l10n.ecgTerritoryLateral, isDark),
              _leadCell("V2", l10n.ecgTerritorySeptal, isDark),
              _leadCell("III", l10n.ecgTerritoryInferior, isDark),
              _leadCell("aVF", l10n.ecgTerritoryInferior, isDark),
              _leadCell("V3", l10n.ecgTerritoryAnterior, isDark),
              _leadCell("V4", l10n.ecgTerritoryAnterior, isDark),
              _leadCell("V5", l10n.ecgTerritoryLateral, isDark),
              _leadCell("V6", l10n.ecgTerritoryLateral, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _leadCell(String label, String territory, bool isDark) {
    final isAbnormal = _abnormalLeads.contains(label);

    return InkWell(
      onTap: () {
        setState(() {
          if (isAbnormal) {
            _abnormalLeads.remove(label);
          } else {
            _abnormalLeads.add(label);
          }
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isAbnormal
              ? AppColors.errorLight.withOpacity(isDark ? 0.15 : 0.1)
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isAbnormal
                ? (isDark ? AppColors.errorDark : AppColors.errorLight)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            if (!isDark && !isAbnormal)
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isAbnormal
                    ? (isDark ? AppColors.errorDark : AppColors.errorLight)
                    : (isDark ? Colors.white : Colors.black),
              ),
            ),
            Text(
              territory,
              style: TextStyle(
                fontSize: 8,
                color: isAbnormal
                    ? (isDark ? AppColors.errorDark : AppColors.errorLight)
                          .withOpacity(0.7)
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimerCard(bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.warningDark : AppColors.warningLight)
            .withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppColors.warningDark : AppColors.warningLight)
              .withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: isDark ? AppColors.warningDark : AppColors.warningLight,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.ecgEducationalTool,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.warningDark
                        : AppColors.warningLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.ecgEducationalToolDesc,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 13,
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

  Widget _buildSectionTitle(BuildContext context, String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
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
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionCard({
    required String title,
    required IconData icon,
    required Color color,
    required bool isDark,
    required List<Widget> children,
    String? status,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ExpansionTile(
          iconColor: color,
          collapsedIconColor: isDark ? Colors.white54 : Colors.black54,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (status != null)
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: color,
                          letterSpacing: 0.5,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildSubHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildTerritoryRow(String territory, String leads, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              territory,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              leads,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text, String explanation, bool isDark) {
    _checklistState.putIfAbsent(text, () => null);
    final answer = _checklistState[text];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showExplanationSheet(text, explanation, isDark),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Iconsax.info_circle,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildAnswerButton(
                  text: text,
                  label: "Yes",
                  value: true,
                  currentValue: answer,
                  activeColor: isDark
                      ? AppColors.secondaryDark
                      : AppColors.secondaryLight,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAnswerButton(
                  text: text,
                  label: "No",
                  value: false,
                  currentValue: answer,
                  activeColor: isDark
                      ? AppColors.errorDark
                      : AppColors.errorLight,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerButton({
    required String text,
    required String label,
    required bool value,
    required bool? currentValue,
    required Color activeColor,
    required bool isDark,
  }) {
    final isSelected = currentValue == value;

    return InkWell(
      onTap: () {
        setState(() {
          _checklistState[text] = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.15)
              : (isDark ? Colors.white12 : Colors.black12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? activeColor
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  void _showExplanationSheet(String title, String explanation, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Iconsax.book,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "What does this mean?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  explanation,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Got it,thanks!",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReferenceItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Iconsax.tick_square,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoNote(String text, bool isDark, {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(left: 32, bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (color ?? (isDark ? Colors.white : Colors.black)).withOpacity(
          0.04,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (color ?? (isDark ? Colors.white : Colors.black)).withOpacity(
            0.08,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Iconsax.info_circle,
            size: 16,
            color: color ?? (isDark ? Colors.white60 : Colors.black54),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: color ?? (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationField(
    String label,
    TextEditingController controller,
    bool isDark, {
    required Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      decoration: _inputDecoration(isDark, label: label),
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
    );
  }

  Widget _buildResultBubble(String text, bool isDark, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(bool isDark, {required String label}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.white54 : Colors.black54,
      ),
      filled: true,
      fillColor: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildSegmentedControl({
    required int value,
    required Function(int) onChanged,
    required bool isDark,
    required Color primaryColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildSegmentButton(
            1,
            "Positive(+)",
            value,
            onChanged,
            primaryColor,
            isDark,
          ),
          _buildSegmentButton(
            0,
            "Equivocal",
            value,
            onChanged,
            primaryColor,
            isDark,
          ),
          _buildSegmentButton(
            -1,
            "Negative(-)",
            value,
            onChanged,
            primaryColor,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(
    int targetValue,
    String label,
    int currentValue,
    Function(int) onChanged,
    Color primaryColor,
    bool isDark,
  ) {
    final isSelected = targetValue == currentValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(targetValue),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white60 : Colors.black54),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceCard(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildSectionTitle(context, l10n.ecgSourceTitle, isDark),
            ),
            if (_ecgImageBytes != null)
              Padding(
                padding: const EdgeInsets.only(right: 24),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  tooltip: "Clear Image",
                  onPressed: () => setState(() => _ecgImageBytes = null),
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              if (_ecgImageBytes != null)
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InteractiveViewer(
                      panEnabled: true,
                      minScale: 1.0,
                      maxScale: 6.0,
                      child: Image.memory(_ecgImageBytes!, fit: BoxFit.contain),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _buildActionBtn(
                        icon: Iconsax.camera,
                        label: l10n.ecgSourceCamera,
                        color: primaryColor,
                        onTap: () => _pickImage(ImageSource.camera),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionBtn(
                        icon: Iconsax.gallery,
                        label: l10n.ecgSourceGallery,
                        color: primaryColor,
                        onTap: () => _pickImage(ImageSource.gallery),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionBtn(
                        icon: Iconsax.edit,
                        label: l10n.ecgSourceDraw,
                        color: primaryColor,
                        onTap: _showDrawingDialog,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
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
    if (_ecgImageBytes != null) {
      pdfImage = pw.MemoryImage(_ecgImageBytes!);
    }

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
                  pw.Text(
                    'ECG Interpretation Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Meducyte',
                    style: pw.TextStyle(fontSize: 14, color: PdfColors.grey),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            if (pdfImage != null) ...[
              pw.Text(
                'Reference ECG Image',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                height: 200,
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
              ),
              pw.SizedBox(height: 20),
            ],
            pw.Text(
              'Key Metrics',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                color: PdfColors.grey100,
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _pdfMetricItem(
                    l10n.ecgHeartRate,
                    "$_calculatedHeartRate BPM",
                  ),
                  _pdfMetricItem(l10n.ecgPdfDeducedAxis, _getAxisText(l10n)),
                  _pdfMetricItem(
                    l10n.ecgQtcInterval,
                    "$_calculatedQtc ms(${_isQtcProlonged ? l10n.ecgProlonged : l10n.ecgNormal})",
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            //Clinical Grid Findings
            if (_abnormalLeads.isNotEmpty) ...[
              pw.Text(
                'Clinical Grid Findings',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.red300),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                  color: PdfColors.red50,
                ),
                child: pw.Text(
                  "${l10n.ecgAbnormalLeadsDetected}: ${_abnormalLeads.join(', ')}",
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.red900,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
            ],

            pw.Text(
              l10n.ecgPdfResponses,
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
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
                ..._checklistState.entries.map((e) {
                  final String answer = e.value == true
                      ? l10n.ecgPdfYes
                      : (e.value == false
                            ? l10n.ecgPdfNo
                            : l10n.ecgPdfUnanswered);
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          e.key.replaceAll("?", ""),
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          answer,
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: e.value == true
                                ? PdfColors.teal
                                : (e.value == false
                                      ? PdfColors.red
                                      : PdfColors.grey),
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.Text(
              l10n.ecgPdfDisclaimer,
              style: pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey700,
                fontStyle: pw.FontStyle.italic,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'ecg_interpretation_report.pdf',
    );
  }

  pw.Widget _pdfMetricItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }
}

class _EcgDrawingDialog extends StatefulWidget {
  final bool isDark;
  const _EcgDrawingDialog({required this.isDark});

  @override
  State<_EcgDrawingDialog> createState() => _EcgDrawingDialogState();
}

class _EcgDrawingDialogState extends State<_EcgDrawingDialog> {
  final List<Offset?> _points = [];

  void _addPoint(Offset? point) {
    setState(() => _points.add(point));
  }

  Future<void> _saveDrawing() async {
    if (_points.isEmpty) {
      Navigator.pop(context, null);
      return;
    }
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 800, 600));
    Paint bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(const Rect.fromLTWH(0, 0, 800, 600), bgPaint);

    Paint gridPaint = Paint()
      ..color = Colors.red.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (double i = 0; i < 800; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, 600), gridPaint);
    }
    for (double i = 0; i < 600; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(800, i), gridPaint);
    }

    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;
    for (int i = 0; i < _points.length - 1; i++) {
      if (_points[i] != null && _points[i + 1] != null) {
        canvas.drawLine(_points[i]!, _points[i + 1]!, paint);
      }
    }
    final ui.Image image = await recorder.endRecording().toImage(800, 600);
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (mounted) {
      Navigator.pop(context, byteData?.buffer.asUint8List());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          color: isDark ? AppColors.surfaceDark : Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: isDark
                    ? AppColors.errorDark.withOpacity(0.05)
                    : Colors.red.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Draw ECG Strip",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.errorDark : Colors.red,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDark ? AppColors.errorDark : Colors.red,
                      ),
                      onPressed: () => Navigator.pop(context, null),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onPanUpdate: (details) {
                        RenderBox rb = context.findRenderObject() as RenderBox;
                        _addPoint(rb.globalToLocal(details.globalPosition));
                      },
                      onPanStart: (details) {
                        RenderBox rb = context.findRenderObject() as RenderBox;
                        _addPoint(rb.globalToLocal(details.globalPosition));
                      },
                      onPanEnd: (details) => _addPoint(null),
                      child: CustomPaint(
                        painter: _EcgCanvasPainter(_points, isDark),
                        size: Size.infinite,
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                color: isDark ? AppColors.surfaceDark : Colors.grey.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.clear, size: 18),
                        label: const Text(
                          "Clear",
                          style: TextStyle(fontSize: 12),
                        ),
                        onPressed: () => setState(() => _points.clear()),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text(
                          "Save&Use",
                          style: TextStyle(fontSize: 12),
                        ),
                        onPressed: _saveDrawing,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EcgCanvasPainter extends CustomPainter {
  final List<Offset?> points;
  final bool isDark;
  _EcgCanvasPainter(this.points, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    Paint bgPaint = Paint()..color = isDark ? AppColors.cardDark : Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    Paint gridPaint = Paint()
      ..color = (isDark ? AppColors.errorDark : Colors.red).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }
    Paint strokePaint = Paint()
      ..color = isDark ? Colors.white : Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, strokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _EcgCanvasPainter oldDelegate) => true;
}
