import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/specialty_config.dart';

class PathologyDataService {
  static final Map<MedicalSpecialty, List<PathologyGuide>> _cache = {};

  ///Loads pathologies for a specific specialty from bundled JSON assets.
  static Future<List<PathologyGuide>> loadPathologies(
    MedicalSpecialty specialty,
  ) async {
    if (_cache.containsKey(specialty)) {
      return _cache[specialty]!;
    }

    try {
      final String fileName = specialty.name;
      final String path = 'assets/data/pathologies/$fileName.json';

      final String jsonString = await rootBundle.loadString(path);
      final List<dynamic> jsonData = jsonDecode(jsonString);

      final pathologies = jsonData
          .map((item) => PathologyGuide.fromJson(item as Map<String, dynamic>))
          .toList();

      _cache[specialty] = pathologies;
      return pathologies;
    } catch (e) {
      //Asset might not exist yet for this specialty
      return [];
    }
  }

  ///Clears the cache if needed(e.g.,for hot reload testing)
  static void clearCache() => _cache.clear();
}
