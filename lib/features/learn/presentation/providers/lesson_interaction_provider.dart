import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/quiz/domain/models/comment_model.dart';
import 'package:uuid/uuid.dart';

enum InteractionType { lesson, course }

enum LearnReportReason { typo, inaccurate, missing, unclear, other }

class InteractionState {
  final List<CommentModel> comments;
  final bool isLoading;
  final bool isReportingSuccess;
  final bool isReportingLoading;
  final LearnReportReason? selectedReportReason;
  final String customReportDescription;
  final Map<String, List<HighlightModel>> optimisticHighlights;
  final Map<String, String> optimisticNotes;

  InteractionState({
    this.comments = const [],
    this.isLoading = false,
    this.isReportingSuccess = false,
    this.isReportingLoading = false,
    this.selectedReportReason,
    this.customReportDescription = '',
    this.optimisticHighlights = const {},
    this.optimisticNotes = const {},
  });

  InteractionState copyWith({
    List<CommentModel>? comments,
    bool? isLoading,
    bool? isReportingSuccess,
    bool? isReportingLoading,
    LearnReportReason? selectedReportReason,
    String? customReportDescription,
    Map<String, List<HighlightModel>>? optimisticHighlights,
    Map<String, String>? optimisticNotes,
  }) {
    return InteractionState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isReportingSuccess: isReportingSuccess ?? this.isReportingSuccess,
      isReportingLoading: isReportingLoading ?? this.isReportingLoading,
      selectedReportReason: selectedReportReason ?? this.selectedReportReason,
      customReportDescription:
          customReportDescription ?? this.customReportDescription,
      optimisticHighlights: optimisticHighlights ?? this.optimisticHighlights,
      optimisticNotes: optimisticNotes ?? this.optimisticNotes,
    );
  }
}

class InteractionNotifier extends StateNotifier<InteractionState> {
  final CourseRepository _repository;
  final String _id;
  final InteractionType _type;
  final Ref _ref;

  InteractionNotifier(this._repository, this._id, this._type, this._ref)
    : super(InteractionState());

