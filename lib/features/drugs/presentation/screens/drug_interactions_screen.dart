import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:meducyte_app/core/themes/app_colors.dart';
import 'package:meducyte_app/l10n/arb/app_localizations.dart';
import 'package:meducyte_app/features/drugs/data/providers/drug_providers.dart';
import 'package:meducyte_app/features/drugs/domain/models/drug_models.dart';

class DrugInteractionsScreen extends ConsumerWidget {
  const DrugInteractionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedDrugs = ref.watch(selectedDrugsProvider);
    final interactionsAsync = ref.watch(drugInteractionsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.drugInteractions),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: theme.textTheme.titleLarge?.color,
      ),
      body: Column(
        children: [
          //Selected Drugs Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.selectedDrugs,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddDrugBottomSheet(context, ref),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(AppLocalizations.of(context)!.addDrug),
                    ),
                  ],
                ),
                if (selectedDrugs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      AppLocalizations.of(context)!.noDrugsSelectedPrompt,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedDrugs.map((drug) {
                      return Chip(
                        label: Text(drug.name),
                        onDeleted: () {
                          ref
                              .read(selectedDrugsProvider.notifier)
                              .update(
                                (state) => state
                                    .where((d) => d.id != drug.id)
                                    .toList(),
                              );
                        },
                        deleteIcon: const Icon(Icons.close, size: 16),
                        backgroundColor: AppColors.primaryDark.withOpacity(0.1),
                        labelStyle: const TextStyle(
                          color: AppColors.primaryDark,
                        ),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          //Interactions List
          Expanded(
            child: interactionsAsync.when(
              data: (interactions) {
                if (selectedDrugs.length < 2) {
                  return _InteractionPlaceholder(
                    icon: Iconsax.info_circle,
                    text: AppLocalizations.of(context)!.selectTwoDrugsPrompt,
                  );
                }
                if (interactions.isEmpty) {
                  return _InteractionPlaceholder(
                    icon: Iconsax.tick_circle,
                    text: AppLocalizations.of(context)!.noInteractionsFound,
                    color: Colors.green,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: interactions.length,
                  itemBuilder: (context, index) {
                    final interaction = interactions[index];
                    return _InteractionCard(interaction: interaction);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDrugBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddDrugBottomSheet(),
    );
  }
}

class _InteractionPlaceholder extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _InteractionPlaceholder({
    required this.icon,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: color ?? theme.hintColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractionCard extends ConsumerWidget {
  final DrugInteraction interaction;

  const _InteractionCard({required this.interaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final drugs = ref.watch(selectedDrugsProvider);
    final drug1 = drugs.firstWhere((d) => d.id == interaction.drugId1).name;
    final drug2 = drugs.firstWhere((d) => d.id == interaction.drugId2).name;

    Color severityColor;
    String severityText;
    switch (interaction.severity) {
      case InteractionSeverity.severe:
        severityColor = Colors.red;
        severityText = AppLocalizations.of(context)!.severe;
        break;
      case InteractionSeverity.moderate:
        severityColor = Colors.orange;
        severityText = AppLocalizations.of(context)!.moderate;
        break;
      case InteractionSeverity.minor:
        severityColor = Colors.blue;
        severityText = AppLocalizations.of(context)!.minor;
      default:
        severityColor = theme.hintColor;
        severityText = '';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: severityColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  severityText.toUpperCase(),
                  style: TextStyle(
                    color: severityColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Iconsax.warning_2, size: 16, color: Colors.amber),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$drug1 vs$drug2',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(interaction.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.management,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: severityColor,
            ),
          ),
          Text(interaction.management, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _AddDrugBottomSheet extends ConsumerStatefulWidget {
  const _AddDrugBottomSheet();

  @override
  ConsumerState<_AddDrugBottomSheet> createState() =>
      _AddDrugBottomSheetState();
}

class _AddDrugBottomSheetState extends ConsumerState<_AddDrugBottomSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final drugSearchAsync = ref.watch(interactionDrugSearchProvider);
    final query = ref.watch(interactionSearchQueryProvider);
    final selectedDrugs = ref.watch(selectedDrugsProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      height: MediaQuery.of(context).size.height * 0.7,
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.addDrugToChecker,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  ref.read(interactionSearchQueryProvider.notifier).state =
                      value,
              autofocus: true,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchDrugHint,
                prefixIcon: const Icon(Iconsax.search_normal),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          ref
                                  .read(interactionSearchQueryProvider.notifier)
                                  .state =
                              '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: drugSearchAsync.when(
              data: (drugs) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: drugs.length,
                  itemBuilder: (context, index) {
                    final drug = drugs[index];
                    final isSelected = selectedDrugs.any(
                      (d) => d.id == drug.id,
                    );

                    return ListTile(
                      title: Text(drug.name),
                      subtitle: Text(drug.genericName),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.add_circle_outline),
                      onTap: () {
                        if (isSelected) {
                          ref
                              .read(selectedDrugsProvider.notifier)
                              .update(
                                (state) => state
                                    .where((d) => d.id != drug.id)
                                    .toList(),
                              );
                        } else {
                          ref
                              .read(selectedDrugsProvider.notifier)
                              .update((state) => [...state, drug]);
                        }
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
