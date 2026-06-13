import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:iconsax/iconsax.dart';
import 'package:meducyte_app/core/themes/app_colors.dart';
import 'package:meducyte_app/features/observation/data/providers/observation_providers.dart';
import 'package:meducyte_app/features/observation/data/models/specialty_config.dart';
import 'package:meducyte_app/features/observation/data/models/specialty_localization.dart';
import 'package:meducyte_app/features/observation/presentation/widgets/quill_input_field.dart';
import 'package:meducyte_app/features/observation/presentation/widgets/section_card.dart';
import 'package:meducyte_app/features/observation/presentation/widgets/examination_helper_sheet.dart';
import 'package:meducyte_app/features/observation/presentation/widgets/clinical_coach_bar.dart';
import 'package:meducyte_app/features/observation/presentation/widgets/pathology_focus_selector.dart';
import 'package:meducyte_app/features/observation/presentation/widgets/clinical_exam_checklist.dart';
import 'package:meducyte_app/features/observation/presentation/services/pdf_export_service.dart';
import 'package:meducyte_app/features/observation/data/repositories/observation_repository.dart';
import 'package:meducyte_app/features/quiz/data/repositories/note_ai_repository.dart';
import 'package:meducyte_app/features/chatbot/data/providers/chat_providers.dart';
import 'package:meducyte_app/features/chatbot/domain/models/chat_models.dart';
import 'package:meducyte_app/l10n/arb/app_localizations.dart';
import 'package:intl/intl.dart';
//Triggering analyzer refresh after localization fixes

class ObservationReportScreen extends ConsumerStatefulWidget {
  final SpecialtyFormConfig config;

  const ObservationReportScreen({super.key, required this.config});

  @override
  ConsumerState<ObservationReportScreen> createState() =>
      _ObservationReportScreenState();
}

