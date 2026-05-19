import 'package:meducyte_app/export.dart';
import 'package:flutter/services.dart';
import 'package:meducyte_app/features/simulation/domain/models/simulation_models.dart';
import 'package:meducyte_app/features/simulation/presentation/providers/simulation_providers.dart';
import 'package:meducyte_app/features/simulation/presentation/widgets/vitals_monitor.dart';
import 'package:meducyte_app/features/simulation/presentation/widgets/interview_tab.dart';
import 'package:meducyte_app/features/simulation/presentation/widgets/exam_tab.dart';
import 'package:meducyte_app/features/simulation/presentation/widgets/labs_tab.dart';
import 'package:meducyte_app/features/simulation/presentation/widgets/result_screen.dart';

class AiPatientSimScreen extends ConsumerStatefulWidget {
  const AiPatientSimScreen({super.key});

  @override
  ConsumerState<AiPatientSimScreen> createState() => _AiPatientSimScreenState();
}

class _AiPatientSimScreenState extends ConsumerState<AiPatientSimScreen> {
  double _fontSizeMultiplier = 1.0;
  bool _isHighContrast = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sessionAsync = ref.watch(simSessionProvider);
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(l10n.dashboardHub.toUpperCase()),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left_2),
            onPressed: () => context.go(AppRoutes.home),
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.simInterview.toUpperCase(), icon: const Icon(Iconsax.message, size: 18)),
              Tab(text: l10n.simExam.toUpperCase(), icon: const Icon(Iconsax.user_search, size: 18)),
              Tab(text: l10n.simLabs.toUpperCase(), icon: const Icon(Iconsax.document_filter, size: 18)),
            ],
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Iconsax.more),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onSelected: (value) => _handleMenuAction(value, sessionAsync),
              itemBuilder: (context) => _buildMenuItems(context, l10n),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Theme(
          data: _isHighContrast
              ? ThemeData.dark().copyWith(
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark, surface: Colors.black),
                  scaffoldBackgroundColor: Colors.black,
                )
              : Theme.of(context),
          child: DefaultTextStyle.merge(
            style: TextStyle(fontSize: 14 * _fontSizeMultiplier),
            child: sessionAsync.when(
              data: (session) => _buildSessionContent(context, session),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text("Error: $e")),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionContent(BuildContext context, SimSession session) {
    if (session.isFinished) {
      return SimResultScreen(session: session);
    }

    return Column(
      children: [
        VitalsMonitor(vitals: session.patientCase.initialVitals),
        Expanded(
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              InterviewTab(session: session),
              ExamTab(session: session),
              LabsTab(session: session),
            ],
          ),
        ),
        _buildControlPanel(context),
      ],
    );
  }

  Widget _buildControlPanel(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showDiagnosisDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(AppLocalizations.of(context)!.simSubmitFinalDiagnosis, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Dialogs and Helpers ---

  void _handleMenuAction(String value, AsyncValue<SimSession> sessionAsync) {
    switch (value) {
      case 'restart':
        ref.invalidate(simSessionProvider);
        Navigator.pop(context);
        break;
      case 'briefing':
        _showCaseBriefing(context, sessionAsync.value?.patientCase);
        break;
      case 'tutor':
        _showAITutor(context);
        break;
      case 'textSize':
        _toggleTextSize();
        break;
      case 'contrast':
        setState(() => _isHighContrast = !_isHighContrast);
        break;
      case 'report':
        _generateClinicalReport(sessionAsync.value);
        break;
      case 'export':
        _exportSessionLog(sessionAsync.value);
        break;
      case 'bug':
        _showBugReportDialog(context, sessionAsync.value);
        break;
      case 'diff':
        _showDifferentialInput(context);
        break;
    }
  }

  List<PopupMenuEntry<String>> _buildMenuItems(BuildContext context, AppLocalizations l10n) {
    return [
      PopupMenuItem(value: 'briefing', child: Row(children: [const Icon(Iconsax.info_circle, size: 18), const SizedBox(width: 12), Text(l10n.simPatientBriefing)])),
      PopupMenuItem(value: 'diff', child: Row(children: [const Icon(Iconsax.edit_2, size: 18), const SizedBox(width: 12), Text(l10n.simDifferentialChecklist)])),
      const PopupMenuDivider(),
      PopupMenuItem(value: 'report', child: Row(children: [const Icon(Iconsax.document_text, size: 18), const SizedBox(width: 12), Text(l10n.simClinicalObservation)])),
      PopupMenuItem(value: 'export', child: Row(children: [const Icon(Iconsax.document_download, size: 18), const SizedBox(width: 12), Text(l10n.printLesson)])),
      PopupMenuItem(value: 'bug', child: Row(children: [const Icon(Iconsax.danger, size: 18, color: Colors.orange), const SizedBox(width: 12), Text(l10n.simReportProblem, style: const TextStyle(color: Colors.orange))])),
      const PopupMenuDivider(),
      PopupMenuItem(value: 'textSize', child: Row(children: [const Icon(Iconsax.text, size: 18), const SizedBox(width: 12), Text(l10n.simTextScaling)])),
      PopupMenuItem(value: 'contrast', child: Row(children: [Icon(_isHighContrast ? Iconsax.sun : Iconsax.moon, size: 18), const SizedBox(width: 12), Text(_isHighContrast ? l10n.themeMode : l10n.simHighContrastMode)])),
      const PopupMenuDivider(),
      PopupMenuItem(value: 'restart', child: Row(children: [Icon(Iconsax.refresh, size: 18, color: Theme.of(context).colorScheme.error), const SizedBox(width: 12), Text(l10n.resetData, style: TextStyle(color: Theme.of(context).colorScheme.error))])),
    ];
  }

  void _showDiagnosisDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.simFinalDiagnosis),
        content: TextField(controller: controller, decoration: InputDecoration(hintText: l10n.simEnterPathology), autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.simCancel)),
          ElevatedButton(
            onPressed: () {
              ref.read(simSessionProvider.notifier).submitDiagnosis(controller.text);
              Navigator.pop(context);
            },
            child: Text(l10n.simSubmit),
          ),
        ],
      ),
    );
  }

  void _toggleTextSize() {
    setState(() {
      if (_fontSizeMultiplier < 1.4) {
        _fontSizeMultiplier += 0.2;
      } else {
        _fontSizeMultiplier = 0.8;
      }
    });
  }

  void _showAITutor(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(simSessionProvider.notifier);
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.dividerColor.withOpacity(0.1), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Iconsax.teacher, color: Colors.amber), const SizedBox(width: 8), Text(l10n.simClinicalReasoningTutor, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12))]),
              const Divider(height: 32),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.amber.withOpacity(0.2))),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(l10n.simWelcomeDoctor, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                        const SizedBox(height: 8),
                        Text(l10n.simTutorHelp, style: const TextStyle(fontSize: 13, color: Colors.amber)),
                      ]),
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.simSuggestedQuestions, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 12),
                    _buildTutorSuggestion(l10n.simTutorDiff, notifier),
                    _buildTutorSuggestion(l10n.simTutorEcg, notifier),
                    _buildTutorSuggestion(l10n.simTutorManagement, notifier),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: l10n.simAskTutorHint,
                    suffixIcon: IconButton(icon: const Icon(Iconsax.send_1, color: AppColors.primary), onPressed: () { if (controller.text.isNotEmpty) { notifier.sendMessage("Tutor: ${controller.text}"); Navigator.pop(context); } }),
                    filled: true, fillColor: theme.cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (val) { if (val.isNotEmpty) { notifier.sendMessage("Tutor: $val"); Navigator.pop(context); } },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTutorSuggestion(String text, SimSessionNotifier notifier) {
    return GestureDetector(
      onTap: () { notifier.sendMessage("Tutor: $text"); Navigator.pop(context); },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05))),
        child: Text(text, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  void _showCaseBriefing(BuildContext context, PatientCase? patientCase) {
    if (patientCase == null) return;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Iconsax.info_circle, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(l10n.simPatientBriefing.toUpperCase(), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const Spacer(),
              IconButton(icon: const Icon(Iconsax.close_circle), onPressed: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 24),
            Text(l10n.simCaseSelection.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.hintColor, letterSpacing: 1)),
            const SizedBox(height: 8),
            Text(patientCase.mainComplaint, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildBriefingRow(l10n.section_history, patientCase.medicalHistory),
            _buildBriefingRow(l10n.intro_profession_hint, patientCase.occupation),
            _buildBriefingRow(l10n.intro_age_hint, "${patientCase.age} ${l10n.intro_age_label_masculine} ${patientCase.gender == 'M' ? l10n.gender_male : l10n.gender_female}"),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBriefingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  void _exportSessionLog(SimSession? session) {
    if (session == null) return;
    final log = session.messages.map((m) => "${m.isFromUser ? 'USER' : 'PATIENT'}: ${m.text}").join("\n\n");
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.simSessionExported),
        content: SingleChildScrollView(child: SelectableText(log)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.simClose))],
      ),
    );
  }

  void _showDifferentialInput(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.simDifferentialDiagnosis, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(maxLines: 5, decoration: InputDecoration(hintText: l10n.simListDifferentialsHint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)))),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: Text(l10n.simSaveList)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _generateClinicalReport(SimSession? session) {
    if (session == null) return;
    final patient = session.patientCase;
    final vitals = patient.initialVitals;
    final labs = session.messages.where((m) => m.text.startsWith('[LAB]')).toList();
    final exams = session.messages.where((m) => m.text.startsWith('[EXAM]')).toList();

    final buffer = StringBuffer();
    final l10n = AppLocalizations.of(context)!;
    buffer.writeln("${l10n.simClinicalObservationReport.toUpperCase()}- ${patient.targetPathology.toUpperCase()}");
    buffer.writeln("----------------------------------------\n");
    buffer.writeln("${l10n.intro_patient_prefix.toUpperCase()}:");
    buffer.writeln("- ${l10n.name}: ${patient.name}");
    buffer.writeln("- Identity: ${patient.age} ${l10n.intro_age_label_masculine} ${patient.gender == 'M' ? l10n.gender_male : l10n.gender_female}");
    buffer.writeln("- ${l10n.intro_profession_hint}: ${patient.occupation}");
    buffer.writeln("- ${l10n.section_motif}: ${patient.mainComplaint}\n");

    if (vitals != null) {
      buffer.writeln("${l10n.section_general_vitals.toUpperCase()}:");
      buffer.writeln("${l10n.vitals_temp}: ${vitals.temperature}°C, ${l10n.vitals_bp}: ${vitals.bloodPressure}mmHg, ${l10n.vitals_hr}: ${vitals.heartRate}bpm, ${l10n.vitals_spo2}: ${vitals.spo2}%\n");
    }

    if (exams.isNotEmpty) {
      buffer.writeln("CLINICAL FINDINGS:");
      for (var ex in exams) { buffer.writeln("- ${ex.text.replaceAll('[EXAM] ', '')}: ${ex.rawResult ?? 'Performed'}"); }
      buffer.writeln("");
    }

    if (labs.isNotEmpty) {
      buffer.writeln("${l10n.section_paraclinical.toUpperCase()}:");
      for (var lab in labs) { buffer.writeln("- ${lab.text.replaceAll('[LAB] ', '')}: ${lab.rawResult ?? 'Performed'}"); }
      buffer.writeln("");
    }

    buffer.writeln("IMPRESSION:");
    buffer.writeln("Suspicion of ${patient.targetPathology} based on clinical interaction.");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [const Icon(Iconsax.document_text, color: AppColors.primary), const SizedBox(width: 12), Text(l10n.simClinicalObservation)]),
        content: Container(
          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(child: SelectableText(buffer.toString(), style: const TextStyle(fontSize: 13, fontFamily: 'monospace'))),
        ),
        actions: [
          TextButton(
            onPressed: () { Clipboard.setData(ClipboardData(text: buffer.toString())); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.simObservationCopied))); },
            child: Text(l10n.simCopyAndClose),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog(BuildContext context, SimSession? session) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final vitals = session?.patientCase.initialVitals;
    final technicalInfo = session != null
        ? "Session ID: ${session.id}\n${l10n.simCase}: ${session.patientCase.targetPathology}\n${l10n.section_general_vitals}: ${vitals?.heartRate ?? 'N/A'} bpm, ${vitals?.bloodPressure ?? 'N/A'}"
        : l10n.noHistoryFound;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.simReportABug.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            Text(l10n.simDescribeIssue, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(maxLines: 4, decoration: InputDecoration(hintText: l10n.simDescribeIssueHint, filled: true, fillColor: theme.cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.1))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.simDiagnosticData, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(technicalInfo, style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.grey)),
              ]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.simReportSent))); },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: Text(l10n.simSubmitReport),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
