import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meducyte_app/shared/providers/network_provider.dart';
import 'package:meducyte_app/features/drugs/data/repositories/drug_repository.dart';
import 'package:meducyte_app/features/drugs/domain/models/drug_models.dart';

enum DrugSortOption { nameAsc, nameDesc, genericAsc, genericDesc }

final drugRepositoryProvider = Provider<DrugRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DrugRepository(dioClient);
});

final drugSearchQueryProvider = StateProvider<String>((ref) => '');

final selectedCategoryProvider = StateProvider<String?>((ref) => null);
final selectedTherapeuticClassProvider = StateProvider<String?>((ref) => null);

final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(drugRepositoryProvider);
  return repository.getCategories();
});

final therapeuticClassesProvider = FutureProvider.family<List<String>, String?>(
  (ref, category) async {
    final repository = ref.watch(drugRepositoryProvider);
    return repository.getTherapeuticClasses(category: category);
  },
);

final drugSortOptionProvider = StateProvider<DrugSortOption>(
  (ref) => DrugSortOption.nameAsc,
);
final drugFilterEnrichedProvider = StateProvider<bool>((ref) => false);

final drugSearchProvider = FutureProvider<List<Drug>>((ref) async {
  final repository = ref.watch(drugRepositoryProvider);
  final query = ref.watch(drugSearchQueryProvider);
  final category = ref.watch(selectedCategoryProvider);
  final therapeuticClass = ref.watch(selectedTherapeuticClassProvider);
  final sortOption = ref.watch(drugSortOptionProvider);
  final enrichedOnly = ref.watch(drugFilterEnrichedProvider);

  var drugs = await repository.searchDrugs(
    query: query,
    category: category,
    therapeuticClass: therapeuticClass,
    enrichedOnly: enrichedOnly,
  );

  //Apply Sorting
  switch (sortOption) {
    case DrugSortOption.nameAsc:
      drugs.sort((a, b) => a.name.compareTo(b.name));
      break;
    case DrugSortOption.nameDesc:
      drugs.sort((a, b) => b.name.compareTo(a.name));
      break;
    case DrugSortOption.genericAsc:
      drugs.sort((a, b) => a.genericName.compareTo(b.genericName));
      break;
    case DrugSortOption.genericDesc:
      drugs.sort((a, b) => b.genericName.compareTo(a.genericName));
      break;
  }

  return drugs;
});

//Separate search for interaction bottom sheet to avoid cross-talk
final interactionSearchQueryProvider = StateProvider<String>((ref) => '');

final interactionDrugSearchProvider = FutureProvider<List<Drug>>((ref) async {
  final repository = ref.watch(drugRepositoryProvider);
  final query = ref.watch(interactionSearchQueryProvider);
  return repository.searchDrugs(query: query);
});

final drugDetailsProvider = FutureProvider.family<Drug?, String>((
  ref,
  id,
) async {
  final repository = ref.watch(drugRepositoryProvider);
  return repository.getDrugDetails(id);
});

//State provider for interaction checker list
final selectedDrugsProvider = StateProvider<List<Drug>>((ref) => []);

final drugInteractionsProvider = FutureProvider<List<DrugInteraction>>((
  ref,
) async {
  final selectedDrugs = ref.watch(selectedDrugsProvider);
  if (selectedDrugs.length < 2) return [];

  final repository = ref.watch(drugRepositoryProvider);
  final drugIds = selectedDrugs.map((d) => d.id).toList();
  return repository.checkInteractions(drugIds);
});

final drugStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(drugRepositoryProvider);
  final allDrugs = await repository.searchDrugs();
  final enrichedCount = allDrugs.where((d) => d.indications.isNotEmpty).length;
  final uniqueMolecules = allDrugs.map((d) => d.genericName).toSet().length;

  return {
    'total': allDrugs.length,
    'enriched': enrichedCount,
    'molecules': uniqueMolecules,
  };
});
