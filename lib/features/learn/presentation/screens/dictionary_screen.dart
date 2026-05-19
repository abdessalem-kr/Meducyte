import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:meducyte_app/core/themes/app_colors.dart';
import 'package:meducyte_app/features/learn/data/providers/dictionary_providers.dart';
import 'package:meducyte_app/core/database/app_database.dart';

class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(paginatedMedicalTermsProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _DictionaryFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredTermsAsync = ref.watch(paginatedMedicalTermsProvider);
    final query = ref.watch(dictionarySearchQueryProvider);
    final isTermView = ref.watch(dictionaryViewModeProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Medical Dictionary'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: theme.textTheme.titleLarge?.color,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) =>
                        ref.read(dictionarySearchQueryProvider.notifier).state =
                            value,
                    decoration: InputDecoration(
                      hintText: 'Search terms...',
                      prefixIcon: const Icon(Iconsax.search_normal),
                      suffixIcon: query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                        .read(
                                          dictionarySearchQueryProvider
                                              .notifier,
                                        )
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showFilterSheet(context),
                  icon: const Icon(Iconsax.filter_edit),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Terms'),
                          selected: isTermView,
                          onSelected: (selected) {
                            if (selected) {
                              ref
                                      .read(dictionaryViewModeProvider.notifier)
                                      .state =
                                  true;
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Abbreviations&Synonyms'),
                          selected: !isTermView,
                          onSelected: (selected) {
                            if (selected) {
                              ref
                                      .read(dictionaryViewModeProvider.notifier)
                                      .state =
                                  false;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const _ActiveFiltersToolbar(),
          Expanded(
            child: filteredTermsAsync.when(
              data: (terms) {
                if (terms.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.document_filter,
                            size: 64,
                            color: theme.hintColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            query.isEmpty
                                ? 'No medical terms found in the database.'
                                : 'No terms found for"$query".',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                          if (query.isEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Please ensure the medical terms data is correctly initialized.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                final notifier = ref.read(
                  paginatedMedicalTermsProvider.notifier,
                );
                final hasMore = notifier.hasMore;

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: terms.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == terms.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final term = terms[index];
                    return _DictionaryCard(term: term, isTermView: isTermView);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) {
                //If it's an asset loading error,show a more friendly message
                final errorStr = err.toString();
                if (errorStr.contains('Unable to load asset')) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Iconsax.warning_2,
                            size: 64,
                            color: Colors.amber,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Data Asset Missing',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'The medical terms database file could not be found.Please contact support.',
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
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorStr,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () =>
                              ref.invalidate(paginatedMedicalTermsProvider),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveFiltersToolbar extends ConsumerWidget {
  const _ActiveFiltersToolbar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final specialty = ref.watch(dictionarySpecialtyFilterProvider);

    if (specialty == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryDark.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  specialty,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () =>
                      ref
                              .read(dictionarySpecialtyFilterProvider.notifier)
                              .state =
                          null,
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              ref.read(dictionarySpecialtyFilterProvider.notifier).state = null;
            },
            child: Text(
              'Clear All',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DictionaryFilterSheet extends ConsumerWidget {
  const _DictionaryFilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentSort = ref.watch(dictionarySortProvider);
    final currentSpecialty = ref.watch(dictionarySpecialtyFilterProvider);
    final specialtiesAsync = ref.watch(medicalSpecialtiesProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters&Sorting',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Sort By',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Term(A-Z)'),
                selected: currentSort == DictionarySort.nameAsc,
                onSelected: (val) {
                  if (val) {
                    ref.read(dictionarySortProvider.notifier).state =
                        DictionarySort.nameAsc;
                  }
                },
              ),
              ChoiceChip(
                label: const Text('Term(Z-A)'),
                selected: currentSort == DictionarySort.nameDesc,
                onSelected: (val) {
                  if (val) {
                    ref.read(dictionarySortProvider.notifier).state =
                        DictionarySort.nameDesc;
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Specialty',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          specialtiesAsync.when(
            data: (specs) => SizedBox(
              height: 200,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: specs.length,
                itemBuilder: (context, index) {
                  final spec = specs[index];
                  return ListTile(
                    dense: true,
                    title: Text(spec),
                    trailing: currentSpecialty == spec
                        ? Icon(Icons.check, color: theme.primaryColor)
                        : null,
                    onTap: () {
                      ref
                              .read(dictionarySpecialtyFilterProvider.notifier)
                              .state =
                          spec;
                    },
                  );
                },
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Error loading specialties'),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(dictionarySortProvider.notifier).state =
                        DictionarySort.nameAsc;
                    ref.read(dictionarySpecialtyFilterProvider.notifier).state =
                        null;
                    Navigator.pop(context);
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DictionaryCard extends StatelessWidget {
  final DbMedicalTerm term;
  final bool isTermView;

  const _DictionaryCard({required this.term, this.isTermView = true});

  //Helper to extract synonyms natively
  List<String> _extractSynonyms() {
    List<String> extractedSynonyms = [];
    final patterns = [
      RegExp(r'^\s*\(?\s*Syn\.?\s*[ :]+(.*?)\)\s*\.?\s*', caseSensitive: false),
      RegExp(r'^\s*Syn\.?\s*[ :]+(.*?)\.\s+', caseSensitive: false),
      RegExp(
        r'^\s*\(?\s*Abr(?:é|e)v\.?\s*[ :]+(.*?)\)\s*\.?\s*',
        caseSensitive: false,
      ),
      RegExp(r'^\s*Abr(?:é|e)v\.?\s*[ :]+(.*?)\.\s+', caseSensitive: false),
    ];

    if (term.name != null && term.name!.isNotEmpty) {
      String cleanName = term.name!.trim();
      for (final pattern in patterns) {
        final match = pattern.firstMatch(cleanName);
        if (match != null) {
          extractedSynonyms.add(match.group(1)!.trim());
          cleanName = cleanName.replaceFirst(match.group(0)!, '').trim();
        }
      }
    }

    String cleanDefinition = term.defn.trim();
    for (final pattern in patterns) {
      final match = pattern.firstMatch(cleanDefinition);
      if (match != null) {
        extractedSynonyms.add(match.group(1)!.trim());
        cleanDefinition = cleanDefinition
            .replaceFirst(match.group(0)!, '')
            .trim();
      }
    }

    return extractedSynonyms
        .map(
          (s) => s.replaceAll(RegExp(r'^\s*[-:.]\s*|\s*[-:.]\s*$'), '').trim(),
        )
        .where(
          (s) => s.isNotEmpty && s.toLowerCase() != term.term.toLowerCase(),
        )
        .toSet()
        .toList();
  }

  void _showDetailsDialog(
    BuildContext context,
    List<String> extractedSynonyms,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);

        String cleanDefinition = term.defn.trim();
        final patterns = [
          RegExp(
            r'^\s*\(?\s*Syn\.?\s*[ :]+(.*?)\)\s*\.?\s*',
            caseSensitive: false,
          ),
          RegExp(r'^\s*Syn\.?\s*[ :]+(.*?)\.\s+', caseSensitive: false),
          RegExp(
            r'^\s*\(?\s*Abr(?:é|e)v\.?\s*[ :]+(.*?)\)\s*\.?\s*',
            caseSensitive: false,
          ),
          RegExp(r'^\s*Abr(?:é|e)v\.?\s*[ :]+(.*?)\.\s+', caseSensitive: false),
        ];

        for (final pattern in patterns) {
          final match = pattern.firstMatch(cleanDefinition);
          if (match != null) {
            cleanDefinition = cleanDefinition
                .replaceFirst(match.group(0)!, '')
                .trim();
          }
        }

        String? cleanName;
        if (term.name != null && term.name!.isNotEmpty) {
          String tempName = term.name!.trim();
          for (final pattern in patterns) {
            final match = pattern.firstMatch(tempName);
            if (match != null) {
              tempName = tempName.replaceFirst(match.group(0)!, '').trim();
            }
          }
          cleanName = tempName;
        }

        return AlertDialog(
          title: Text(
            term.term,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (extractedSynonyms.isNotEmpty) ...[
                  Text(
                    'Abbreviations/Synonyms',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    extractedSynonyms.join(', '),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                ],
                if (term.spec != null && term.spec!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      term.spec!.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(cleanDefinition, style: theme.textTheme.bodyLarge),
                if (cleanName != null && cleanName.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    cleanName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extractedSynonyms = _extractSynonyms();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryDark.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetailsDialog(context, extractedSynonyms),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    term.term,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.hintColor.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