class _ObservationReportScreenState
    extends ConsumerState<ObservationReportScreen>
    with SingleTickerProviderStateMixin {
  Timer? _autoSaveTimer;
  bool _isSaving = false;
  bool _isGeneratingSummary = false;
  bool _isGeneratingAssessment = false;
  DateTime? _lastSaved;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _triggerAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      _performAutoSave();
    });
  }

  Future<void> _performAutoSave() async {
    //Only save if there's significant content(at least a patient name or motif)
    final patient = ref.read(patientInfoProvider);
    final motif = ref.read(motifHospitalisationProvider);

    if (patient.name.isEmpty && motif.isEmpty) return;

    if (mounted) setState(() => _isSaving = true);

    try {
      await ref
          .read(observationRepositoryProvider)
          .saveCurrentReport(widget.config.specialty.name);
      if (mounted) {
        setState(() {
          _isSaving = false;
          _lastSaved = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
      debugPrint('Auto-save error: $e');
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Watch unified report provider to trigger auto-save
    ref.listen(observationReportProvider, (_, __) => _triggerAutoSave());

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.config.specialty.localizedName(context)),
        centerTitle: true,
        actions: [
          _buildSaveStatusIndicator(),
          IconButton(
            icon: const Icon(Iconsax.magicpen, color: AppColors.primary),
            tooltip: "Assistant IA Clinique",
            onPressed: () => _showAiHelperSheet(context),
          ),
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: () {
              //Ask for confirmation before clearing
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(l10n.clearReportQuestion),
                    content: Text(l10n.clearReportConfirmDesc),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () {
                          resetObservationReport(ref);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.reportCleared)),
                          );
                        },
                        child: Text(
                          l10n.reset,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 13,
          ),
          indicatorSize: TabBarIndicatorSize.label,
          indicatorPadding: const EdgeInsets.symmetric(vertical: 8),
          tabs: [
            Tab(text: l10n.general, icon: const Icon(Iconsax.user, size: 20)),
            Tab(text: l10n.history, icon: const Icon(Iconsax.book, size: 20)),
            Tab(text: 'Examen', icon: const Icon(Iconsax.health, size: 20)),
            Tab(text: 'Tests', icon: const Icon(Iconsax.monitor, size: 20)),
            Tab(text: 'Résumé', icon: const Icon(Iconsax.note_text, size: 20)),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  //Tab 1:General
                  ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      SectionCard(
                        title: l10n.section_introduction,
                        icon: Iconsax.document_text,
                        child: const _IntroductionForm(),
                      ),
                      SectionCard(
                        title: 'Paramètres vitaux',
                        icon: Iconsax.activity,
                        child: Column(
                          children: [
                            const _PatientInfoForm(),
                            const SizedBox(height: 16),
                            const _VitalsForm(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  //Tab 2:History
                  ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      SectionCard(
                        title: l10n.section_motif,
                        icon: Iconsax.warning_2,
                        child: const _MotifHospitalisationForm(),
                      ),
                      SectionCard(
                        title: l10n.section_history,
                        icon: Iconsax.book,
                        child: const _HistoireMaladieForm(),
                      ),
                      SectionCard(
                        title: l10n.section_antecedents,
                        icon: Iconsax.folder_open,
                        child: const _AntecedentsForm(),
                      ),
                    ],
                  ),
                  //Tab 3:Exam
                  ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      ClinicalCoachBar(config: widget.config),
                      PathologyFocusSelector(config: widget.config),
                      ClinicalExamChecklist(config: widget.config),
                      SectionCard(
                        title: 'Examen clinique - ${widget.config.specialty.localizedName(context)}',
                        icon: Iconsax.health,
                        child: _PhysicalExamForm(config: widget.config),
                      ),
                    ],
                  ),
                  //Tab 4:Tests
                  ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      SectionCard(
                        title: l10n.section_paraclinical,
                        icon: Iconsax.monitor,
                        child: const _ParacliniqueForm(),
                      ),
                    ],
                  ),
                  //Tab 5:Summary
                  ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _buildMeducyteAiSection(),
                      SectionCard(
                        title: l10n.section_summary,
                        icon: Iconsax.note_text,
                        child: const _ResumeTotalForm(),
                      ),
                      SectionCard(
                        title: l10n.section_conclusion,
                        icon: Iconsax.document_text,
                        child: const _AssessmentForm(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 2
          ? FloatingActionButton.extended(
              onPressed: () =>
                  ExaminationHelperSheet.show(context, widget.config),
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Iconsax.teacher),
              label: Text(
                l10n.examHelp,
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            )
          : null,
    );
  }

  Widget _buildSaveStatusIndicator() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _isSaving
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryLight,
                  ),
                ),
              ),
            )
          : _lastSaved != null
          ? Tooltip(
              key: ValueKey(_lastSaved),
              message: 'Saved at${DateFormat.Hm().format(_lastSaved!)}',
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Iconsax.cloud_plus,
                      color: Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat.Hm().format(_lastSaved!),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox(key: ValueKey('none')),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    final activeController = ref.watch(activeQuillControllerProvider);
    final currentIndex = _tabController.index;
    final isLastTab = currentIndex == 4;
    final isFirstTab = currentIndex == 0;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (activeController != null)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: QuillSimpleToolbar(
                controller: activeController,
                config: const QuillSimpleToolbarConfig(
                  showFontFamily: false,
                  showFontSize: false,
                  showSubscript: false,
                  showSuperscript: false,
                  showInlineCode: false,
                  showIndent: false,
                  showAlignmentButtons: false,
                  showLink: false,
                  showSearchButton: false,
                  showBackgroundColorButton: true,
                  showDirection: false,
                  multiRowsDisplay: false,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (!isFirstTab)
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () =>
                          _tabController.animateTo(currentIndex - 1),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Iconsax.arrow_left_2),
                    ),
                  ),
                if (!isFirstTab) const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: isLastTab
                        ? () => _exportReport(context)
                        : () => _tabController.animateTo(currentIndex + 1),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastTab ? l10n.compileAndCopy : l10n.next,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isLastTab ? Iconsax.copy : Iconsax.arrow_right_3,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                if (isLastTab) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () => _exportToPdf(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.secondary
                            .withOpacity(0.1),
                        foregroundColor: theme.colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Icon(Iconsax.document_download),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _exportReport(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final patient = ref.read(patientInfoProvider);
    final introData = ref.read(introductionDataProvider);
    final introduction = _compileIntroduction(
      introData,
      patient,
      l10n,
    );
    final motif = getPlainText(ref.read(motifHospitalisationProvider));
    final histoire = getPlainText(ref.read(histoireMaladieProvider));
    final ant = ref.read(antecedentsProvider);
    final vitals = ref.read(vitalsProvider);
    final exam = ref.read(physicalExamProvider);
    final paraExams = ref.read(paracliniqueExamsProvider);
    final resume = getPlainText(ref.read(resumeTotalProvider));
    final assessment = getPlainText(ref.read(assessmentAndPlanProvider));

    final buffer = StringBuffer();
    buffer.writeln(
      "OBSERVATION MÉDICALE - ${widget.config.specialty.localizedName(context).toUpperCase()}",
    );
    buffer.writeln("----------------------------------------\n");

    if (introduction.isNotEmpty) {
      buffer.writeln("INTRODUCTION:\n$introduction\n");
    }

    buffer.writeln(
      "PATIENT: ${patient.name} (${patient.age}, ${patient.gender})\n",
    );
    buffer.writeln("MOTIF: $motif\n");
    buffer.writeln("HISTOIRE DE LA MALADIE:\n$histoire\n");

    buffer.writeln("ANTÉCÉDENTS:");
    buffer.writeln("-Médicaux: ${getPlainText(ant.medicaux)}");
    buffer.writeln("-Chirurgicaux: ${getPlainText(ant.chirurgicaux)}");
    buffer.writeln("-Familiaux: ${getPlainText(ant.familiaux)}");
    buffer.writeln("-Gynéco-obs: ${getPlainText(ant.gynecoObstetriques)}");
    buffer.writeln("-Mode de vie: ${getPlainText(ant.modeDeVie)}\n");

    buffer.writeln("EXAMEN PHYSIQUE:");
    buffer.writeln(
      "Constantes: ${vitals.temperature}°C, ${vitals.bloodPressure}mmHg, ${vitals.heartRate}bpm, ${vitals.respiratoryRate}cpm,SpO2: ${vitals.oxygenSaturation}%\n",
    );

    for (final field in widget.config.examFields) {
      final val = getPlainText(exam[field.key] ?? "");
      if (val.isNotEmpty) {
        buffer.writeln("- ${field.label}: $val");
      }
    }
    buffer.writeln("");

    final customFields = ref.read(customPhysicalExamFieldsProvider);
    if (customFields.isNotEmpty) {
      buffer.writeln("[EXAMENS SUPPLÉMENTAIRES]");
      for (final field in customFields) {
        final val = getPlainText(exam[field.key] ?? "");
        if (val.isNotEmpty) {
          buffer.writeln("- ${field.label}: $val");
        }
      }
      buffer.writeln("");
    }

    if (paraExams.isNotEmpty) {
      buffer.writeln("EXAMENS COMPLÉMENTAIRES/PARACLINIQUE:");
      for (final e in paraExams) {
        buffer.writeln("- ${e.title}:");
        for (final p in e.parameters) {
          final pval = getPlainText(p.value);
          if (pval.isNotEmpty) {
            buffer.writeln("  * ${p.name}: $pval");
          }
        }
      }
      buffer.writeln("");
    }

    buffer.writeln("RÉSUMÉSYNDROMIQUE/AU TOTAL:\n$resume\n");
    buffer.writeln("CONCLUSION/CONDUITEÀTENIR:\n$assessment");

    final reportText = buffer.toString().trim();
    Clipboard.setData(ClipboardData(text: reportText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.reportCopiedClipboard)),
    );
  }

  void _exportToPdf(BuildContext context) async {
    final patient = ref.read(patientInfoProvider);
    final introData = ref.read(introductionDataProvider);
    final introduction = _compileIntroduction(
      introData,
      patient,
      AppLocalizations.of(context)!,
    );
    final motif = ref.read(motifHospitalisationProvider);
    final histoire = ref.read(histoireMaladieProvider);
    final antecedents = ref.read(antecedentsProvider);
    final vitals = ref.read(vitalsProvider);
    final physicalExam = ref.read(physicalExamProvider);
    final paraclinical = ref.read(paracliniqueExamsProvider);
    final resume = ref.read(resumeTotalProvider);
    final assessment = ref.read(assessmentAndPlanProvider);
    final customFields = ref.read(customPhysicalExamFieldsProvider);

    await PdfExportService.exportToPdf(
      context: context,
      config: widget.config,
      patient: patient,
      introduction: introduction,
      motif: motif,
      histoire: histoire,
      antecedents: antecedents,
      vitals: vitals,
      physicalExam: physicalExam,
      customPhysicalExamFields: customFields,
      paraclinicalExams: paraclinical,
      resume: resume,
      assessment: assessment,
    );
  }

  String _compileIntroduction(
    IntroductionData intro,
    PatientInfo patient,
    AppLocalizations l10n,
  ) {
    final isFemale = patient.gender.toLowerCase().contains('f');
    final genderSuffix = isFemale ? 'e' : '';
    final name = patient.name;

    final ageLabel = isFemale
        ? l10n.intro_age_label_feminine
        : l10n.intro_age_label_masculine;

    final admittedLabel = isFemale
        ? l10n.intro_admitted_feminine
        : l10n.intro_admitted_masculine;

    final ageStr = patient.age.isEmpty
        ? ageLabel
        : '$ageLabel${l10n.intro_age_prefix}${patient.age}';

    return "${l10n.intro_patient_prefix}$genderSuffix$name$ageStr${l10n.intro_origin_prefix}${intro.origin}. "
        "${intro.maritalStatus} ${intro.profession} $admittedLabel"
        "${l10n.intro_date_prefix}${intro.admissionDate} ${l10n.intro_for_prefix}${intro.signs}.";
  }

  Widget _buildMeducyteAiSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.primary.withOpacity(0.05),
                ]
              : [
                  AppColors.primary.withOpacity(0.08),
                  AppColors.primary.withOpacity(0.02),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.magicpen,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Meducyte AI",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Générez automatiquement vos synthèses et conclusions cliniques.",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _isGeneratingSummary
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _generateSummary,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Iconsax.note_text, size: 16),
                        label: const Text(
                          "Résumé Syndromique",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _isGeneratingAssessment
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _generateAssessment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                        icon: const Icon(Iconsax.document_text, size: 16),
                        label: const Text(
                          "Conduite à Tenir",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _generateSummary() async {
    final contextText = _compileReportContext();
    if (contextText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez d'abord remplir les autres sections de l'observation."),
        ),
      );
      return;
    }

    setState(() => _isGeneratingSummary = true);

    try {
      final language = Localizations.localeOf(context).languageCode;
      final aiRepo = ref.read(noteAiRepositoryProvider);
      
      final responseText = await aiRepo.getAiResponse(
        action: 'generate_observation_summary',
        contextText: contextText,
        language: language,
      );

      final deltaJson = _convertPlainTextToDeltaJson(responseText);
      ref.read(observationReportProvider.notifier).updateResumeTotal(deltaJson);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Résumé Syndromique généré avec succès !")),
        );
      }
    } catch (e) {
      debugPrint("Meducyte AI summary error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la génération: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingSummary = false);
    }
  }

  Future<void> _generateAssessment() async {
    final contextText = _compileReportContext();
    if (contextText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez d'abord remplir les autres sections de l'observation."),
        ),
      );
      return;
    }

    setState(() => _isGeneratingAssessment = true);

    try {
      final language = Localizations.localeOf(context).languageCode;
      final aiRepo = ref.read(noteAiRepositoryProvider);
      
      final responseText = await aiRepo.getAiResponse(
        action: 'generate_observation_assessment',
        contextText: contextText,
        language: language,
      );

      final deltaJson = _convertPlainTextToDeltaJson(responseText);
      ref.read(observationReportProvider.notifier).updateAssessmentAndPlan(deltaJson);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Conclusion et Conduite à Tenir générées avec succès !")),
        );
      }
    } catch (e) {
      debugPrint("Meducyte AI assessment error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la génération: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingAssessment = false);
    }
  }

  String _convertPlainTextToDeltaJson(String text) {
    final doc = Document()..insert(0, text);
    return jsonEncode(doc.toDelta().toJson());
  }

  String _compileReportContext() {
    final patient = ref.read(patientInfoProvider);
    final introData = ref.read(introductionDataProvider);
    final l10n = AppLocalizations.of(context)!;
    final introduction = _compileIntroduction(introData, patient, l10n);
    final motif = getPlainText(ref.read(motifHospitalisationProvider));
    final histoire = getPlainText(ref.read(histoireMaladieProvider));
    final ant = ref.read(antecedentsProvider);
    final vitals = ref.read(vitalsProvider);
    final exam = ref.read(physicalExamProvider);
    final paraExams = ref.read(paracliniqueExamsProvider);

    final buffer = StringBuffer();
    if (introduction.isNotEmpty) buffer.writeln("Introduction: $introduction");
    buffer.writeln("Patient: ${patient.name} (${patient.age} ans, ${patient.gender})");
    if (motif.isNotEmpty) buffer.writeln("Motif de consultation: $motif");
    if (histoire.isNotEmpty) buffer.writeln("Histoire de la maladie: $histoire");
    
    buffer.writeln("Antécédents:");
    if (ant.medicaux.isNotEmpty) buffer.writeln("- Médicaux: ${getPlainText(ant.medicaux)}");
    if (ant.chirurgicaux.isNotEmpty) buffer.writeln("- Chirurgicaux: ${getPlainText(ant.chirurgicaux)}");
    if (ant.familiaux.isNotEmpty) buffer.writeln("- Familiaux: ${getPlainText(ant.familiaux)}");
    if (ant.gynecoObstetriques.isNotEmpty) buffer.writeln("- Gynéco-obstétriques: ${getPlainText(ant.gynecoObstetriques)}");
    if (ant.modeDeVie.isNotEmpty) buffer.writeln("- Mode de vie: ${getPlainText(ant.modeDeVie)}");

    buffer.writeln("Examen physique:");
    buffer.writeln("- Température: ${vitals.temperature}°C, TA: ${vitals.bloodPressure}mmHg, FC: ${vitals.heartRate}bpm, FR: ${vitals.respiratoryRate}cpm, SpO2: ${vitals.oxygenSaturation}%, Poids: ${vitals.weight}kg");
    
    for (final field in widget.config.examFields) {
      final val = getPlainText(exam[field.key] ?? "");
      if (val.isNotEmpty) {
        buffer.writeln("- Examen ${field.label}: $val");
      }
    }

    final customFields = ref.read(customPhysicalExamFieldsProvider);
    for (final field in customFields) {
      final val = getPlainText(exam[field.key] ?? "");
      if (val.isNotEmpty) {
        buffer.writeln("- Examen ${field.label}: $val");
      }
    }

    if (paraExams.isNotEmpty) {
      buffer.writeln("Examens complémentaires:");
      for (final e in paraExams) {
        buffer.writeln("- ${e.title}:");
        for (final p in e.parameters) {
          final pval = getPlainText(p.value);
          if (pval.isNotEmpty) {
            buffer.writeln("  * ${p.name}: $pval");
          }
        }
      }
    }
    return buffer.toString();
  }

  void _showAiHelperSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ObservationAiHelperSheet(
        compileContext: _compileReportContext,
        patientName: ref.read(patientInfoProvider).name,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// AI Helper Sheet Widget
// -----------------------------------------------------------------------------
class _ObservationAiHelperSheet extends ConsumerStatefulWidget {
  final String Function() compileContext;
  final String patientName;

  const _ObservationAiHelperSheet({
    required this.compileContext,
    required this.patientName,
  });

  @override
  ConsumerState<_ObservationAiHelperSheet> createState() =>
      __ObservationAiHelperSheetState();
}

class __ObservationAiHelperSheetState
    extends ConsumerState<_ObservationAiHelperSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final name = widget.patientName.trim().isEmpty ? "le patient" : widget.patientName;
    _messages.add(
      ChatMessage(
        id: 'welcome',
        text: "Bonjour Docteur. Je suis Meducyte AI, votre assistant clinique. "
            "J'ai analysé les informations saisies pour $name. "
            "Comment puis-je vous aider dans votre démarche (diagnostic différentiel, examens complémentaires, interprétation) ?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend([String? textToSend]) async {
    final text = textToSend ?? _controller.text.trim();
    if (text.isEmpty) return;

    if (textToSend == null) {
      _controller.clear();
    }

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final chatRepo = ref.read(chatRepositoryProvider);
      final reportContext = widget.compileContext();

      final aiResponse = await chatRepo.sendObservationChatMessage(
        history: _messages.sublist(1, _messages.length - 1),
        message: text,
        observationContext: reportContext,
      );

      if (mounted) {
        setState(() {
          _messages.add(aiResponse);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: "Une erreur est survenue lors de la communication avec l'assistant IA: $e",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Iconsax.magicpen, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Assistant IA Clinique",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Analyse en temps réel de votre observation",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Iconsax.close_circle),
                  color: theme.hintColor,
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildChatBubble(message);
              },
            ),
          ),
          if (_messages.length == 1) _buildSuggestions(),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = [
      "Diagnostic différentiel",
      "Signes de gravité à rechercher",
      "Examens complémentaires clés",
      "Plan thérapeutique suggéré",
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: suggestions.map((s) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: Text(s, style: const TextStyle(fontSize: 12)),
                backgroundColor: Theme.of(context).cardColor,
                elevation: 0,
                pressElevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                  ),
                ),
                onPressed: () => _handleSend(s),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(right: 8, top: 4),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: AppColors.primary,
                size: 14,
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : theme.cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: theme.dividerColor.withOpacity(0.08),
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isUser
                      ? Text(
                          message.text,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        )
                      : MarkdownBody(
                          data: message.text,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                            p: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                              fontSize: 14.5,
                            ),
                            h3: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: theme.primaryColor,
                            ),
                            blockquote: theme.textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.amber[900],
                            ),
                            blockquotePadding: const EdgeInsets.all(12),
                            blockquoteDecoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border(
                                left: BorderSide(color: Colors.amber[700]!, width: 4),
                              ),
                            ),
                            tableBorder: TableBorder.all(
                              color: theme.dividerColor.withOpacity(0.2),
                              width: 1,
                            ),
                            tableCellsPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            tableHead: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  if (!isUser && message.id != 'welcome') ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Iconsax.copy, size: 16),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          tooltip: "Copier la suggestion",
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: message.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Copié dans le presse-papiers !"),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withOpacity(0.05)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.1),
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: "Posez votre question clinique...",
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: AppColors.primaryDark,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _handleSend(),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(Iconsax.send_1, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//Component Forms(We use ConsumerStatefulWidget for local text controllers that sync to providers)
// -----------------------------------------------------------------------------

class _PatientInfoForm extends ConsumerStatefulWidget {
  const _PatientInfoForm();

  @override
  ConsumerState<_PatientInfoForm> createState() => _PatientInfoFormState();
}

class _PatientInfoFormState extends ConsumerState<_PatientInfoForm> {
  @override
  Widget build(BuildContext context) {
    final patientInfo = ref.watch(patientInfoProvider);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: patientInfo.gender.isEmpty ? null : patientInfo.gender,
          decoration: InputDecoration(
            labelText: l10n.gender,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: [
            DropdownMenuItem(value: 'Male', child: Text(l10n.gender_male)),
            DropdownMenuItem(value: 'Female', child: Text(l10n.gender_female)),
          ],
          onChanged: (newValue) {
            if (newValue != null) {
              ref.read(observationReportProvider.notifier).updatePatientInfo(
                    patientInfo.copyWith(gender: newValue),
                  );
            }
          },
        ),
      ],
    );
  }
}