  Future<void> addComment(String text, {String? parentId}) async {
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

    try {
      if (_type == InteractionType.lesson) {
        await _repository.addLessonComment(_id, text, parentId: parentId);
      } else {
        await _repository.addCourseComment(_id, text, parentId: parentId);
      }
    } catch (e) {
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

  Future<void> report() async {
    if (state.selectedReportReason == null) return;
    state = state.copyWith(isReportingLoading: true, isReportingSuccess: false);
    try {
      final reason = state.selectedReportReason!.name;
      final description = state.selectedReportReason == LearnReportReason.other
          ? state.customReportDescription
          : null;

      if (_type == InteractionType.lesson) {
        await _repository.reportLesson(_id, reason, description);
      } else {
        await _repository.reportCourse(_id, reason, description);
      }

      state = state.copyWith(
        isReportingLoading: false,
        isReportingSuccess: true,
      );
    } catch (e) {
      state = state.copyWith(isReportingLoading: false);
      rethrow;
    }
  }

  void setReportReason(LearnReportReason reason) {
    state = state.copyWith(selectedReportReason: reason);
  }

  void setCustomReportDescription(String description) {
    state = state.copyWith(customReportDescription: description);
  }

  void resetReportStatus() {
    state = state.copyWith(
      isReportingSuccess: false,
      isReportingLoading: false,
      selectedReportReason: null,
      customReportDescription: '',
    );
  }

  Future<void> deleteComment(String commentId) async {
    final originalComments = List<CommentModel>.from(state.comments);
    state = state.copyWith(
      comments: _removeCommentById(state.comments, commentId),
    );

    try {
      if (_type == InteractionType.lesson) {
        await _repository.deleteLessonComment(commentId);
      } else {
        await _repository.deleteCourseComment(commentId);
      }
    } catch (e) {
      state = state.copyWith(comments: originalComments);
    }
  }

  Future<void> voteComment(String commentId, int vote) async {
    final originalComments = List<CommentModel>.from(state.comments);
    final updatedComments = _updateCommentInList(state.comments, commentId, (
      c,
    ) {
      int newUpvotes = c.upvotes;
      int newDownvotes = c.downvotes;

      //Reverse previous vote
      if (c.myVote == 1) newUpvotes--;
      if (c.myVote == -1) newDownvotes--;

      //Apply new vote
      if (vote == 1) newUpvotes++;
      if (vote == -1) newDownvotes++;

      return c.copyWith(
        myVote: vote,
        upvotes: newUpvotes,
        downvotes: newDownvotes,
      );
    });

    state = state.copyWith(comments: updatedComments);

    try {
      await _repository.voteComment(commentId, vote);
    } catch (e) {
      state = state.copyWith(comments: originalComments);
    }
  }

  Future<void> editComment(String commentId, String text) async {
    final originalComments = List<CommentModel>.from(state.comments);
    final updatedComments = _updateCommentInList(state.comments, commentId, (
      c,
    ) {
      return c.copyWith(text: text, isEdited: true);
    });

    state = state.copyWith(comments: updatedComments);

    try {
      if (_type == InteractionType.lesson) {
        await _repository.editLessonComment(commentId, text);
      } else {
        await _repository.editCourseComment(commentId, text);
      }
    } catch (e) {
      state = state.copyWith(comments: originalComments);
    }
  }

  List<CommentModel> _updateCommentInList(
    List<CommentModel> comments,
    String id,
    CommentModel Function(CommentModel) updater,
  ) {
    return comments.map((c) {
      if (c.id == id) {
        return updater(c);
      }
      if (c.replies.isNotEmpty) {
        return c.copyWith(
          replies: _updateCommentInList(c.replies, id, updater),
        );
      }
      return c;
    }).toList();
  }

  Future<void> addHighlight(
    String paragraphId,
    List<HighlightModel> currentHighlights,
    HighlightModel newHighlight,
  ) async {
    try {
      if (_type == InteractionType.lesson) {
        final allHighlights = [...currentHighlights, newHighlight];
        state = state.copyWith(
          optimisticHighlights: {
            ...state.optimisticHighlights,
            paragraphId: allHighlights,
          },
        );
        await _repository.syncParagraphHighlights(
          paragraphId,
          allHighlights.map((h) => h.toJson()).toList(),
        );
        await _repository.clearLessonDetailsCache(_id);
        _ref.invalidate(lessonDetailsProvider(_id));
      }
    } catch (e) {
      debugPrint('DEBUG:addHighlight ERROR: $e');
    }
  }

  Future<void> updateHighlightNote(
    String paragraphId,
    List<HighlightModel> currentHighlights,
    String highlightId,
    String note,
  ) async {
    try {
      if (_type == InteractionType.lesson) {
        final allHighlights = currentHighlights.map((h) {
          if (h.id == highlightId) {
            return h.copyWith(note: note);
          }
          return h;
        }).toList();

        state = state.copyWith(
          optimisticHighlights: {
            ...state.optimisticHighlights,
            paragraphId: allHighlights,
          },
        );

        await _repository.syncParagraphHighlights(
          paragraphId,
          allHighlights.map((h) => h.toJson()).toList(),
        );
        await _repository.clearLessonDetailsCache(_id);
        _ref.invalidate(lessonDetailsProvider(_id));
      }
    } catch (e) {
      debugPrint('DEBUG:updateHighlightNote ERROR: $e');
    }
  }

  Future<void> saveParagraphNote(String paragraphId, String note) async {
    try {
      if (_type == InteractionType.lesson) {
        state = state.copyWith(
          optimisticNotes: {...state.optimisticNotes, paragraphId: note},
        );
        await _repository.addParagraphNote(paragraphId, note);
        await _repository.clearLessonDetailsCache(_id);
        _ref.invalidate(lessonDetailsProvider(_id));
      }
    } catch (e) {
      debugPrint('DEBUG:saveParagraphNote ERROR: $e');
    }
  }

  Future<void> deleteParagraphNote(String paragraphId, String? noteId) async {
    try {
      if (_type == InteractionType.lesson) {
        state = state.copyWith(
          optimisticNotes: {...state.optimisticNotes, paragraphId: ""},
        );
        if (noteId != null) {
          await _repository.deleteParagraphNote(noteId);
        }
        await _repository.clearLessonDetailsCache(_id);
        _ref.invalidate(lessonDetailsProvider(_id));
      }
    } catch (e) {
      debugPrint('DEBUG:deleteParagraphNote ERROR: $e');
    }
  }

  Future<void> deleteHighlight(
    String paragraphId,
    List<HighlightModel> currentHighlights,
    String highlightId,
  ) async {
    try {
      if (_type == InteractionType.lesson) {
        final allHighlights = currentHighlights
            .where((h) => h.id != highlightId)
            .toList();
        state = state.copyWith(
          optimisticHighlights: {
            ...state.optimisticHighlights,
            paragraphId: allHighlights,
          },
        );
        await _repository.syncParagraphHighlights(
          paragraphId,
          allHighlights.map((h) => h.toJson()).toList(),
        );
        await _repository.clearLessonDetailsCache(_id);
        _ref.invalidate(lessonDetailsProvider(_id));
      }
    } catch (e) {
      debugPrint('DEBUG:deleteHighlight ERROR: $e');
    }
  }

  Future<void> updateHighlightColor(
    String paragraphId,
    List<HighlightModel> currentHighlights,
    String highlightId,
    Color newColor,
  ) async {
    try {
      if (_type == InteractionType.lesson) {
        final allHighlights = currentHighlights.map((h) {
          if (h.id == highlightId) {
            return h.copyWith(color: newColor);
          }
          return h;
        }).toList();

        state = state.copyWith(
          optimisticHighlights: {
            ...state.optimisticHighlights,
            paragraphId: allHighlights,
          },
        );

        await _repository.syncParagraphHighlights(
          paragraphId,
          allHighlights.map((h) => h.toJson()).toList(),
        );
        await _repository.clearLessonDetailsCache(_id);
        _ref.invalidate(lessonDetailsProvider(_id));
      }
    } catch (e) {
      debugPrint('DEBUG:updateHighlightColor ERROR: $e');
    }
  }

  Future<void> toggleLessonStudied() async {
    try {
      if (_type == InteractionType.lesson) {
        await _repository.toggleLessonStudied(_id);
        //Invalidate to refresh progress bars and lesson flags
        _ref.invalidate(learnModulesProvider);
        _ref.invalidate(moduleLessonsProvider);
      }
    } catch (e) {
      debugPrint('DEBUG:toggleLessonStudied ERROR: $e');
      rethrow;
    }
  }
}

typedef InteractionParams = ({String id, InteractionType type});

final interactionProvider =
    StateNotifierProvider.family<
      InteractionNotifier,
      InteractionState,
      InteractionParams
    >((ref, params) {
      final repo = ref.watch(learnRepositoryProvider);
      return InteractionNotifier(repo, params.id, params.type, ref);
    });

//Maintain compatibility for Lesson specialized usage if needed
final lessonInteractionProvider = Provider.family<InteractionParams, String>((
  ref,
  id,
) {
  return (id: id, type: InteractionType.lesson);
});

final courseInteractionProvider = Provider.family<InteractionParams, String>((
  ref,
  id,
) {
  return (id: id, type: InteractionType.course);
});
