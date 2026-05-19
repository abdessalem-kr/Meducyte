import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/quiz/domain/models/comment_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'dart:convert';

class QuizSessionState {
  final int currentQuestionIndex;
  final bool showFeedback;
  final Set<int> selectedOptionIds; //Supports multiple selections
  final bool isStarred;
  final Map<String, List<HighlightModel>> highlights;
  final List<CommentModel> comments;
  final Map<int, Set<int>> userAnswers; //questionId->set of propositionIds
  final Map<int, AnswerResult>
  results; //questionId->AnswerResult(local feedback)
  final bool isFinished;
  final bool isLoading;
  final int timeSeconds;
  final QuizCorrectionMode correctionMode;
  final bool isCountdown;
  final bool isInitialized;
  final bool isExplore;
  final bool isPractice;
  final String? questionNote;
  final String? clinicalCaseNote;
  final bool isClinicalCaseExpanded;

  QuizSessionState({
    this.currentQuestionIndex = 0,
    this.showFeedback = false,
    this.selectedOptionIds = const {},
    this.isStarred = false,
    this.highlights = const {},
    this.comments = const [],
    this.userAnswers = const {},
    this.results = const {},
    this.isFinished = false,
    this.isLoading = false,
    this.timeSeconds = 0,
    this.correctionMode = QuizCorrectionMode.allOrNothing,
    this.isCountdown = false,
    this.isInitialized = false,
    this.isExplore = false,
    this.isPractice = true,
    this.questionNote,
    this.clinicalCaseNote,
    this.isClinicalCaseExpanded = true,
  });

  QuizSessionState copyWith({
    int? currentQuestionIndex,
    bool? showFeedback,
    Set<int>? selectedOptionIds,
    bool? isStarred,
    Map<String, List<HighlightModel>>? highlights,
    List<CommentModel>? comments,
    Map<int, Set<int>>? userAnswers,
    Map<int, AnswerResult>? results,
    bool? isFinished,
    bool? isLoading,
    int? timeSeconds,
    QuizCorrectionMode? correctionMode,
    bool? isCountdown,
    bool? isInitialized,
    bool? isExplore,
    bool? isPractice,
    String? questionNote,
    String? clinicalCaseNote,
    bool? isClinicalCaseExpanded,
  }) {
    return QuizSessionState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      showFeedback: showFeedback ?? this.showFeedback,
      selectedOptionIds: selectedOptionIds ?? this.selectedOptionIds,
      isStarred: isStarred ?? this.isStarred,
      highlights: highlights ?? this.highlights,
      comments: comments ?? this.comments,
      userAnswers: userAnswers ?? this.userAnswers,
      results: results ?? this.results,
      isFinished: isFinished ?? this.isFinished,
      isLoading: isLoading ?? this.isLoading,
      timeSeconds: timeSeconds ?? this.timeSeconds,
      correctionMode: correctionMode ?? this.correctionMode,
      isCountdown: isCountdown ?? this.isCountdown,
      isInitialized: isInitialized ?? this.isInitialized,
      isExplore: isExplore ?? this.isExplore,
      isPractice: isPractice ?? this.isPractice,
      questionNote: questionNote ?? this.questionNote,
      clinicalCaseNote: clinicalCaseNote ?? this.clinicalCaseNote,
      isClinicalCaseExpanded:
          isClinicalCaseExpanded ?? this.isClinicalCaseExpanded,
    );
  }
}

class QuizSessionNotifier extends StateNotifier<QuizSessionState> {
  final QuizRepository _repository;
  final Ref _ref;
  Timer? _timer;

  QuizSessionNotifier(this._repository, this._ref) : super(QuizSessionState());

