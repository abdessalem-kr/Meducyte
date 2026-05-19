import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/settings_models.dart';

class BaySettingsNotifier extends StateNotifier<List<BaySection>> {
  BaySettingsNotifier() : super(_defaultSections) {
    _loadSettings();
  }

  static const String _storageKey = 'productive_bay_settings';

  static const List<BaySection> _defaultSections = [
    BaySection(
      id: '1',
      title: "Analyse Fatigue IA",
      type: BaySectionType.fatigueTracker,
    ),
    BaySection(
      id: '2',
      title: "Tableau de Bord Hub",
      type: BaySectionType.navigationHub,
    ),
    BaySection(
      id: '3',
      title: "Mode Deep Work",
      type: BaySectionType.pomodoroTimer,
    ),
    BaySection(
      id: '4',
      title: "CompteàRebours Examens",
      type: BaySectionType.examCountdown,
    ),
  ];

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        state = decoded.map((e) => BaySection.fromJson(e)).toList();
      }
    } catch (e) {
      //Fallback to defaults
      state = _defaultSections;
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final List<BaySection> newState = List.from(state);
    final item = newState.removeAt(oldIndex);
    newState.insert(newIndex, item);
    state = newState;
    _saveSettings();
  }

  void toggleVisibility(String id) {
    state = [
      for (final section in state)
        if (section.id == id)
          section.copyWith(isEnabled: !section.isEnabled)
        else
          section,
    ];
    _saveSettings();
  }
}

final baySettingsProvider =
    StateNotifierProvider<BaySettingsNotifier, List<BaySection>>((ref) {
      return BaySettingsNotifier();
    });
