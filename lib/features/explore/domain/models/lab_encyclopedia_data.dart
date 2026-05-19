import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:meducyte_app/export.dart';
import 'lab_encyclopedia_models.dart';

class LabEncyclopediaData {
  static List<LabEntry> _cachedEntries = [];

  static Future<List<LabEntry>> loadEntries() async {
    if (_cachedEntries.isNotEmpty) return _cachedEntries;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/lab_encyclopedia.json',
      );
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> entriesJson = data['entries'] as List<dynamic>;

      final List<LabEntry> loadedEntries = [];
      for (final jsonEntry in entriesJson) {
        try {
          loadedEntries.add(
            LabEntry.fromJson(jsonEntry as Map<String, dynamic>),
          );
        } catch (e) {
          debugPrint('Error parsing lab entry: $e');
        }
      }
      _cachedEntries = loadedEntries;

      // Sort alphabetically by name
      _cachedEntries.sort((a, b) => a.name.compareTo(b.name));

      return _cachedEntries;
    } catch (e) {
      debugPrint('Error loading lab encyclopedia: $e');
      return [];
    }
  }

  static void clearCache() {
    _cachedEntries = [];
  }

  // Temporary fallback for static access if needed during migration
  static List<LabEntry> get currentEntries => _cachedEntries;

  static Future<LabEntry?> getEntryById(String id) async {
    final entries = await loadEntries();
    try {
      return entries.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }
}