class _VitalsForm extends ConsumerStatefulWidget {
  const _VitalsForm();

  @override
  ConsumerState<_VitalsForm> createState() => _VitalsFormState();
}

class _VitalsFormState extends ConsumerState<_VitalsForm> {
  final _bpController = TextEditingController();
  final _hrController = TextEditingController();
  final _rrController = TextEditingController();
  final _tempController = TextEditingController();
  final _spo2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final vitals = ref.read(vitalsProvider);
    _bpController.text = vitals.bloodPressure;
    _hrController.text = vitals.heartRate;
    _rrController.text = vitals.respiratoryRate;
    _tempController.text = vitals.temperature;
    _spo2Controller.text = vitals.oxygenSaturation;
  }

  @override
  void dispose() {
    _bpController.dispose();
    _hrController.dispose();
    _rrController.dispose();
    _tempController.dispose();
    _spo2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vitals = ref.watch(vitalsProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    ref.listen(vitalsProvider, (previous, next) {
      if (previous?.bloodPressure != next.bloodPressure) {
        _bpController.text = next.bloodPressure;
      }
      if (previous?.heartRate != next.heartRate) {
        _hrController.text = next.heartRate;
      }
      if (previous?.respiratoryRate != next.respiratoryRate) {
        _rrController.text = next.respiratoryRate;
      }
      if (previous?.temperature != next.temperature) {
        _tempController.text = next.temperature;
      }
      if (previous?.oxygenSaturation != next.oxygenSaturation) {
        _spo2Controller.text = next.oxygenSaturation;
      }
    });

    InputDecoration decor(String label, String unit) => InputDecoration(
      labelText: label,
      suffixText: unit,
      isDense: true,
      filled: true,
      fillColor: theme.primaryColor.withOpacity(0.03),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primaryColor.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primaryColor.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primaryColor, width: 2),
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: theme.primaryColor.withOpacity(0.7),
      ),
    );

    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            TextFormField(
              controller: _bpController,
              decoration: decor(l10n.vitals_bp, 'mmHg'),
              onChanged: (val) => ref.read(observationReportProvider.notifier).updateVitals(
                    vitals.copyWith(bloodPressure: val),
                  ),
            ),
            TextFormField(
              controller: _hrController,
              keyboardType: TextInputType.number,
              decoration: decor(l10n.vitals_hr, 'bpm'),
              onChanged: (val) => ref.read(observationReportProvider.notifier).updateVitals(
                    vitals.copyWith(heartRate: val),
                  ),
            ),
            TextFormField(
              controller: _rrController,
              keyboardType: TextInputType.number,
              decoration: decor(l10n.vitals_rr, 'cpm'),
              onChanged: (val) => ref.read(observationReportProvider.notifier).updateVitals(
                    vitals.copyWith(respiratoryRate: val),
                  ),
            ),
            TextFormField(
              controller: _tempController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: decor(l10n.vitals_temp, '°C'),
              onChanged: (val) => ref.read(observationReportProvider.notifier).updateVitals(
                    vitals.copyWith(temperature: val),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _spo2Controller,
          keyboardType: TextInputType.number,
          decoration: decor(l10n.vitals_spo2, '%'),
          onChanged: (val) => ref.read(observationReportProvider.notifier).updateVitals(
                vitals.copyWith(oxygenSaturation: val),
              ),
        ),
      ],
    );
  }
}

