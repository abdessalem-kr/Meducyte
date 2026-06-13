import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:meducyte_app/core/config/env.dart';
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
    if (drugIds.length < 2) return [];

    final allDrugs = await _loadDrugs();
    final selectedDrugs = allDrugs.where((d) => drugIds.contains(d.id)).toList();

    const String apiKey = Env.groqApiKey;
    const String groqUrl = "https://api.groq.com/openai/v1/chat/completions";

    final drugListJson = selectedDrugs.map((d) => {
      'id': d.id,
      'name': d.name,
      'generic_name': d.genericName,
      'drug_class': d.drugClass,
    }).toList();

    final messages = [
      {
        "role": "system",
        "content":
            "You are a clinical pharmacology engine. "
            "Analyze the selected drugs and identify any clinically significant drug-drug interactions between them.\n\n"
            "STRICT INSTRUCTIONS:\n"
            "1. You MUST respond ONLY with a valid JSON array of objects representing the detected interactions. "
            "Do NOT include any introduction, formatting backticks like ```json, markdown tags, or any text outside the JSON array.\n"
            "2. If there are no clinically significant interactions, return exactly: []\n"
            "3. Every interaction object MUST have the following keys:\n"
            "   - \"drug_id_1\": the exact String ID of the first drug (e.g. \"1\")\n"
            "   - \"drug_id_2\": the exact String ID of the second drug (e.g. \"2\")\n"
            "   - \"severity\": one of: \"severe\", \"moderate\", \"minor\"\n"
            "   - \"description\": clinical explanation of the interaction in French\n"
            "   - \"management\": clinical management advice in French\n\n"
            "Example expected format:\n"
            "[{\"drug_id_1\": \"1\", \"drug_id_2\": \"2\", \"severity\": \"severe\", \"description\": \"Risque accru...\", \"management\": \"Éviter...\"}]",
      },
      {
        "role": "user",
        "content": "Selected Drugs:\n${json.encode(drugListJson)}",
      }
    ];

    try {
      final response = await _client.dio.post(
        groqUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer $apiKey",
            "Content-Type": "application/json",
          },
        ),
        data: {
          "model": "llama-3.1-8b-instant",
          "messages": messages,
          "temperature": 0.1,
        },
      );

      if (response.statusCode == 200) {
        String content = response.data['choices'][0]['message']['content'];
        content = content.trim();

        // Strip markdown code block wrapping if present
        if (content.contains('```json')) {
          content = content.split('```json').last.split('```').first.trim();
        } else if (content.contains('```')) {
          content = content.split('```').last.split('```').first.trim();
        }

        if (content.isEmpty || content == '[]') {
          return [];
        }

        final List<dynamic> parsed = json.decode(content);
        return parsed.map((item) {
          final severityStr = item['severity'] as String? ?? 'minor';
          final severity = InteractionSeverity.values.firstWhere(
            (e) => e.name == severityStr.toLowerCase(),
            orElse: () => InteractionSeverity.minor,
          );

          return DrugInteraction(
            drugId1: item['drug_id_1'] as String? ?? '',
            drugId2: item['drug_id_2'] as String? ?? '',
            severity: severity,
            description: item['description'] as String? ?? '',
            management: item['management'] as String? ?? '',
          );
        }).toList();
      }
    } catch (e) {
      // Fallback to name check
      final List<DrugInteraction> fallbackResults = [];
      for (int i = 0; i < selectedDrugs.length; i++) {
        for (int j = i + 1; j < selectedDrugs.length; j++) {
          final d1 = selectedDrugs[i];
          final d2 = selectedDrugs[j];
          if ((d1.genericName.contains('ACETYLSALICYLIQUE') &&
                  d2.genericName.contains('WARFARINE')) ||
              (d2.genericName.contains('ACETYLSALICYLIQUE') &&
                  d1.genericName.contains('WARFARINE'))) {
            fallbackResults.add(
              DrugInteraction(
                drugId1: d1.id,
                drugId2: d2.id,
                severity: InteractionSeverity.severe,
                description:
                    'Risque accru d\'hémorragie majeure lors de l\'association de l\'aspirine avec la warfarine.',
                management:
                    'Éviter l\'association si possible. Surveiller étroitement l\'INR et les signes de saignement.',
              ),
            );
          }
        }
      }
      return fallbackResults;
    }
    return [];
  }
}
