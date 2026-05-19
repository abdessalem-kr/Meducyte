import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/observation/data/models/specialty_config.dart';

class ClinicalTemplatePicker extends StatelessWidget {
  final Function(String) onSelect;

  const ClinicalTemplatePicker({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    //List of specialties to show in the picker
    final specs = [
      SpecialtyConfigs.general,
      SpecialtyConfigs.cardiology,
      SpecialtyConfigs.neurology,
      SpecialtyConfigs.dermatologieetvenereologie,
      SpecialtyConfigs.diabetologieendocrinologieetmaladiesmetaboliques,
      SpecialtyConfigs.hepatogastroenterologie,
      SpecialtyConfigs.hematologie,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(
                  Iconsax.document_text,
                  color: theme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.clinicalCases, //Using"Clinical Cases"as title
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: specs.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final spec = specs[index];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(spec.icon, color: AppColors.primary, size: 22),
                  ),
                  title: Text(
                    spec.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Iconsax.add_circle, size: 20),
                  onTap: () {
                    final template = _generateTemplate(spec, l10n);
                    onSelect(template);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  String _generateTemplate(SpecialtyFormConfig config, AppLocalizations l10n) {
    final buffer = StringBuffer();
    buffer.writeln("**[Oobservation- ${config.title}]**");
    buffer.writeln("${l10n.intro_patient_prefix} :");
    buffer.writeln("${l10n.intro_age_hint} :");
    buffer.writeln("${l10n.gender} :");
    buffer.writeln("${l10n.section_motif} :");
    buffer.writeln("\n**${l10n.section_general_vitals}**");
    buffer.writeln("- ${l10n.vitals_bp} :");
    buffer.writeln("- ${l10n.vitals_hr} :");
    buffer.writeln("- ${l10n.vitals_temp} :");
    buffer.writeln("\n**Examen Clinique**");
    for (var field in config.examFields.take(3)) {
      buffer.writeln("- ${field.label} : ");
    }
    buffer.writeln(
      "\n*AI Assistant:Please analyze this clinical case and suggest a differential diagnosis.*",
    );
    return buffer.toString();
  }
}