  void initialize(QuizSession session) {
    int? timeLimit = session.filters['timeLimit'];
    bool isExplore = session.filters['isExplore'] ?? false;
    bool isPractice = session.filters['isPractice'] ?? true;
    int initialTime = 0;
    bool isCountdown = false;

    if (timeLimit != null) {
      initialTime = timeLimit * 60;
      isCountdown = true;
    }

    state = state.copyWith(
      correctionMode: session.correctionMode,
      timeSeconds: initialTime,
      isCountdown: isCountdown,
      isInitialized: true,
      isExplore: isExplore,
      isPractice: isPractice,
    );

    if (session.questions.isNotEmpty) {
      final q = session.questions[0];
      _updateInteractionState(q);
      if (isExplore) {
        autoSolve(q);
      }
    }
  }

  void _updateInteractionState(Question q) {
    //Convert backend JSON highlights to local model
    Map<String, List<HighlightModel>> mappedHighlights = {};
    String? questionNote;

    //1.Process Question Highlights
    if (q.myHighlights != null) {
      _parseHighlights(q.myHighlights!, mappedHighlights, (note) {
        questionNote = note;
      });
    }

    //2.Process Clinical Case Highlights(New)
    if (q.clinicalCase?.myHighlights != null) {
      _parseHighlights(q.clinicalCase!.myHighlights!, mappedHighlights, (_) {});
    }

    //Convert backend comments to local model
    final List<CommentModel> localComments = q.comments
        .map((c) => _mapToLocalComment(c))
        .toList();

    //Sort top-level comments by votes(upvotes-downvotes)descending
    localComments.sort((a, b) {
      final scoreA = a.upvotes - a.downvotes;
      final scoreB = b.upvotes - b.downvotes;
      return scoreB.compareTo(scoreA);
    });

    state = state.copyWith(
      isStarred: q.isSaved,
      highlights: mappedHighlights,
      comments: localComments,
      questionNote: questionNote,
      clinicalCaseNote: q.clinicalCase?.myNote?.text,
    );
  }

