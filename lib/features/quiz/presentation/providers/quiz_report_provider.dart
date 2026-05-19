import 'package:meducyte_app/export.dart';

enum ReportReason { typo, wrongAnswer, unclear, other }

class QuizReportState {
  final ReportReason? selectedReason;
  final String customDescription;
  final bool isSending;
  final bool isSuccess;

  QuizReportState({
    this.selectedReason,
    this.customDescription = '',
    this.isSending = false,
    this.isSuccess = false,
  });

  QuizReportState copyWith({
    ReportReason? selectedReason,
    String? customDescription,
    bool? isSending,
    bool? isSuccess,
  }) {
    return QuizReportState(
      selectedReason: selectedReason ?? this.selectedReason,
      customDescription: customDescription ?? this.customDescription,
      isSending: isSending ?? this.isSending,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class QuizReportNotifier extends StateNotifier<QuizReportState> {
  final QuizRepository _repository;

  QuizReportNotifier(this._repository) : super(QuizReportState());

  void setReason(ReportReason reason) {
    state = state.copyWith(selectedReason: reason);
  }

  void setCustomDescription(String description) {
    state = state.copyWith(customDescription: description);
  }

  Future<void> sendReport(String questionId) async {
    if (state.selectedReason == null) return;

    state = state.copyWith(isSending: true);

    try {
      await _repository.reportQuestion(
        int.parse(questionId),
        state.selectedReason!.name,
        state.selectedReason == ReportReason.other
            ? state.customDescription
            : null,
      );
      state = state.copyWith(isSending: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isSending: false);
    }
  }

  void reset() {
    state = QuizReportState();
  }
}

final quizReportProvider =
    StateNotifierProvider.autoDispose<QuizReportNotifier, QuizReportState>((
      ref,
    ) {
      final repository = ref.watch(quizRepositoryProvider);
      return QuizReportNotifier(repository);
    });