class _PhysicalExamForm extends ConsumerWidget {
  final SpecialtyFormConfig config;

  const _PhysicalExamForm({required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examData = ref.watch(physicalExamProvider);
    final customFields = ref.watch(customPhysicalExamFieldsProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      children: [
        //Standard fields
        ...config.examFields.map(
          (field) => _buildField(context, ref, field, examData),
        ),

        //Custom fields
        if (customFields.isNotEmpty) ...[
          const Divider(),
          const SizedBox(height: 8),
          ...customFields.map(
            (field) =>
                _buildField(context, ref, field, examData, isCustom: true),
          ),
        ],

        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _showAddFieldDialog(context, ref),
          icon: const Icon(Icons.add),
          label: Text(l10n.addCustomSection),
          style: TextButton.styleFrom(foregroundColor: theme.primaryColor),
        ),
      ],
    );
  }

  Widget _buildField(
    BuildContext context,
    WidgetRef ref,
    ExamFieldConfig field,
    Map<String, String> examData, {
    bool isCustom = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.02)
            : Colors.black.withOpacity(0.01),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    field.localizationKey != null
                        ? _getLocalizedLabel(context, field.localizationKey!)
                        : field.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: theme.primaryColor.withOpacity(0.8),
                    ),
                  ),
                ),
                if (isCustom)
                  IconButton(
                    icon: const Icon(
                      Iconsax.trash,
                      color: Colors.red,
                      size: 18,
                    ),
                    onPressed: () {
                      final curr = ref.read(observationReportProvider).customPhysicalExamFields;
                      ref
                          .read(observationReportProvider.notifier)
                          .updateCustomPhysicalExamFields(
                            curr.where((f) => f.key != field.key).toList(),
                          );
                      //Also clear the data
                      final currData = Map<String, String>.from(
                        ref.read(observationReportProvider).physicalExam,
                      );
                      currData.remove(field.key);
                      ref.read(observationReportProvider.notifier).updatePhysicalExam(currData);
                    },
                  )
                else
                  TextButton(
                    onPressed: () {
                      final currData = ref.read(observationReportProvider).physicalExam;
                      String valueToSet = field.normalText;
                      if (!valueToSet.startsWith('[{')) {
                        valueToSet = jsonEncode([
                          {"insert": "$valueToSet\n"},
                        ]);
                      }
                      ref.read(observationReportProvider.notifier).updatePhysicalExam({
                        ...currData,
                        field.key: valueToSet,
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: theme.primaryColor.withOpacity(0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Normal',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          QuillInputField(
            fieldKey: field.key,
            label: '',
            initialValue: examData[field.key] ?? '',
            hint: field.localizationKey != null
                ? _getLocalizedHint(context, field.localizationKey!)
                : field.normalText,
            dense: true,
            onChanged: (value) {
              final currData = ref.read(observationReportProvider).physicalExam;
              ref.read(observationReportProvider.notifier).updatePhysicalExam({
                ...currData,
                field.key: value,
              });
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showAddFieldDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    String label = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.newExamSectionTitle),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.newSectionHint,
          ),
          onChanged: (val) => label = val,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              if (label.trim().isEmpty) return;
              final key = 'custom_${DateTime.now().millisecondsSinceEpoch}';
              final newField = ExamFieldConfig(
                key: key,
                label: label.trim(),
                normalText: 'Normal',
              );
              final curr = ref.read(observationReportProvider).customPhysicalExamFields;
              ref.read(observationReportProvider.notifier).updateCustomPhysicalExamFields([
                ...curr,
                newField,
              ]);
              Navigator.pop(context);
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'exam_general_state':
        return l10n.exam_general_state_label;
      case 'exam_hydration':
        return l10n.exam_hydration_label;
      case 'exam_head_neck':
        return l10n.exam_head_neck_label;
      case 'exam_respiratory':
        return l10n.exam_respiratory_label;
      case 'exam_cardio':
        return l10n.exam_cardio_label;
      case 'exam_abdominal':
        return l10n.exam_abdominal_label;
      case 'exam_urogenital':
        return l10n.exam_urogenital_label;
      case 'exam_locomotor':
        return l10n.exam_locomotor_label;
      case 'exam_neuro_mental':
        return l10n.exam_neuro_mental_label;
      case 'exam_skin':
        return l10n.exam_skin_label;
      case 'exam_cardio_edema':
        return l10n.exam_cardio_edema_label;
      case 'exam_cardio_cyanosis':
        return l10n.exam_cardio_cyanosis_label;
      case 'exam_neuro_glasgow':
        return l10n.exam_neuro_glasgow_label;
      case 'exam_neuro_orient':
        return l10n.exam_neuro_orient_label;
      default:
        return key;
    }
  }

  String _getLocalizedHint(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'exam_general_state':
        return l10n.exam_general_state_hint;
      case 'exam_hydration':
        return l10n.exam_hydration_hint;
      case 'exam_head_neck':
        return l10n.exam_head_neck_hint;
      case 'exam_respiratory':
        return l10n.exam_respiratory_hint;
      case 'exam_cardio':
        return l10n.exam_cardio_hint;
      case 'exam_abdominal':
        return l10n.exam_abdominal_hint;
      case 'exam_urogenital':
        return l10n.exam_urogenital_hint;
      case 'exam_locomotor':
        return l10n.exam_locomotor_hint;
      case 'exam_neuro_mental':
        return l10n.exam_neuro_mental_hint;
      case 'exam_skin':
        return l10n.exam_skin_hint;
      case 'exam_cardio_edema':
        return l10n.exam_cardio_edema_hint;
      case 'exam_cardio_cyanosis':
        return l10n.exam_cardio_cyanosis_hint;
      case 'exam_neuro_glasgow':
        return l10n.exam_neuro_glasgow_hint;
      case 'exam_neuro_orient':
        return l10n.exam_neuro_orient_hint;
      default:
        return '';
    }
  }
}

