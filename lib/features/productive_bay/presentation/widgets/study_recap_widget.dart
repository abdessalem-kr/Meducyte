import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/mastery_provider.dart';

class StudyRecapWidget extends ConsumerStatefulWidget {
  const StudyRecapWidget({super.key});

  @override
  ConsumerState<StudyRecapWidget> createState() => _StudyRecapWidgetState();
}

class _StudyRecapWidgetState extends ConsumerState<StudyRecapWidget> {
  int _confidence = 3;
  String _selectedSubject = 'Cardiologie';
  final TextEditingController _conceptController = TextEditingController();

  final List<String> _subjects = [
    'Cardiologie',
    'Neurologie',
    'Pneumologie',
    'Gastro-entérologie',
    'Rhumatologie',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final modulesAsync = ref.watch(learnModulesProvider);
    final subjects = modulesAsync.value?.map((m) => m.name).toList() ?? _subjects;
    if (subjects.isNotEmpty && !subjects.contains(_selectedSubject)) {
      _selectedSubject = subjects.first;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.edit, color: theme.primaryColor, size: 24),
              const SizedBox(width: 12),
              Text(
                context
                    .l10n
                    .finishSession, //I'll use a better key later if needed
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _selectedSubject,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: "Sujet d'étude",
              filled: true,
              fillColor: isDark
                  ? Colors.white10
                  : Colors.black.withOpacity(0.02),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            items: subjects
                .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s, overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: (val) => setState(() => _selectedSubject = val!),
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.confidenceLevelQuestion,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final score = index + 1;
              final isSelected = _confidence == score;
              return GestureDetector(
                onTap: () => setState(() => _confidence = score),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.primaryColor
                        : (isDark
                              ? Colors.white10
                              : Colors.black.withOpacity(0.05)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      score.toString(),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.difficultConceptQuestion,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _conceptController,
            decoration: InputDecoration(
              hintText: "Ex:Cycle de Krebs...",
              filled: true,
              fillColor: isDark
                  ? Colors.white10
                  : Colors.black.withOpacity(0.02),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref
                    .read(masteryProvider.notifier)
                    .addSessionResult(
                      subject: _selectedSubject,
                      confidence: _confidence,
                      difficultConcept: _conceptController.text,
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Séance de$_selectedSubject enregistrée"),
                  ),
                );
                _conceptController.clear();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(context.l10n.finishSession),
            ),
          ),
        ],
      ),
    );
  }
}
