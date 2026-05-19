import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/shared/providers/database_provider.dart';
import 'package:meducyte_app/features/drugs/data/providers/drug_providers.dart';

// ───Navigation────────────────────────────────────────────────────────────
final navigationIndexProvider = StateProvider<int>((ref) => 0);

// ───Search&Filters───────────────────────────────────────────────────────
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedFilterProvider = StateProvider<String>((ref) => 'All');
final selectedSortProvider = StateProvider<String>((ref) => 'Relevance');
final selectedDifficultyProvider = StateProvider<String>((ref) => 'All');

// ───Search Result Model─────────────────────────────────────────────────────
enum SearchResultCategory { drug, dictionary }

class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final SearchResultCategory category;

  const SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
  });

  IconData get icon {
    switch (category) {
      case SearchResultCategory.drug:
        return Icons.medication_rounded;
      case SearchResultCategory.dictionary:
        return Icons.menu_book_rounded;
    }
  }

  Color iconColor(BuildContext context) {
    switch (category) {
      case SearchResultCategory.drug:
        return Colors.teal;
      case SearchResultCategory.dictionary:
        return Colors.indigo;
    }
  }

  String get categoryLabel {
    switch (category) {
      case SearchResultCategory.drug:
        return 'Drug';
      case SearchResultCategory.dictionary:
        return 'Dictionary';
    }
  }
}

// ───Global Search Provider───────────────────────────────────────────────────
final globalSearchProvider = FutureProvider<List<SearchResult>>((ref) async {
  final query = ref.watch(searchQueryProvider).trim();
  final filter = ref.watch(
    selectedFilterProvider,
  ); // 'All' | 'Drugs' | 'Diseases' | 'Abbreviations'
  final sort = ref.watch(
    selectedSortProvider,
  ); // 'Relevance' | 'Alphabetical' | 'Newest'

  if (query.length < 2) return [];

  final db = ref.watch(appDatabaseProvider);
  final drugRepo = ref.watch(drugRepositoryProvider);

  //Determine what to query based on filter
  final queryDrugs = filter == 'All' || filter == 'Drugs';
  final queryDict =
      filter == 'All' || filter == 'Diseases' || filter == 'Abbreviations';

  final futures = <Future<List<SearchResult>>>[];

  if (queryDrugs) {
    futures.add(
      drugRepo
          .searchDrugs(query: query)
          .then(
            (drugs) => drugs
                .take(6)
                .map(
                  (d) => SearchResult(
                    id: d.id,
                    title: d.name,
                    subtitle: d.genericName.isNotEmpty
                        ? d.genericName
                        : (d.category ?? ''),
                    category: SearchResultCategory.drug,
                  ),
                )
                .toList(),
          )
          .catchError((_) => <SearchResult>[]),
    );
  }

  if (queryDict) {
    futures.add(
      db
          .searchMedicalTerms(query, limit: 6, offset: 0)
          .then(
            (terms) => terms
                .map(
                  (t) => SearchResult(
                    id: t.id.toString(),
                    title: t.term,
                    subtitle: t.defn.length > 70
                        ? '${t.defn.substring(0, 70)}…'
                        : t.defn,
                    category: SearchResultCategory.dictionary,
                  ),
                )
                .toList(),
          )
          .catchError((_) => <SearchResult>[]),
    );
  }

  if (futures.isEmpty) return [];

  final results = await Future.wait<List<SearchResult>>(futures);
  var combined = results.expand((r) => r).toList();

  //Apply sort
  switch (sort) {
    case 'Alphabetical':
      combined.sort((a, b) => a.title.compareTo(b.title));
      break;
    case 'Newest':
      //Reverse the order(newest=last added,approximate via reversed list)
      combined = combined.reversed.toList();
      break;
    case 'Relevance':
    default:
      //Prioritise results where title starts with query
      final q = query.toLowerCase();
      combined.sort((a, b) {
        final aStarts = a.title.toLowerCase().startsWith(q) ? 0 : 1;
        final bStarts = b.title.toLowerCase().startsWith(q) ? 0 : 1;
        return aStarts.compareTo(bStarts);
      });
      break;
  }

  return combined;
});
