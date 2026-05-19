import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:meducyte_app/features/observation/data/models/specialty_config.dart';
import 'package:meducyte_app/features/observation/data/providers/pathology_assistant_provider.dart';

class PathologyFocusSelector extends ConsumerWidget {
  final SpecialtyFormConfig config;

  const PathologyFocusSelector({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedPathology = ref.watch(selectedPathologyProvider);
    final pathologiesAsync = ref.watch(suggestedPathologiesProvider(config));

    return pathologiesAsync.when(
      data: (pathologies) {
        if (pathologies.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Row(
                children: [
                  Icon(Iconsax.radar, size: 14, color: theme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    "FOCUS DIAGNOSTIQUE(INTERNE)",
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  //General Exam chip
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: selectedPathology == null,
                      label: const Text("Examen Standard"),
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(selectedPathologyProvider.notifier).state =
                              null;
                        }
                      },
                      selectedColor: theme.primaryColor.withOpacity(0.1),
                      checkmarkColor: theme.primaryColor,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: selectedPathology == null
                            ? FontWeight.bold
                            : null,
                        color: selectedPathology == null
                            ? theme.primaryColor
                            : null,
                      ),
                    ),
                  ),
                  //Pathology specific chips
                  ...pathologies.map((pathology) {
                    final isSelected =
                        selectedPathology?.name == pathology.name;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(pathology.name),
                        onSelected: (selected) {
                          ref.read(selectedPathologyProvider.notifier).state =
                              selected ? pathology : null;
                        },
                        selectedColor: Colors.purple.withOpacity(0.1),
                        checkmarkColor: Colors.purple,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : null,
                          color: isSelected ? Colors.purple : null,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: LinearProgressIndicator(minHeight: 2),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