class _IntroductionForm extends ConsumerWidget {
  const _IntroductionForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intro = ref.watch(introductionDataProvider);
    final patient = ref.watch(patientInfoProvider);

    final genderSuffix = patient.gender.toLowerCase().contains('f') ? 'e' : '';
    final name = patient.name;

    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
        ),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 12,
        children: [
          _buildText(l10n.intro_patient_prefix),
          if (genderSuffix.isNotEmpty) _buildText(genderSuffix),
          _InlineField(
            value: name,
            hint: l10n.intro_patient_name_hint,
            onChanged: (val) => ref.read(observationReportProvider.notifier).updatePatientInfo(
                  patient.copyWith(name: val),
                ),
          ),
          _buildText(
            patient.gender.toLowerCase().contains('f')
                ? l10n.intro_age_label_feminine
                : l10n.intro_age_label_masculine,
          ),
          _buildText(l10n.intro_age_prefix.trim()),
          _InlineField(
            value: patient.age,
            hint: l10n.intro_age_hint,
            onChanged: (val) => ref.read(observationReportProvider.notifier).updatePatientInfo(
                  patient.copyWith(age: val),
                ),
          ),
          _buildText(l10n.intro_origin_prefix.trim()),
          _InlineField(
            value: intro.origin,
            hint: l10n.intro_origin_hint,
            onChanged: (val) =>
                ref.read(observationReportProvider.notifier).updateIntroductionData(
                      intro.copyWith(origin: val),
                    ),
          ),
          _buildText(". "),
          _InlineField(
            value: intro.maritalStatus,
            hint: l10n.intro_marital_status_hint,
            onChanged: (val) =>
                ref.read(observationReportProvider.notifier).updateIntroductionData(
                      intro.copyWith(maritalStatus: val),
                    ),
          ),
          _InlineField(
            value: intro.profession,
            hint: l10n.intro_profession_hint,
            onChanged: (val) =>
                ref.read(observationReportProvider.notifier).updateIntroductionData(
                      intro.copyWith(profession: val),
                    ),
          ),
          _buildText(
            patient.gender.toLowerCase().contains('f')
                ? l10n.intro_admitted_feminine
                : l10n.intro_admitted_masculine,
          ),
          _buildText(l10n.intro_date_prefix.trim()),
          _InlineField(
            value: intro.admissionDate,
            hint: l10n.intro_date_hint,
            onChanged: (val) =>
                ref.read(observationReportProvider.notifier).updateIntroductionData(
                      intro.copyWith(admissionDate: val),
                    ),
          ),
          _buildText(l10n.intro_for_prefix.trim()),
          _InlineField(
            value: intro.signs,
            hint: l10n.intro_signs_hint,
            isLong: true,
            onChanged: (val) =>
                ref.read(observationReportProvider.notifier).updateIntroductionData(
                      intro.copyWith(signs: val),
                    ),
          ),
          _buildText("."),
        ],
      ),
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
    );
  }
}

