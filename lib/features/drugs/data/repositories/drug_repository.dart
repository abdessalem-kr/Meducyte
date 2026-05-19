import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:meducyte_app/core/network/dio_client.dart';
import 'package:meducyte_app/features/drugs/domain/models/drug_models.dart';

class DrugRepository {
  //ignore:unused_field
  final DioClient _client;
  List<Drug>? _cachedDrugs;

  DrugRepository(this._client);

  Future<List<Drug>> _loadDrugs() async {
    if (_cachedDrugs != null) return _cachedDrugs!;

    try {
      final String response = await rootBundle.loadString(
        'assets/data/algerian_drugs.json',
      );
      final List<dynamic> data = json.decode(response);
      _cachedDrugs = data.map((json) => Drug.fromJson(json)).toList();
      return _cachedDrugs!;
    } catch (e) {
      //Fallback or error handling
      return [];
    }
  }

  //Mock interactions(handled by name in checkInteractions)

  Future<List<String>> getCategories() async {
    final allDrugs = await _loadDrugs();
    final categories = allDrugs
        .map((d) => d.category ?? 'Autres')
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  Future<List<String>> getTherapeuticClasses({String? category}) async {
    final allDrugs = await _loadDrugs();
    final classes = allDrugs
        .where((d) => category == null || d.category == category)
        .map((d) => d.therapeuticClass ?? 'Non documenté')
        .toSet()
        .toList();
    classes.sort();
    return classes;
  }

  Future<List<Drug>> searchDrugs({
    String query = '',
    String? category,
    String? therapeuticClass,
    bool enrichedOnly = false,
  }) async {
    final allDrugs = await _loadDrugs();
    var filteredDrugs = allDrugs;

    //Apply Search Query Filter
    if (query.isNotEmpty) {
      final lowercaseQuery = query.toLowerCase();
      filteredDrugs = filteredDrugs
          .where(
            (drug) =>
                drug.name.toLowerCase().contains(lowercaseQuery) ||
                drug.genericName.toLowerCase().contains(lowercaseQuery),
          )
          .toList();
    }

    //Apply Category Filter
    if (category != null) {
      filteredDrugs = filteredDrugs
          .where((drug) => drug.category == category)
          .toList();
    }

    //Apply Therapeutic Class Filter
    if (therapeuticClass != null) {
      filteredDrugs = filteredDrugs
          .where((drug) => drug.therapeuticClass == therapeuticClass)
          .toList();
    }

    //Apply Enriched Filter
    if (enrichedOnly) {
      filteredDrugs = filteredDrugs
          .where((drug) => drug.indications.isNotEmpty)
          .toList();
    }

    return filteredDrugs;
  }

  Future<Drug?> getDrugDetails(String id) async {
    final allDrugs = await _loadDrugs();
    try {
      return allDrugs.firstWhere((drug) => drug.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<DrugInteraction>> checkInteractions(List<String> drugIds) async {
    final allDrugs = await _loadDrugs();
    final selectedDrugs = allDrugs
        .where((d) => drugIds.contains(d.id))
        .toList();

    List<DrugInteraction> results = [];

    for (int i = 0; i < selectedDrugs.length; i++) {
      for (int j = i + 1; j < selectedDrugs.length; j++) {
        final d1 = selectedDrugs[i];
        final d2 = selectedDrugs[j];

        //Simple name-based mock check for demo purposes
        if ((d1.genericName.contains('ACETYLSALICYLIQUE') &&
                d2.genericName.contains('WARFARINE')) ||
            (d2.genericName.contains('ACETYLSALICYLIQUE') &&
                d1.genericName.contains('WARFARINE'))) {
          results.add(
            DrugInteraction(
              drugId1: d1.id,
              drugId2: d2.id,
              severity: InteractionSeverity.severe,
              description:
                  'Risque accru d\'hémorragie majeure lors de l\'association de l\'aspirine avec la warfarine.',
              management:
                  'Éviter l\'association si possible.Surveillerétroitement l\'INR et les signes de saignement.',
            ),
          );
        }
      }
    }
    return results;
  }
}
