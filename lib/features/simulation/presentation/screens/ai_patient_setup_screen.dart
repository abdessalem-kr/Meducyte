import 'package:meducyte_app/export.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:meducyte_app/features/simulation/domain/models/simulation_models.dart';
import 'package:meducyte_app/features/simulation/presentation/providers/simulation_providers.dart';

class AiPatientSetupScreen extends ConsumerStatefulWidget {
  const AiPatientSetupScreen({super.key});

  @override
  ConsumerState<AiPatientSetupScreen> createState() => _AiPatientSetupScreenState();
}

class _AiPatientSetupScreenState extends ConsumerState<AiPatientSetupScreen> {
  int _currentStep = 0;
  
  // Step 1: Specialty
  LearnModule? _selectedModule;
  
  // Step 2: Case Selection
  SimCaseSummary? _selectedCase;
  String _caseSearchQuery = "";
  final TextEditingController _caseSearchController = TextEditingController();
  
  // Step 3: Simulation Environment
  SimulationSetting _selectedSetting = SimulationSetting.emergencyRoom;
  SimulationDifficulty _selectedDifficulty = SimulationDifficulty.resident;

  @override
  void dispose() {
    _caseSearchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final modulesAsync = ref.watch(learnModulesProvider);
    final casesAsync = ref.watch(simCasesProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_getStepTitle(l10n).toUpperCase()),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: _currentStep > 0 
          ? IconButton(
              icon: const Icon(Iconsax.arrow_left),
              onPressed: () => setState(() => _currentStep--),
            )
          : null,
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildStepContent(modulesAsync, casesAsync),
              ),
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  String _getStepTitle(AppLocalizations l10n) {
    return switch (_currentStep) {
      0 => l10n.simCurriculumFocus,
      1 => l10n.simCaseSelection,
      2 => l10n.simClinicalSetting,
      3 => l10n.simFinalBriefing,
      _ => "Setup",
    };
  }

