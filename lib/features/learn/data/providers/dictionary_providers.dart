import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meducyte_app/core/database/app_database.dart';
import 'package:meducyte_app/shared/providers/database_provider.dart';

//Provides the count of medical terms in the database
final medicalDictionaryCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  return await db.getMedicalTermsCount();
});

//Sorting and Filtering Providers
enum DictionarySort { nameAsc, nameDesc }

final dictionarySortProvider = StateProvider<DictionarySort>(
  (ref) => DictionarySort.nameAsc,
);
final dictionarySpecialtyFilterProvider = StateProvider<String?>((ref) => null);

//View Mode Provider:true=Terms View,false=Abbreviations&Synonyms View
final dictionaryViewModeProvider = StateProvider<bool>((ref) => true);

final medicalSpecialtiesProvider = FutureProvider<List<String>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  return await db.getMedicalSpecialties();
});

//A provider to seed the database if it's empty
final seedDictionaryProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final count = await db.getMedicalTermsCount();

  if (count == 0) {
    try {
      debugPrint('Dictionary is empty,starting seeding...');

      //Try JSON first as it was the original plan
      try {
        final String jsonString = await rootBundle.loadString(
          'assets/data/medical_terms.json',
        );
        debugPrint('Loading medical_terms.json...');
        final List<dynamic> jsonList = json.decode(jsonString);

        if (jsonList.isNotEmpty) {
          final terms = jsonList.map((json) {
            return MedicalTermsCompanion.insert(
              term: (json['term'] as String? ?? 'Unknown Term').trim(),
              spec: Value(json['spec'] as String?),
              name: Value(json['name'] as String?),
              defn: (json['defn'] as String? ?? 'No definition provided')
                  .trim(),
            );
          }).toList();

          await db.insertMedicalTermsBatch(terms);
          debugPrint('Successfully seeded${terms.length}terms from JSON');
          ref.invalidate(medicalDictionaryCountProvider);
          return;
        }
      } catch (e) {
        debugPrint('JSON seeding skipped(file missing or empty)');
      }

      //SQLite Seeding fallback
      try {
        debugPrint('Attempting to seed from terms.sqlite asset...');
        final ByteData data = await rootBundle.load('assets/data/terms.sqlite');
        final bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );

        if (bytes.isNotEmpty) {
          final directory = await getApplicationSupportDirectory();
          final path = p.join(directory.path, 'temp_terms.sqlite');
          final file = File(path);
          await file.writeAsBytes(bytes, flush: true);

          debugPrint('Importing data from SQLite asset($path)...');
          await db.importDataFromAssetDatabase(path);

          //Cleanup
          try {
            await file.delete();
          } catch (e) {
            debugPrint('Failed to delete temp SQLite file: $e');
          }

          ref.invalidate(medicalDictionaryCountProvider);
          final newCount = await db.getMedicalTermsCount();
          debugPrint('Dictionary successfully seeded.Total terms: $newCount');
        } else {
          debugPrint('Error:terms.sqlite asset is empty');
        }
      } catch (e) {
        if (e is FlutterError && e.message.contains('Unable to load asset')) {
          debugPrint(
            'Dictionary seeding skipped:No data assets found(JSON or SQLite)',
          );
        } else {
          debugPrint('Error during SQLite dictionary seeding: $e');
        }
      }
    } catch (e) {
      debugPrint('Unexpected error during dictionary seeding: $e');
    }
  } else {
    debugPrint('Dictionary already contains$count terms,skipping seeding.');
  }
});

//A provider for searching terms
final dictionarySearchQueryProvider = StateProvider<String>((ref) => '');

class PaginatedMedicalTermsNotifier extends AsyncNotifier<List<DbMedicalTerm>> {
  int _offset = 0;
  final int _limit = 50;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  @override
  Future<List<DbMedicalTerm>> build() async {
    //Ensure seeding is attempted first
    await ref.watch(seedDictionaryProvider.future);

    _offset = 0;
    _hasMore = true;

    final db = ref.watch(appDatabaseProvider);
    final query = ref.watch(dictionarySearchQueryProvider);
    final sort = ref.watch(dictionarySortProvider);
    final specialty = ref.watch(dictionarySpecialtyFilterProvider);
    final isTermView = ref.watch(dictionaryViewModeProvider);

    final terms = await db.searchMedicalTerms(
      query,
      limit: _limit,
      offset: _offset,
      specialty: specialty,
      sortAscending: sort == DictionarySort.nameAsc,
      isTermView: isTermView,
    );
    _hasMore = terms.length == _limit;
    return terms;
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.hasError || !_hasMore) return;

    final db = ref.read(appDatabaseProvider);
    final query = ref.read(dictionarySearchQueryProvider);
    final sort = ref.read(dictionarySortProvider);
    final specialty = ref.read(dictionarySpecialtyFilterProvider);
    final isTermView = ref.read(dictionaryViewModeProvider);

    _offset += _limit;

    final currentTerms = state.value ?? [];

    try {
      final newTerms = await db.searchMedicalTerms(
        query,
        limit: _limit,
        offset: _offset,
        specialty: specialty,
        sortAscending: sort == DictionarySort.nameAsc,
        isTermView: isTermView,
      );
      _hasMore = newTerms.length == _limit;
      state = AsyncData([...currentTerms, ...newTerms]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final paginatedMedicalTermsProvider =
    AsyncNotifierProvider<PaginatedMedicalTermsNotifier, List<DbMedicalTerm>>(
      () {
        return PaginatedMedicalTermsNotifier();
      },
    );
