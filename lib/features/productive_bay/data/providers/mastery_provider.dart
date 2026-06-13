import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MasteryData {
  final String subject;
  final double masteryScore; //0.0 to 1.0(average of confidence scores/5)
  final String? lastDifficultConcept;
  final List<int> history; //Last 10 confidence scores

  MasteryData({
    required this.subject,
    required this.masteryScore,
    this.lastDifficultConcept,
    this.history = const [],
  });

  Map<String, dynamic> toJson() => {
    'subject': subject,
    'masteryScore': masteryScore,
    'lastDifficultConcept': lastDifficultConcept,
    'history': history,
  };

  factory MasteryData.fromJson(Map<String, dynamic> json) {
    return MasteryData(
      subject: json['subject'] as String,
      masteryScore: (json['masteryScore'] as num).toDouble(),
      lastDifficultConcept: json['lastDifficultConcept'] as String?,
      history: List<int>.from(json['history'] as List),
    );
  }
}

class MasteryNotifier extends StateNotifier<Map<String, MasteryData>> {
  MasteryNotifier() : super({}) {
    _loadFromPrefs();
  }

  static final Map<String, MasteryData> _defaultData = {
    'Cardiologie': MasteryData(
      subject: 'Cardiologie',
      masteryScore: 0.84,
      lastDifficultConcept: 'Bloc de branche gauche',
      history: [4, 5, 4, 4, 5],
    ),
    'Neurologie': MasteryData(
      subject: 'Neurologie',
      masteryScore: 0.42,
      lastDifficultConcept: 'Territoires vasculaires sylviens',
      history: [2, 3, 2, 2, 3],
    ),
    'Pneumologie': MasteryData(
      subject: 'Pneumologie',
      masteryScore: 0.65,
      lastDifficultConcept: 'BPCO Stades Gold',
      history: [3, 4, 3, 4, 3],
    ),
    'Gastro-entérologie': MasteryData(
      subject: 'Gastro-entérologie',
      masteryScore: 0.72,
      lastDifficultConcept: 'Score de Child-Pugh',
      history: [4, 4, 3, 4, 5],
    ),
  };

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('meducyte_mastery_data');
      if (cachedJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(cachedJson);
        final Map<String, MasteryData> loaded = {};
        decoded.forEach((key, value) {
          loaded[key] = MasteryData.fromJson(value as Map<String, dynamic>);
        });
        if (!mounted) return;
        state = loaded;
        return;
      }
    } catch (e) {
      debugPrint('Error loading mastery data from prefs: $e');
    }
    if (!mounted) return;
    state = _defaultData;
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(state.map((k, v) => MapEntry(k, v.toJson())));
      await prefs.setString('meducyte_mastery_data', encoded);
    } catch (e) {
      debugPrint('Error saving mastery data to prefs: $e');
    }
  }

  void addSessionResult({
    required String subject,
    required int confidence,
    required String difficultConcept,
  }) {
    final current =
        state[subject] ?? MasteryData(subject: subject, masteryScore: 0);
    final newHistory = [...current.history, confidence];
    if (newHistory.length > 10) newHistory.removeAt(0);

    final double newScore =
        newHistory.reduce((a, b) => a + b) / (newHistory.length * 5);

    state = {
      ...state,
      subject: MasteryData(
        subject: subject,
        masteryScore: newScore,
        lastDifficultConcept: difficultConcept.isEmpty ? current.lastDifficultConcept : difficultConcept,
        history: newHistory,
      ),
    };
    _saveToPrefs();
  }
}

final masteryProvider =
    StateNotifierProvider<MasteryNotifier, Map<String, MasteryData>>((ref) {
      return MasteryNotifier();
    });
