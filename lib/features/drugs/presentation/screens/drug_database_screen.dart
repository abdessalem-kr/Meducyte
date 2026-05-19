import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/drugs/data/providers/drug_providers.dart';
import 'package:meducyte_app/features/drugs/domain/models/drug_models.dart';
import 'package:meducyte_app/features/drugs/presentation/screens/drug_details_screen.dart';

class DrugDatabaseScreen extends ConsumerStatefulWidget {
  const DrugDatabaseScreen({super.key});

  @override
  ConsumerState<DrugDatabaseScreen> createState() => _DrugDatabaseScreenState();
}

class _DrugDatabaseScreenState extends ConsumerState<DrugDatabaseScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final statsAsync = ref.watch(drugStatsProvider);

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(Iconsax.info_circle, color: AppColors.primaryDark),
                  const SizedBox(width: 10),
                  Text(AppLocalizations.of(context)!.databaseStatus),
                ],
              ),
              content: statsAsync.when(
                data: (stats) {
                  final total = stats['total'] ?? 0;
                  final enriched = stats['enriched'] ?? 0;
                  final molecules = stats['molecules'] ?? 0;
                  final percent = (total > 0)
                      ? (enriched / total * 100).toStringAsFixed(1)
                      : '0';

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StatRow(
                        label: AppLocalizations.of(context)!.registeredDrugs,
                        value: total.toString(),
                        icon: Iconsax.box,
                      ),
                      const Divider(),
                      _StatRow(
                        label: AppLocalizations.of(
                          context,
                        )!.uniqueDrugPrincipals,
                        value: molecules.toString(),
                        icon: Iconsax.mask,
                      ),
                      const Divider(),
                      _StatRow(
                        label: AppLocalizations.of(
                          context,
                        )!.enrichedClinicalInfos,
                        value: '$enriched($percent%)',
                        icon: Iconsax.tick_circle,
                        countColor: Colors.green,
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => Text('Erreur: $err'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.close),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final drugSearchAsync = ref.watch(drugSearchProvider);
    final query = ref.watch(drugSearchQueryProvider);
    final isSubscriber =
        ref.watch(authControllerProvider).value?.isSubscriber ?? false;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.drugDatabase),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: theme.textTheme.titleLarge?.color,
        actions: [
          IconButton(
            onPressed: () => _showStatsDialog(context),
            icon: const Icon(Iconsax.info_circle),
            tooltip: AppLocalizations.of(context)!.databaseStatistics,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) =>
                        ref.read(drugSearchQueryProvider.notifier).state =
                            value,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.searchHint,
                      prefixIcon: const Icon(Iconsax.search_normal),
                      suffixIcon: query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                        .read(drugSearchQueryProvider.notifier)
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
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showFilterBottomSheet(context),
                  icon: Stack(
                    children: [
                      const Icon(Iconsax.filter),
                      () {
                        int count = 0;
                        if (ref.watch(selectedCategoryProvider) != null) {
                          count++;
                        }
                        if (ref.watch(selectedTherapeuticClassProvider) !=
                            null) {
                          count++;
                        }
                        if (ref.watch(drugFilterEnrichedProvider)) count++;

                        if (count > 0) {
                          return Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryDark,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }(),
                    ],
                  ),
                  tooltip: AppLocalizations.of(context)!.filters,
                ),
                IconButton(
                  onPressed: () => _showSortBottomSheet(context),
                  icon: const Icon(Iconsax.sort),
                  tooltip: AppLocalizations.of(context)!.sortBy,
                ),
              ],
            ),
          ),
          //Category Filter
          ref
              .watch(categoriesProvider)
              .when(
                data: (categories) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _CategoryChip(
                          label: AppLocalizations.of(context)!.all,
                          isSelected:
                              ref.watch(selectedCategoryProvider) == null,
                          onTap: () {
                            ref.read(selectedCategoryProvider.notifier).state =
                                null;
                            ref
                                    .read(
                                      selectedTherapeuticClassProvider.notifier,
                                    )
                                    .state =
                                null;
                          },
                        ),
                        ...categories.map(
                          (cat) => Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: _CategoryChip(
                              label: cat,
                              isSelected:
                                  ref.watch(selectedCategoryProvider) == cat,
                              onTap: () {
                                ref
                                        .read(selectedCategoryProvider.notifier)
                                        .state =
                                    cat;
                                ref
                                        .read(
                                          selectedTherapeuticClassProvider
                                              .notifier,
                                        )
                                        .state =
                                    null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (err, stack) => const SizedBox.shrink(),
              ),
          const SizedBox(height: 12),

          Expanded(
            child: drugSearchAsync.when(
              data: (drugs) {
                if (drugs.isEmpty) {
                  return Center(
                    child: Text(
                      AppLocalizations.of(context)!.noResultsFound(query),
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }
                return Column(
                  children: [
                    if (!isSubscriber)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Iconsax.info_circle,
                                size: 18,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  "PREVIEW MODE:Drugs marked with'PREVIEW'are full-access samples.Upgrade to unlock the full database.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.amber,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: drugs.length,
                        itemBuilder: (context, index) {
                          final drug = drugs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _DrugCard(drug: drug),
                          );
                        },
                      ),
                    ),
                  ],
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

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final currentSort = ref.watch(drugSortOptionProvider);
            final l10n = AppLocalizations.of(context)!;

            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.sortBy,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SortTile(
                    label: l10n.nameAZ,
                    isSelected: currentSort == DrugSortOption.nameAsc,
                    onTap: () {
                      ref.read(drugSortOptionProvider.notifier).state =
                          DrugSortOption.nameAsc;
                      Navigator.pop(context);
                    },
                  ),
                  _SortTile(
                    label: l10n.nameZA,
                    isSelected: currentSort == DrugSortOption.nameDesc,
                    onTap: () {
                      ref.read(drugSortOptionProvider.notifier).state =
                          DrugSortOption.nameDesc;
                      Navigator.pop(context);
                    },
                  ),
                  _SortTile(
                    label: l10n.genericAZ,
                    isSelected: currentSort == DrugSortOption.genericAsc,
                    onTap: () {
                      ref.read(drugSortOptionProvider.notifier).state =
                          DrugSortOption.genericAsc;
                      Navigator.pop(context);
                    },
                  ),
                  _SortTile(
                    label: l10n.genericZA,
                    isSelected: currentSort == DrugSortOption.genericDesc,
                    onTap: () {
                      ref.read(drugSortOptionProvider.notifier).state =
                          DrugSortOption.genericDesc;
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final isEnrichedOnly = ref.watch(drugFilterEnrichedProvider);
            final l10n = AppLocalizations.of(context)!;

            return Container(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.filters,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ref
                                    .read(drugFilterEnrichedProvider.notifier)
                                    .state =
                                false;
                            ref.read(selectedCategoryProvider.notifier).state =
                                null;
                            ref
                                    .read(
                                      selectedTherapeuticClassProvider.notifier,
                                    )
                                    .state =
                                null;
                          },
                          child: Text(l10n.reset),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(l10n.enrichedOnly),
                      subtitle: Text(
                        AppLocalizations.of(context)!.enrichedOnlySubtitle,
                        style: const TextStyle(fontSize: 12),
                      ),
                      value: isEnrichedOnly,
                      activeColor: AppColors.primaryDark,
                      onChanged: (value) {
                        ref.read(drugFilterEnrichedProvider.notifier).state =
                            value;
                      },
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        AppLocalizations.of(context)!.therapeuticClass,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    ref
                        .watch(
                          therapeuticClassesProvider(
                            ref.watch(selectedCategoryProvider),
                          ),
                        )
                        .when(
                          data: (classes) => DropdownButtonFormField<String?>(
                            isExpanded: true,
                            value: ref.watch(selectedTherapeuticClassProvider),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            hint: Text(
                              AppLocalizations.of(context)!.allClasses,
                            ),
                            items: [
                              DropdownMenuItem<String?>(
                                value: null,
                                child: Text(
                                  AppLocalizations.of(context)!.allClasses,
                                ),
                              ),
                              ...classes.map(
                                (cls) => DropdownMenuItem<String?>(
                                  value: cls,
                                  child: Text(
                                    cls,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              ref
                                      .read(
                                        selectedTherapeuticClassProvider
                                            .notifier,
                                      )
                                      .state =
                                  value;
                            },
                          ),
                          loading: () =>
                              const Center(child: LinearProgressIndicator()),
                          error: (err, stack) => Text(
                            AppLocalizations.of(context)!.errorLoadingData,
                          ),
                        ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(l10n.apply),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SortTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primaryDark : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primaryDark)
          : null,
      onTap: onTap,
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryDark
              : AppColors.primaryDark.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryDark
                : AppColors.primaryDark.withOpacity(0.1),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryDark.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected
                ? Colors.white
                : theme.textTheme.bodyMedium?.color,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _DrugCard extends StatelessWidget {
  final Drug drug;

  const _DrugCard({required this.drug});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DrugDetailsScreen(drugId: drug.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Iconsax.mask, color: AppColors.primaryDark),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          drug.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (drug.isFree)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.2),
                            ),
                          ),
                          child: const Text(
                            "PREVIEW",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          drug.genericName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            drug.category ??
                                AppLocalizations.of(context)!.general,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          drug.drugClass,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: theme.hintColor.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, size: 16),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? countColor;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
    this.countColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: countColor,
            ),
          ),
        ],
      ),
    );
  }
}