  Widget _buildProgressBar() {
    return Container(
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(AsyncValue<List<LearnModule>> modulesAsync, AsyncValue<List<SimCaseSummary>> casesAsync) {
    final l10n = AppLocalizations.of(context)!;
    return switch (_currentStep) {
      0 => _buildSpecialtyStep(modulesAsync, l10n),
      1 => _buildCaseStep(casesAsync, l10n),
      2 => _buildEnvironmentStep(l10n),
      3 => _buildBriefingStep(l10n),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildSpecialtyStep(AsyncValue<List<LearnModule>> modulesAsync, AppLocalizations l10n) {
    return modulesAsync.when(
      data: (modules) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.simChooseModuleDesc,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemCount: modules.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = _selectedModule == null;
                  return _buildSelectionCard(
                    title: l10n.simAllSpecialties,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedModule = null),
                    icon: Iconsax.category,
                  );
                }
                final module = modules[index - 1];
                final isSelected = _selectedModule?.id == module.id;
                return _buildSelectionCard(
                  title: module.name,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedModule = module),
                  icon: Iconsax.book,
                );
              },
            ),
          ],
        );
      },
      loading: () => Skeletonizer(
        enabled: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.simChooseModuleDesc,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return _buildSelectionCard(
                  title: "Module de spécialité médicale factice",
                  isSelected: false,
                  onTap: () {},
                  icon: Iconsax.book,
                );
              },
            ),
          ],
        ),
      ),
      error: (e, s) => Center(child: Text("Error loading curriculum: $e")),
    );
  }

  Widget _buildCaseStep(AsyncValue<List<SimCaseSummary>> casesAsync, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return casesAsync.when(
      data: (allCases) {
        // Filter by module and search query
        final pathologies = allCases.where((c) {
          final matchesModule = _selectedModule == null || c.moduleName == _selectedModule?.name;
          final matchesSearch = c.targetPathology.toLowerCase().contains(_caseSearchQuery.toLowerCase()) || 
                              c.summary.toLowerCase().contains(_caseSearchQuery.toLowerCase());
          return matchesModule && matchesSearch;
        }).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(l10n.simChooseClinicalCase),
            const SizedBox(height: 16),
            TextField(
              controller: _caseSearchController,
              onChanged: (val) => setState(() => _caseSearchQuery = val),
              decoration: InputDecoration(
                hintText: l10n.simSearchPathology,
                prefixIcon: const Icon(Iconsax.search_normal, size: 20),
                suffixIcon: _caseSearchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Iconsax.close_circle, size: 20),
                      onPressed: () {
                        _caseSearchController.clear();
                        setState(() => _caseSearchQuery = "");
                      },
                    )
                  : null,
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            if (pathologies.isEmpty)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const Icon(Iconsax.info_circle, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(l10n.simNoCasesFound),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pathologies.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final p = pathologies[index];
                  final isSelected = _selectedCase?.pathologyId == p.pathologyId;
                  return _buildSelectionCard(
                    title: p.targetPathology,
                    subtitle: p.summary,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedCase = p),
                    icon: Iconsax.personalcard,
                  );
                },
              ),
          ],
        );
      },
      loading: () => Skeletonizer(
        enabled: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(l10n.simChooseClinicalCase),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: l10n.simSearchPathology,
                prefixIcon: const Icon(Iconsax.search_normal, size: 20),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildSelectionCard(
                  title: "Cas clinique de pathologie factice",
                  subtitle: "Description synthétique et résumé succinct du cas clinique factice pour le chargement.",
                  isSelected: false,
                  onTap: () {},
                  icon: Iconsax.personalcard,
                );
              },
            ),
          ],
        ),
      ),
      error: (e, s) => Center(child: Text("Error loading cases: $e")),
    );
  }

  Widget _buildEnvironmentStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(l10n.simSimParameters),
        const SizedBox(height: 32),
        _buildSelectionTitle(l10n.simClinicalSetting),
        const SizedBox(height: 12),
        _buildSelectionCard(
          title: l10n.simEmergencyRoom,
          subtitle: l10n.simEmergencyRoomDesc,
          isSelected: _selectedSetting == SimulationSetting.emergencyRoom,
          onTap: () => setState(() => _selectedSetting = SimulationSetting.emergencyRoom),
          icon: Iconsax.flash,
        ),
        const SizedBox(height: 12),
        _buildSelectionCard(
          title: l10n.simOutpatientClinic,
          subtitle: l10n.simOutpatientClinicDesc,
          isSelected: _selectedSetting == SimulationSetting.outpatientClinic,
          onTap: () => setState(() => _selectedSetting = SimulationSetting.outpatientClinic),
          icon: Iconsax.house,
        ),
        const SizedBox(height: 32),
        _buildSelectionTitle(l10n.simSimDifficulty),
        const SizedBox(height: 12),
        Row(
          children: SimulationDifficulty.values.map((d) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildTabButton(
                  d.name.toUpperCase(),
                  _selectedDifficulty == d,
                  () => setState(() => _selectedDifficulty = d),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBriefingStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(l10n.simReadyToInitialize),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              _buildBriefingItem(Iconsax.personalcard, l10n.simCase, _selectedCase?.targetPathology ?? ""),
              _buildBriefingItem(Iconsax.location, l10n.simLocation, _selectedSetting == SimulationSetting.emergencyRoom ? l10n.simEmergencyRoom : l10n.simOutpatientClinic),
              _buildBriefingItem(Iconsax.award, l10n.simDifficulty, _selectedDifficulty.name.toUpperCase()),
              const Divider(height: 32),
              Text(
                l10n.simDemographicsPersonalityDesc,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.simEnterRoomDesc,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildBriefingItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSelectionCard({
    required String title,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Theme.of(context).dividerColor.withOpacity(0.05),
          ),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isSelected ? Colors.white70 : Colors.grey,
                        fontSize: 11,
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

  Widget _buildTabButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : Theme.of(context).dividerColor.withOpacity(0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSelectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12, letterSpacing: 1),
    );
  }

  Widget _buildNavigationButtons() {
    final isLastStep = _currentStep == 3;
    final canGoNext = switch (_currentStep) {
      0 => _selectedModule != null,
      1 => _selectedCase != null,
      _ => true,
    };

    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ElevatedButton(
        onPressed: canGoNext ? (isLastStep ? _startSimulation : () => setState(() => _currentStep++)) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
        child: Text(
          isLastStep ? l10n.simStartMission : l10n.simNextStep,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
    );
  }

  void _startSimulation() {
    if (_selectedCase == null) return;
    ref.read(simSessionProvider.notifier).startNewSession(
      pathologyId: _selectedCase!.pathologyId,
      difficulty: _selectedDifficulty,
      setting: _selectedSetting,
    );
    context.push(AppRoutes.aiPatientChat);
  }
}