class _InlineField extends StatefulWidget {
  final String value;
  final String hint;
  final ValueChanged<String> onChanged;
  final bool isLong;

  const _InlineField({
    required this.value,
    required this.hint,
    required this.onChanged,
    this.isLong = false,
  });

  @override
  State<_InlineField> createState() => _InlineFieldState();
}

class _InlineFieldState extends State<_InlineField> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void didUpdateWidget(covariant _InlineField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFilled = widget.value.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: _isFocused
            ? theme.primaryColor.withOpacity(0.05)
            : isFilled
            ? theme.primaryColor.withOpacity(0.03)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isFocused
              ? theme.primaryColor
              : isFilled
              ? theme.primaryColor.withOpacity(0.3)
              : theme.dividerColor,
          width: _isFocused ? 1.5 : 1,
        ),
      ),
      child: IntrinsicWidth(
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isFilled ? theme.primaryColor : theme.hintColor,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: widget.hint,
            contentPadding: const EdgeInsets.symmetric(vertical: 6),
            constraints: BoxConstraints(
              minWidth: 60,
              maxWidth: widget.isLong ? 300 : 150,
            ),
            hintStyle: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
              color: theme.hintColor.withOpacity(0.4),
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

class _MotifHospitalisationForm extends ConsumerWidget {
  const _MotifHospitalisationForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final motif = ref.watch(motifHospitalisationProvider);

    return QuillInputField(
      label: '',
      initialValue: motif,
      onChanged: (value) {
        ref.read(observationReportProvider.notifier).updateMotifHospitalisation(value);
      },
    );
  }
}

