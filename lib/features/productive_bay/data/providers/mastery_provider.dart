import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}

class MasteryNotifier extends StateNotifier<Map<String, MasteryData>> {
  MasteryNotifier() : super(_initialData);

  static final Map<String, MasteryData> _initialData = {
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
        lastDifficultConcept: difficultConcept,
        history: newHistory,
      ),
    };
  }
}

final masteryProvider =
    StateNotifierProvider<MasteryNotifier, Map<String, MasteryData>>((ref) {
      return MasteryNotifier();
    });