  void _parseHighlights(
    String jsonStr,
    Map<String, List<HighlightModel>> target,
    Function(String?) onGlobalNote,
  ) {
    try {
      final decoded = json.decode(jsonStr);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('global_question_note')) {
          onGlobalNote(decoded['global_question_note'] as String?);
        }
        decoded.forEach((key, value) {
          if (value is List) {
            target[key] = value
                .map((h) => HighlightModel.fromJson(h as Map<String, dynamic>))
                .toList();
          }
        });
      }
    } catch (e) {
      debugPrint('DEBUG:Error decoding highlights: $e');
    }
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isCountdown) {
        if (state.timeSeconds > 0) {
          state = state.copyWith(timeSeconds: state.timeSeconds - 1);
        } else {
          stopTimer();
          state = state.copyWith(isFinished: true);
        }
      } else {
        state = state.copyWith(timeSeconds: state.timeSeconds + 1);
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void toggleOption(int propositionId) {
    if (state.showFeedback) return;
    final newSelection = Set<int>.from(state.selectedOptionIds);
    if (newSelection.contains(propositionId)) {
      newSelection.remove(propositionId);
    } else {
      newSelection.add(propositionId);
    }
    state = state.copyWith(selectedOptionIds: newSelection);
  }

  void selectOption(int propositionId) {
    if (state.showFeedback) return;
    state = state.copyWith(selectedOptionIds: {propositionId});
  }

  void submit(Question question) {
    if (state.selectedOptionIds.isEmpty) return;

    try {
      final result = _repository.submitQuizAnswerLocal(
        question,
        state.selectedOptionIds,
        state.correctionMode,
      );

      final newUserAnswers = Map<int, Set<int>>.from(state.userAnswers);
      newUserAnswers[question.id] = state.selectedOptionIds;

      final newResults = Map<int, AnswerResult>.from(state.results);
      newResults[question.id] = result;

      state = state.copyWith(
        showFeedback: true,
        userAnswers: newUserAnswers,
        results: newResults,
      );
    } catch (e) {
      debugPrint('DEBUG:QuizSessionNotifier.submit ERROR: $e');
    }
  }

  void autoSolve(Question question) {
    final correctPropIds = question.propositions
        .where((p) => p.isCorrect)
        .map((p) => p.id)
        .toSet();

    final result = _repository.submitQuizAnswerLocal(
      question,
      correctPropIds,
      state.correctionMode,
    );

    final newUserAnswers = Map<int, Set<int>>.from(state.userAnswers);
    newUserAnswers[question.id] = correctPropIds;

    final newResults = Map<int, AnswerResult>.from(state.results);
    newResults[question.id] = result;

    state = state.copyWith(
      selectedOptionIds: correctPropIds,
      showFeedback: true,
      userAnswers: newUserAnswers,
      results: newResults,
    );
  }

  Future<void> syncSession(QuizSession session) async {
    state = state.copyWith(isLoading: true);
    try {
      //Update session object with latest state
      session.userAnswers = state.userAnswers;
      session.isCompleted = true;

      await _repository.syncQuizSession(session);
    } catch (e) {
      debugPrint('DEBUG:syncSession ERROR: $e');
      //Potential for offline persistence here
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void next(List<Question> questions) {
    if (state.currentQuestionIndex < questions.length - 1) {
      final currentQ = questions[state.currentQuestionIndex];

      //Save answer on navigation
      final newUserAnswers = Map<int, Set<int>>.from(state.userAnswers);
      newUserAnswers[currentQ.id] = state.selectedOptionIds;

      final nextIndex = state.currentQuestionIndex + 1;
      final nextQ = questions[nextIndex];

      final result = state.results[nextQ.id];

      state = state.copyWith(
        currentQuestionIndex: nextIndex,
        showFeedback: result != null,
        selectedOptionIds: newUserAnswers[nextQ.id] ?? const {},
        userAnswers: newUserAnswers,
      );

      _updateInteractionState(nextQ);
      if (state.isExplore) {
        autoSolve(nextQ);
      }
    }
  }

  void previous(List<Question> questions) {
    if (state.currentQuestionIndex > 0) {
      final currentQ = questions[state.currentQuestionIndex];

      //Save answer on navigation
      final newUserAnswers = Map<int, Set<int>>.from(state.userAnswers);
      newUserAnswers[currentQ.id] = state.selectedOptionIds;

      final prevIndex = state.currentQuestionIndex - 1;
      final prevQ = questions[prevIndex];

      final result = state.results[prevQ.id];

      state = state.copyWith(
        currentQuestionIndex: prevIndex,
        showFeedback: result != null,
        selectedOptionIds: newUserAnswers[prevQ.id] ?? const {},
        userAnswers: newUserAnswers,
      );

      _updateInteractionState(prevQ);
      if (state.isExplore) {
        autoSolve(prevQ);
      }
    }
  }

  void jumpTo(int index, List<Question> questions) {
    if (index >= 0 && index < questions.length) {
      final currentQ = questions[state.currentQuestionIndex];

      //Save current selection
      final newUserAnswers = Map<int, Set<int>>.from(state.userAnswers);
      newUserAnswers[currentQ.id] = state.selectedOptionIds;

      final nextQ = questions[index];

      //If already has result,show feedback
      final result = state.results[nextQ.id];

      state = state.copyWith(
        currentQuestionIndex: index,
        showFeedback: result != null,
        selectedOptionIds: newUserAnswers[nextQ.id] ?? const {},
        userAnswers: newUserAnswers,
      );

      _updateInteractionState(nextQ);
      if (state.isExplore) {
        autoSolve(nextQ);
      }
    }
  }

  void verify(Question question) {
    submit(question);
  }

  void finishQuiz(List<Question> questions) {
    stopTimer();

    //If simulation mode,calculate all results now
    final newResults = Map<int, AnswerResult>.from(state.results);
    final newUserAnswers = Map<int, Set<int>>.from(state.userAnswers);

    //Save final question answer
    if (questions.isNotEmpty) {
      final currentQ = questions[state.currentQuestionIndex];
      newUserAnswers[currentQ.id] = state.selectedOptionIds;
    }

    if (!state.isPractice) {
      for (var q in questions) {
        final answers = newUserAnswers[q.id] ?? {};
        final result = _repository.submitQuizAnswerLocal(
          q,
          answers,
          state.correctionMode,
        );
        newResults[q.id] = result;
      }
    }

    state = state.copyWith(
      isFinished: true,
      results: newResults,
      userAnswers: newUserAnswers,
    );
  }

  void resetQuiz() {
    stopTimer();
    state = QuizSessionState();
  }

  void reviewQuestion(int index, Set<int> propositionIds) {
    state = state.copyWith(
      currentQuestionIndex: index,
      showFeedback: true,
      selectedOptionIds: propositionIds,
      isFinished: false,
    );
  }

  void addHighlight(
    int questionId,
    String textId,
    String text,
    int start,
    int end,
    Color color, {
    String? note,
    int? clinicalCaseId,
  }) {
    final highlight = HighlightModel(
      id: const Uuid().v4(),
      text: text,
      start: start,
      end: end,
      color: color,
      note: note,
    );

    final newHighlights = Map<String, List<HighlightModel>>.from(
      state.highlights,
    );
    final textHighlights = List<HighlightModel>.from(
      newHighlights[textId] ?? [],
    );
    textHighlights.add(highlight);
    newHighlights[textId] = textHighlights;

    state = state.copyWith(highlights: newHighlights);
    _syncHighlights(questionId, clinicalCaseId: clinicalCaseId);
  }

  Future<void> _syncHighlights(int questionId, {int? clinicalCaseId}) async {
    try {
      //Split highlights by source(clinicalCase vs question)
      final Map<String, List<HighlightModel>> questionHighlights = {};
      final Map<String, List<HighlightModel>> clinicalCaseHighlights = {};

      state.highlights.forEach((textId, highlights) {
        if (textId.startsWith('cc_')) {
          clinicalCaseHighlights[textId] = highlights;
        } else {
          questionHighlights[textId] = highlights;
        }
      });

      //Sync Question Highlights
      final Map<String, dynamic> qData = Map.from(questionHighlights);
      if (state.questionNote != null && state.questionNote!.isNotEmpty) {
        qData['global_question_note'] = state.questionNote;
      }
      await _repository.syncHighlights(questionId, json.encode(qData));

      //Sync Clinical Case Highlights if needed
      if (clinicalCaseId != null && clinicalCaseHighlights.isNotEmpty) {
        await _repository.syncClinicalCaseHighlights(
          clinicalCaseId,
          json.encode(clinicalCaseHighlights),
        );
      }
    } catch (e) {
      debugPrint('DEBUG:syncHighlights ERROR: $e');
    }
  }

  void removeHighlight(
    int questionId,
    String textId,
    String highlightId, {
    int? clinicalCaseId,
  }) {
    final newHighlights = Map<String, List<HighlightModel>>.from(
      state.highlights,
    );
    final textHighlights = List<HighlightModel>.from(
      newHighlights[textId] ?? [],
    );
    textHighlights.removeWhere((h) => h.id == highlightId);
    newHighlights[textId] = textHighlights;

    state = state.copyWith(highlights: newHighlights);
    _syncHighlights(questionId, clinicalCaseId: clinicalCaseId);
  }

  void updateHighlightNote(
    int questionId,
    String textId,
    String highlightId,
    String note, {
    int? clinicalCaseId,
  }) {
    if (!state.highlights.containsKey(textId)) return;

    final updatedHighlights = state.highlights[textId]!.map((h) {
      if (h.id == highlightId) {
        return h.copyWith(note: note);
      }
      return h;
    }).toList();

    state = state.copyWith(
      highlights: {...state.highlights, textId: updatedHighlights},
    );
    _syncHighlights(questionId, clinicalCaseId: clinicalCaseId);
  }

  void updateQuestionNote(int questionId, String note) {
    state = state.copyWith(questionNote: note);
    _syncHighlights(questionId);
  }

  void removeQuestionNote(int questionId) {
    state = state.copyWith(questionNote: null);
    _syncHighlights(questionId);
  }

  Future<void> updateClinicalCaseNote(int clinicalCaseId, String note) async {
    state = state.copyWith(clinicalCaseNote: note);
    try {
      await _repository.syncClinicalCaseNote(clinicalCaseId, note);
    } catch (e) {
      debugPrint('DEBUG:updateClinicalCaseNote ERROR: $e');
    }
  }

  Future<void> toggleSave(int questionId) async {
    final oldState = state.isStarred;
    state = state.copyWith(isStarred: !oldState);
    try {
      await _repository.toggleSaveQuestion(questionId);
      //Invalidate to refresh SavedQuizzesScreen
      _ref.invalidate(mySavedQuestionsProvider);
    } catch (e) {
      state = state.copyWith(isStarred: oldState);
      debugPrint('DEBUG:toggleSave ERROR: $e');
    }
  }

  void refreshStarStatus(int questionId, bool isStarred) {
    //We assume this is called for the current question
    state = state.copyWith(isStarred: isStarred);
  }

  void toggleClinicalCaseExpansion() {
    state = state.copyWith(
      isClinicalCaseExpanded: !state.isClinicalCaseExpanded,
    );
  }

  CommentModel _mapToLocalComment(QuestionComment c) {
    return CommentModel(
      id: c.id,
      author: c.author,
      text: c.text,
      isEdited: c.isEdited,
      createdAt: c.createdAt,
      parentId: c.parentId,
      upvotes: c.upvotes,
      downvotes: c.downvotes,
      myVote: c.myVote,
      isMine: c.isMine,
      replies: c.replies.map((r) => _mapToLocalComment(r)).toList()
        ..sort((a, b) {
          final scoreA = a.upvotes - a.downvotes;
          final scoreB = b.upvotes - b.downvotes;
          return scoreB.compareTo(scoreA);
        }),
    );
  }

  Future<void> addComment(
    int questionId,
    String text, {
    String? parentId,
  }) async {
    final tempId = const Uuid().v4();
    final optimisticComment = CommentModel(
      id: tempId,
      author: 'Me',
      text: text,
      createdAt: DateTime.now(),
      parentId: parentId,
      isMine: true,
    );

    //Optimistic Update
    final List<CommentModel> updatedComments = List.from(state.comments);
    if (parentId == null) {
      updatedComments.add(optimisticComment);
    } else {
      _addReplyOptimistically(updatedComments, parentId, optimisticComment);
    }
    state = state.copyWith(comments: updatedComments);

    debugPrint('DEBUG:addComment-Starting sync for tempId: $tempId');
    try {
      final comment = await _repository.addComment(
        questionId,
        text,
        parentId: parentId,
      );
      debugPrint('DEBUG:addComment-Server returned ID: ${comment.id}');
      final localComment = _mapToLocalComment(comment);

      //Replace temporary comment with real one
      final newComments = _replaceCommentById(
        state.comments,
        tempId,
        localComment,
      );
      state = state.copyWith(comments: newComments);
      debugPrint('DEBUG:addComment-Replaced tempId successfully');
    } catch (e, stack) {
      debugPrint('DEBUG:addComment ERROR: $e');
      debugPrint('DEBUG:stacktrace: $stack');
      //Rollback
      state = state.copyWith(
        comments: _removeCommentById(state.comments, tempId),
      );
    }
  }

  bool _addReplyOptimistically(
    List<CommentModel> comments,
    String parentId,
    CommentModel reply,
  ) {
    for (int i = 0; i < comments.length; i++) {
      if (comments[i].id == parentId) {
        comments[i] = comments[i].copyWith(
          replies: [...comments[i].replies, reply],
        );
        return true;
      }
      if (comments[i].replies.isNotEmpty) {
        final nestedReplies = List<CommentModel>.from(comments[i].replies);
        if (_addReplyOptimistically(nestedReplies, parentId, reply)) {
          comments[i] = comments[i].copyWith(replies: nestedReplies);
          return true;
        }
      }
    }
    return false;
  }

  List<CommentModel> _replaceCommentById(
    List<CommentModel> comments,
    String id,
    CommentModel replacement,
  ) {
    return comments.map((c) {
      if (c.id == id) return replacement;
      if (c.replies.isNotEmpty) {
        return c.copyWith(
          replies: _replaceCommentById(c.replies, id, replacement),
        );
      }
      return c;
    }).toList();
  }

  List<CommentModel> _removeCommentById(
    List<CommentModel> comments,
    String id,
  ) {
    return comments.where((c) => c.id != id).map((c) {
      if (c.replies.isNotEmpty) {
        return c.copyWith(replies: _removeCommentById(c.replies, id));
      }
      return c;
    }).toList();
  }

  Future<void> voteComment(String commentId, int vote) async {
    //vote is 1, -1,or 0
    final oldComments = state.comments;

    //Optimistic update
    state = state.copyWith(
      comments: _updateVoteOptimistically(state.comments, commentId, vote),
    );

    try {
      final updatedComment = await _repository.voteComment(commentId, vote);
      state = state.copyWith(
        comments: _replaceCommentById(
          state.comments,
          commentId,
          _mapToLocalComment(updatedComment),
        ),
      );
    } catch (e) {
      debugPrint('DEBUG:voteComment ERROR: $e');
      state = state.copyWith(comments: oldComments);
    }
  }

  List<CommentModel> _updateVoteOptimistically(
    List<CommentModel> comments,
    String commentId,
    int newVote,
  ) {
    return comments.map((c) {
      if (c.id == commentId) {
        int upAdjust = 0;
        int downAdjust = 0;

        //Revert old vote
        if (c.myVote == 1) upAdjust--;
        if (c.myVote == -1) downAdjust--;

        //Apply new vote
        if (newVote == 1) upAdjust++;
        if (newVote == -1) downAdjust++;

        return c.copyWith(
          myVote: newVote == 0 ? null : newVote,
          upvotes: c.upvotes + upAdjust,
          downvotes: c.downvotes + downAdjust,
        );
      }
      if (c.replies.isNotEmpty) {
        return c.copyWith(
          replies: _updateVoteOptimistically(c.replies, commentId, newVote),
        );
      }
      return c;
    }).toList();
  }

  Future<void> editComment(String id, String newText) async {
    final oldComments = state.comments;

    //Optimistic UI
    state = state.copyWith(
      comments: _updateTextOptimistically(state.comments, id, newText),
    );

    try {
      final comment = await _repository.editComment(id, newText);
      state = state.copyWith(
        comments: _replaceCommentById(
          state.comments,
          id,
          _mapToLocalComment(comment),
        ),
      );
    } catch (e) {
      debugPrint('DEBUG:editComment ERROR: $e');
      state = state.copyWith(comments: oldComments);
    }
  }

  List<CommentModel> _updateTextOptimistically(
    List<CommentModel> comments,
    String id,
    String text,
  ) {
    return comments.map((c) {
      if (c.id == id) return c.copyWith(text: text, isEdited: true);
      if (c.replies.isNotEmpty) {
        return c.copyWith(
          replies: _updateTextOptimistically(c.replies, id, text),
        );
      }
      return c;
    }).toList();
  }

  Future<void> deleteComment(String id) async {
    final oldComments = state.comments;
    state = state.copyWith(comments: _removeCommentById(state.comments, id));

    try {
      await _repository.deleteComment(id);
    } catch (e) {
      debugPrint('DEBUG:deleteComment ERROR: $e');
      state = state.copyWith(comments: oldComments);
    }
  }

  Future<void> reportComment(String commentId, String reason) async {
    try {
      await _repository.reportComment(commentId, reason);
    } catch (e) {
      debugPrint('DEBUG:reportComment ERROR: $e');
      rethrow;
    }
  }
}

final quizSessionProvider =
    StateNotifierProvider.autoDispose<QuizSessionNotifier, QuizSessionState>((
      ref,
    ) {
      final repository = ref.watch(quizRepositoryProvider);
      return QuizSessionNotifier(repository, ref);
    });