class _HistoireMaladieForm extends ConsumerWidget {
  const _HistoireMaladieForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final histoire = ref.watch(histoireMaladieProvider);

    return QuillInputField(
      label: '',
      initialValue: histoire,
      onChanged: (value) {
        ref.read(observationReportProvider.notifier).updateHistoireMaladie(value);
      },
    );
  }
}

class _AntecedentsForm extends ConsumerWidget {
  const _AntecedentsForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ant = ref.watch(antecedentsProvider);

    return Column(
      children: [
        QuillInputField(
          label: 'Médicaux',
          initialValue: ant.medicaux,
          onChanged: (val) {
            ref.read(observationReportProvider.notifier).updateAntecedents(
                  ant.copyWith(medicaux: val),
                );
          },
        ),
        const SizedBox(height: 12),
        QuillInputField(
          label: 'Chirurgicaux',
          initialValue: ant.chirurgicaux,
          onChanged: (val) {
            ref.read(observationReportProvider.notifier).updateAntecedents(
                  ant.copyWith(chirurgicaux: val),
                );
          },
        ),
        const SizedBox(height: 12),
        QuillInputField(
          label: 'Familiaux',
          initialValue: ant.familiaux,
          onChanged: (val) {
            ref.read(observationReportProvider.notifier).updateAntecedents(
                  ant.copyWith(familiaux: val),
                );
          },
        ),
        const SizedBox(height: 12),
        QuillInputField(
          label: 'Gynéco-Obstétriques(Si applicable)',
          initialValue: ant.gynecoObstetriques,
          onChanged: (val) {
            ref.read(observationReportProvider.notifier).updateAntecedents(
                  ant.copyWith(gynecoObstetriques: val),
                );
          },
        ),
        const SizedBox(height: 12),
        QuillInputField(
          label: 'Mode de Vie/Habitudes',
          initialValue: ant.modeDeVie,
          onChanged: (val) {
            ref.read(observationReportProvider.notifier).updateAntecedents(
                  ant.copyWith(modeDeVie: val),
                );
          },
        ),
      ],
    );
  }
}

class _ParacliniqueForm extends ConsumerStatefulWidget {
  const _ParacliniqueForm();

  @override
  ConsumerState<_ParacliniqueForm> createState() => _ParacliniqueFormState();
}

class _ParacliniqueFormState extends ConsumerState<_ParacliniqueForm> {
  final List<String> _examTypes = [
    'ECG',
    'Échographie(ETT)',
    'Échographie(Abdominale)',
    'Radiographie Standard(RX)',
    'Scanner(TDM)',
    'IRM',
    'Bilan Biologique(FNS,Rénal,Hépathique,etc.)',
    'Gazométrie(GDS)',
    'Troponine',
    'Autre...',
  ];

  String? _selectedExamType;

  List<ExamParameter> _getDefaultParameters(String type) {
    List<String> names = [];
    switch (type) {
      case 'ECG':
        names = [
          'Rythme',
          'Axe',
          'Onde P',
          'PR',
          'QRS',
          'QT',
          'Segment ST',
          'Onde T',
          'Conclusion',
        ];
        break;
      case 'Échographie(ETT)':
        names = [
          'VG(Taille/Fonction)',
          'FE(%)',
          'Cinétique segmentaire',
          'PRVG',
          'OG/OD',
          'VD',
          'VCI',
          'Péricarde',
          'Valves',
          'Conclusion',
        ];
        break;
      case 'Bilan Biologique(FNS,Rénal,Hépathique,etc.)':
        names = [
          'Hb',
          'GB',
          'PLQ',
          'Urée',
          'Créatinine',
          'Clairance',
          'Glycémie',
          'HbA1c',
          'CRP',
          'Na+',
          'K+',
          'TP/INR',
          'TCA',
          'Bilan hépatique',
        ];
        break;
      case 'Gazométrie(GDS)':
        names = ['pH', 'PaO2', 'PaCO2', 'HCO3-', 'Lactates', 'SaO2'];
        break;
      case 'Troponine':
        names = ['1er dosage', '2ème dosage'];
        break;
      default:
        names = ['Résultat'];
    }
    return names
        .map(
          (n) =>
              ExamParameter(key: n.toLowerCase().replaceAll(' ', '_'), name: n),
        )
        .toList();
  }

  void _addExam(String title) {
    if (title.isEmpty) return;
    final exams = ref.read(observationReportProvider).paracliniqueExams;
    ref.read(observationReportProvider.notifier).updateParacliniqueExams([
      ...exams,
      ParaclinicalExam(title: title, parameters: _getDefaultParameters(title)),
    ]);
  }

  void _removeExam(int index) {
    final exams = ref.read(observationReportProvider).paracliniqueExams;
    final newExams = List<ParaclinicalExam>.from(exams);
    newExams.removeAt(index);
    ref.read(observationReportProvider.notifier).updateParacliniqueExams(newExams);
  }

  void _updateExamParameter(int examIndex, int paramIndex, String newValue) {
    final exams = ref.read(observationReportProvider).paracliniqueExams;
    final newExams = List<ParaclinicalExam>.from(exams);
    final newParams = List<ExamParameter>.from(newExams[examIndex].parameters);
    newParams[paramIndex] = newParams[paramIndex].copyWith(value: newValue);
    newExams[examIndex] = newExams[examIndex].copyWith(parameters: newParams);
    ref.read(observationReportProvider.notifier).updateParacliniqueExams(newExams);
  }

