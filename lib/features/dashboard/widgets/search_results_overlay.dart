import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:meducyte_app/features/dashboard/providers/dashboard_providers.dart';
import 'package:meducyte_app/features/drugs/presentation/screens/drug_database_screen.dart';
import 'package:meducyte_app/features/learn/presentation/screens/dictionary_screen.dart';
import 'package:meducyte_app/l10n/arb/app_localizations.dart';

class SearchResultsOverlay extends ConsumerWidget {
  final TextEditingController controller;
  final VoidCallback onDismiss;

  const SearchResultsOverlay({
    super.key,
    required this.controller,
    required this.onDismiss,
  });

  void _navigateTo(BuildContext context, SearchResult result) {
    onDismiss();
    switch (result.category) {
      case SearchResultCategory.drug:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DrugDatabaseScreen()),
        );
        break;
      case SearchResultCategory.dictionary:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DictionaryScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final activeFilter = ref.watch(selectedFilterProvider);
    final activeSort = ref.watch(selectedSortProvider);

    if (query.trim().length < 2) return const SizedBox.shrink();

    final searchAsync = ref.watch(globalSearchProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        //Dismissible background
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDismiss,
            child: Container(color: Colors.black.withOpacity(0.01)),
          ),
        ),

        //Results card
        Positioned(
          top: 80,
          left: 16,
          right: 16,
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 400),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ──Active filter badge row──────────────────────────────
                  if (activeFilter != 'All' || activeSort != 'Relevance')
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.07),
                        border: Border(
                          bottom: BorderSide(
                            color: theme.dividerColor.withOpacity(0.15),
                          ),
                        ),
                      ),
                      child: Wrap(
                        spacing: 6,
                        children: [
                          if (activeFilter != 'All')
                            _FilterBadge(
                              label: activeFilter,
                              color: Colors.teal,
                            ),
                          if (activeSort != 'Relevance')
                            _FilterBadge(
                              label: '↕ $activeSort',
                              color: Colors.deepPurple,
                            ),
                        ],
                      ),
                    ),
                  // ──Search results───────────────────────────────────────
                  Flexible(
                    child: searchAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      error: (_, __) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(
                              Iconsax.warning_2,
                              color: Colors.orange,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Search unavailable',
                              style: TextStyle(color: theme.hintColor),
                            ),
                          ],
                        ),
                      ),
                      data: (results) {
                        if (results.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.info_circle,
                                  color: theme.hintColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    l10n.noResultsFound(query),
                                    style: TextStyle(
                                      color: theme.textTheme.bodyMedium?.color
                                          ?.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final drugs = results
                            .where(
                              (r) => r.category == SearchResultCategory.drug,
                            )
                            .toList();
                        final terms = results
                            .where(
                              (r) =>
                                  r.category == SearchResultCategory.dictionary,
                            )
                            .toList();

                        final sections = <Widget>[];

                        void buildSection(
                          String label,
                          List<SearchResult> items,
                          Color color,
                        ) {
                          if (items.isEmpty) return;

                          sections.add(
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 3,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );

                          for (final result in items) {
                            sections.add(
                              InkWell(
                                onTap: () => _navigateTo(context, result),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          result.icon,
                                          size: 18,
                                          color: color,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              result.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (result.subtitle.isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                result.subtitle,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: theme.hintColor,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 12,
                                        color: theme.hintColor.withOpacity(0.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        }

                        buildSection('DRUGS', drugs, Colors.teal);
                        buildSection('DICTIONARY', terms, Colors.indigo);

                        return SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              ...sections,
                              const SizedBox(height: 8),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _FilterBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