  void _addParameterToExam(int examIndex, String paramName) {
    if (paramName.isEmpty) return;
    final exams = ref.read(observationReportProvider).paracliniqueExams;
    final newExams = List<ParaclinicalExam>.from(exams);
    final newParams = List<ExamParameter>.from(newExams[examIndex].parameters);
    newParams.add(
      ExamParameter(
        key:
            '${paramName.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}',
        name: paramName,
      ),
    );
    newExams[examIndex] = newExams[examIndex].copyWith(parameters: newParams);
    ref.read(observationReportProvider.notifier).updateParacliniqueExams(newExams);
  }

  void _removeParameterFromExam(int examIndex, int paramIndex) {
    final exams = ref.read(observationReportProvider).paracliniqueExams;
    final newExams = List<ParaclinicalExam>.from(exams);
    final newParams = List<ExamParameter>.from(newExams[examIndex].parameters);
    newParams.removeAt(paramIndex);
    newExams[examIndex] = newExams[examIndex].copyWith(parameters: newParams);
    ref.read(observationReportProvider.notifier).updateParacliniqueExams(newExams);
  }

  void _reorderParameterInExam(int examIndex, int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final exams = ref.read(observationReportProvider).paracliniqueExams;
    final newExams = List<ParaclinicalExam>.from(exams);
    final newParams = List<ExamParameter>.from(newExams[examIndex].parameters);
    final item = newParams.removeAt(oldIndex);
    newParams.insert(newIndex, item);
    newExams[examIndex] = newExams[examIndex].copyWith(parameters: newParams);
    ref.read(observationReportProvider.notifier).updateParacliniqueExams(newExams);
  }

  @override
  Widget build(BuildContext context) {
    final paracliniqueExams = ref.watch(paracliniqueExamsProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //List of currently added exams
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: paracliniqueExams.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final exam = paracliniqueExams[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.primaryColor.withOpacity(0.1)),
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
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Iconsax.document_text,
                          size: 18,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          exam.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor.withOpacity(0.9),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Iconsax.trash,
                          color: Colors.red,
                          size: 18,
                        ),
                        onPressed: () => _removeExam(index),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: exam.parameters.length,
                    onReorder: (oldIndex, newIndex) =>
                        _reorderParameterInExam(index, oldIndex, newIndex),
                    itemBuilder: (context, paramIndex) {
                      final param = exam.parameters[paramIndex];
                      return Padding(
                        key: ValueKey(param.key),
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: ReorderableDragStartListener(
                                index: paramIndex,
                                child: Icon(
                                  Icons.drag_indicator,
                                  color: theme.hintColor.withOpacity(0.3),
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: QuillInputField(
                                label: param.name,
                                initialValue: param.value,
                                dense: true,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: theme.primaryColor.withOpacity(0.6),
                                ),
                                onChanged: (value) => _updateExamParameter(
                                  index,
                                  paramIndex,
                                  value,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: theme.hintColor.withOpacity(0.4),
                                  size: 18,
                                ),
                                onPressed: () =>
                                    _removeParameterFromExam(index, paramIndex),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 40),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            String paramName = '';
                            final l10n = AppLocalizations.of(context)!;
                            return AlertDialog(
                              title: Text(l10n.addParameter),
                              content: TextField(
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: l10n.parameterNameHint,
                                ),
                                onChanged: (value) => paramName = value,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(l10n.cancel),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _addParameterToExam(index, paramName);
                                  },
                                  child: Text(l10n.addParameter),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(
                        AppLocalizations.of(context)!.addParameter,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (paracliniqueExams.isNotEmpty) const SizedBox(height: 16),
        //Add Exam Section
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.addExam,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _selectedExamType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      hint: Text(
                        AppLocalizations.of(context)!.selectExamHint,
                        style: const TextStyle(fontSize: 12),
                      ), //Using selectSpecialty as a fallback hint if no generic"select type"exists or just create one.Actually let's use a generic one if I missed it.
                      //Wait,I didn't add a specific hint for"Select type",let's use something generic or I'll add it later.
                      //For now,I'll use"Sélectionner un type..."but I should have localized it.
                      //Let's assume I did't add"selectType"yet.
                      //I'll stick to a hardcoded one for one second or add it to ARB.
                      //Actually let's add"selectTypeHint"to ARB too.
                      //But I already called multi_replace_file_content for ARB.
                      //I'll use a hardcoded one for now or just use one of the existing ones.
                      //Let's just use"selectSpecialty".
                      items: _examTypes.map((type) {
                        final displayLabel = type == 'Autre...'
                            ? AppLocalizations.of(context)!.otherOption
                            : type;
                        return DropdownMenuItem(value: type, child: Text(displayLabel));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedExamType = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _selectedExamType == null
                        ? null
                        : () {
                            if (_selectedExamType == 'Autre...') {
                              //Ask for custom name
                              final l10n = AppLocalizations.of(context)!;
                              showDialog(
                                context: context,
                                builder: (context) {
                                  String customName = '';
                                  return AlertDialog(
                                    title: Text(l10n.examNameTitle),
                                    content: TextField(
                                      autofocus: true,
                                      decoration: InputDecoration(
                                        hintText: l10n.pelvicUltrasoundExample,
                                      ),
                                      onChanged: (value) => customName = value,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(l10n.cancel),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _addExam(customName);
                                          setState(
                                            () => _selectedExamType = null,
                                          );
                                        },
                                        child: Text(l10n.add),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              _addExam(_selectedExamType!);
                              setState(() => _selectedExamType = null);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResumeTotalForm extends ConsumerWidget {
  const _ResumeTotalForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resume = ref.watch(resumeTotalProvider);

    return QuillInputField(
      label: '',
      initialValue: resume,
      onChanged: (value) {
        ref.read(observationReportProvider.notifier).updateResumeTotal(value);
      },
    );
  }
}

class _AssessmentForm extends ConsumerWidget {
  const _AssessmentForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessment = ref.watch(assessmentAndPlanProvider);

    return QuillInputField(
      label: '',
      initialValue: assessment,
      onChanged: (value) {
        ref.read(observationReportProvider.notifier).updateAssessmentAndPlan(value);
      },
    );
  }
}

String getPlainText(String jsonStr) {
  if (jsonStr.isEmpty) return '';
  try {
    final doc = Document.fromJson(jsonDecode(jsonStr));
    return doc.toPlainText().trim();
  } catch (e) {
    return jsonStr;
  }
}
