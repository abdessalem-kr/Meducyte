import 'dart:convert';
import 'package:meducyte_app/export.dart';
import 'package:uuid/uuid.dart';
import 'package:meducyte_app/core/network/dio_client.dart';
import 'package:meducyte_app/shared/providers/network_provider.dart';

class QuizFilters {
  final List<int>? years;
  final List<String>? moduleIds;
  final List<String>? lessonIds;
  final List<String>? sources;
  final List<String>? questionIds;
  final bool isPractice;
  final bool isExplore;
  final QuizCorrectionMode correctionMode;
  final int? timeLimit;
  final bool? hasClinicalCase;
  final int limit;
  final int offset;

  QuizFilters({
    this.years,
    this.moduleIds,
    this.lessonIds,
    this.sources,
    this.questionIds,
    required this.isPractice,
    this.isExplore = false,
    this.correctionMode = QuizCorrectionMode.allOrNothing,
    this.timeLimit,
    this.hasClinicalCase,
    this.limit = 100,
    this.offset = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'years': years,
      'moduleIds': moduleIds,
      'lessonIds': lessonIds,
      'sources': sources,
      'questionIds': questionIds,
      'isPractice': isPractice,
      'isExplore': isExplore,
      'correctionMode': correctionMode.name,
      if (timeLimit != null) 'timeLimit': timeLimit,
      if (hasClinicalCase != null) 'hasClinicalCase': hasClinicalCase,
      'limit': limit,
      'offset': offset,
    };
  }
}

//REPOSITORY
class QuizRepository {
  final DioClient _client;

  QuizRepository(this._client);

  Future<QuizSession> startPracticeSession(QuizFilters filters) async {
    const String query = r'''
  query GetQuestions($moduleIds: [ID], $lessonIds: [ID], $years: [Int], $sources: [String], $ids: [ID!], $useIds:Boolean!, $hasClinicalCase:Boolean, $limit:Int, $offset:Int) {
    questions(moduleIds: $moduleIds,lessonIds: $lessonIds,years: $years,sources: $sources,hasClinicalCase: $hasClinicalCase,limit: $limit,offset: $offset) @skip(if: $useIds) {
       ...QuestionFields
     }
    questionsByIds(ids: $ids) @include(if: $useIds) {
       ...QuestionFields
     }
   }

  fragment QuestionFields on Question{
    id
    text
    source_exam
    tags
    estimated_time
    lesson{
      title
      module{
        name
        year
       }
     }
    propositions{
      id
      questionId
      label
      text
      isCorrect
     }
    comments{
      id
      parent_id
      text
      is_edited
      upvotes
      downvotes
      my_vote
      is_mine
      created_at
      user{
        name
       }
      replies{
        id
        parent_id
        text
        is_edited
        upvotes
        downvotes
        my_vote
        is_mine
        created_at
        user{
          name
         }
       }
     }
    my_highlights
    saved_by_user
    clinicalCase{
      id
      text
      title
      my_highlights
      my_note{
        id
        text
        thumbnail_url
       }
     }
   }
 ''';

    try {
      debugPrint(
        'DEBUG:startPracticeSession-Sending request with filters: ${filters.toJson()}',
      );
      final response = await _client.post(
        '/graphql',
        data: {
          'query': query,
          'variables': {
            'moduleIds': filters.moduleIds,
            'lessonIds': filters.lessonIds,
            'years': filters.years,
            'sources': filters.sources,
            'ids': filters.questionIds,
            'useIds':
                filters.questionIds != null && filters.questionIds!.isNotEmpty,
            'limit': filters.limit,
            'offset': filters.offset,
            'hasClinicalCase': filters.hasClinicalCase,
          },
        },
      );

      debugPrint(
        'DEBUG:startPracticeSession-Response status: ${response.statusCode}',
      );
      debugPrint('DEBUG:startPracticeSession-Response body: ${response.data}');

      final Map<String, dynamic> responseData =
          response.data as Map<String, dynamic>;
      if (responseData['errors'] != null) {
        final errorMsg = responseData['errors'][0]['message'];
        debugPrint('DEBUG:startPracticeSession GraphQL Error: $errorMsg');
        throw Exception('GraphQL error: $errorMsg');
      }

      final data = responseData['data'] as Map<String, dynamic>;
      final questionsData =
          (data['questions'] ?? data['questionsByIds']) as List?;

      if (questionsData == null) {
        debugPrint('DEBUG:startPracticeSession-No questions found in response');
        return QuizSession(
          id: const Uuid().v4(),
          questions: [],
          startTime: DateTime.now(),
          filters: filters.toJson(),
        );
      }

      var questions = questionsData.map((q) => Question.fromJson(q)).toList();

      //Client-side truncation if limit is specified(and not-1 for All)
      if (filters.limit > 0 && questions.length > filters.limit) {
        debugPrint(
          'DEBUG:startPracticeSession-Truncating from${questions.length}to${filters.limit}',
        );
        questions = questions.take(filters.limit).toList();
      }

      debugPrint(
        'DEBUG:startPracticeSession-Loaded${questions.length}questions',
      );

      return QuizSession(
        id: const Uuid().v4(),
        questions: questions,
        startTime: DateTime.now(),
        filters: filters.toJson(),
        correctionMode: filters.correctionMode,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      debugPrint('DEBUG:startPracticeSession CATCH: $e');
      throw Exception('Failed to load quiz session: $e');
    }
  }

  Future<List<Question>> getQuestionsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    const String query = r'''
  query GetQuestionsByIds($ids: [ID!]!) {
    questionsByIds(ids: $ids) {
      id
      text
      source_exam
      tags
      estimated_time
      lesson{
        title
        module{
          name
          year
         }
       }
      propositions{
        id
        questionId
        label
        text
        isCorrect
       }
      clinicalCase{
        id
        text
        title
        my_highlights
        my_note{
          id
          text
          thumbnail_url
         }
       }
     }
   }
 ''';

    try {
      final response = await _client.post(
        '/graphql',
        data: {
          'query': query,
          'variables': {'ids': ids.map((id) => id.toString()).toList()},
        },
      );

      final Map<String, dynamic> responseData =
          response.data as Map<String, dynamic>;
      if (responseData['errors'] != null) {
        throw Exception(responseData['errors'][0]['message']);
      }

      final questionsData = responseData['data']['questionsByIds'] as List?;
      if (questionsData == null) return [];

      return questionsData.map((q) => Question.fromJson(q)).toList();
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      debugPrint('DEBUG:getQuestionsByIds CATCH: $e');
      return [];
    }
  }

  ///Local validation:returns whether the selected propositions are correct.
  ///This replaces the server-side per-question validation.
  AnswerResult submitQuizAnswerLocal(
    Question question,
    Set<int> selectedPropositionIds,
    QuizCorrectionMode mode,
  ) {
    try {
      debugPrint(
        'DEBUG:submitQuizAnswerLocal-Question: ${question.id},Selected: $selectedPropositionIds,Mode: ${mode.name}',
      );

      final correctPropIds = question.propositions
          .where((p) => p.isCorrect)
          .map((p) => p.id)
          .toSet();

      if (mode == QuizCorrectionMode.allOrNothing) {
        final bool isCorrect =
            selectedPropositionIds.length == correctPropIds.length &&
            selectedPropositionIds.containsAll(correctPropIds);

        return AnswerResult(
          isCorrect: isCorrect,
          score: isCorrect ? 1.0 : 0.0,
          correctPropositionId: correctPropIds.isNotEmpty
              ? correctPropIds.first
              : null,
          explanation: null,
        );
      } else {
        //Simple Ratio scoring: (correct selected) / (total correct)
        final correctlySelected = selectedPropositionIds
            .where((id) => correctPropIds.contains(id))
            .length;
        final totalCorrect = correctPropIds.length;

        double score = totalCorrect > 0
            ? correctlySelected / totalCorrect
            : 0.0;

        return AnswerResult(
          isCorrect: score > 0,
          score: score,
          correctPropositionId: correctPropIds.isNotEmpty
              ? correctPropIds.first
              : null,
          explanation: null,
        );
      }
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      debugPrint('DEBUG:submitQuizAnswerLocal CATCH: $e');
      throw Exception('Failed to validate answer locally: $e');
    }
  }

  ///Batch sync the entire quiz session results to the backend.
  Future<void> syncQuizSession(QuizSession session) async {
    const String mutation = r'''
  mutation SyncQuizSession($sessionId: String!, $results: JSON!) {
    syncQuizSession(sessionId: $sessionId, results: $results)
  }
 ''';

    try {
      debugPrint('DEBUG:syncQuizSession-Syncing session: ${session.id}');
      final response = await _client.post(
        '/graphql',
        data: {
          'query': mutation,
          'variables': {'sessionId': session.id, 'results': session.toJson()},
        },
      );
      final mapData = response.data as Map<String, dynamic>?;
      if (mapData != null && mapData['errors'] != null) {
        final errorMsg = mapData['errors'][0]['message'];
        throw Exception('GraphQL error: $errorMsg');
      }
      debugPrint('DEBUG:syncQuizSession-Success');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      debugPrint('DEBUG:syncQuizSession CATCH: $e');
      //Still throw so the UI can decide whether to retry or cache for later
      throw Exception('Failed to sync quiz session: $e');
    }
  }

  Future<List<LearnModule>> fetchModules() async {
    const String query = r'''
  query{
    modules{
      id
      name
      year
      parent{
        id
       }
      children{
        id
        name
        year
        parent{
          id
         }
       }
     }
   }
 ''';
    try {
      debugPrint('DEBUG:fetchModules(Quiz) -Sending request...');
      final response = await _client.post('/graphql', data: {'query': query});
      debugPrint('DEBUG:fetchModules(Quiz) -Response: ${response.statusCode}');

      final Map<String, dynamic> responseData =
          response.data as Map<String, dynamic>;
      if (responseData['errors'] != null) {
        debugPrint(
          'DEBUG:fetchModules(Quiz)GraphQL Error: ${responseData['errors'][0]['message']}',
        );
        return [];
      }

      final List? modulesData = responseData['data']?['modules'];
      if (modulesData == null) return [];

      return modulesData.map((m) => LearnModule.fromJson(m)).toList();
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      debugPrint('DEBUG:fetchModules(Quiz)CATCH: $e');
      return [];
    }
  }

  Future<List<int>> fetchYears() async {
    const String query = r'''
  query{
    years
   }
 ''';
    try {
      final response = await _client.post('/graphql', data: {'query': query});
      final List<int> years = List<int>.from(response.data['data']['years']);
      return years.isEmpty ? [1, 2, 3, 4, 5, 6, 7] : years;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      return [1, 2, 3, 4, 5, 6, 7];
    }
  }

  Future<List<String>> fetchSources({
    List<int>? years,
    List<String>? moduleIds,
    List<String>? lessonIds,
  }) async {
    const String query = r'''
  query GetSources($moduleIds: [ID], $lessonIds: [ID], $years: [Int]) {
    sources(moduleIds: $moduleIds, lessonIds: $lessonIds, years: $years)
   }
 ''';
    try {
      final response = await _client.post(
        '/graphql',
        data: {
          'query': query,
          'variables': {
            'moduleIds': moduleIds,
            'lessonIds': lessonIds,
            'years': years,
          },
        },
      );
      return List<String>.from(response.data['data']['sources']);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      return [];
    }
  }

  Future<List<LearnLesson>> fetchLessons(String moduleId) async {
    const String query = r'''
  query GetModuleLessons($id:ID!) {
    module(id: $id) {
      lessons{
        id
        title
       }
     }
   }
 ''';
    try {
      debugPrint('DEBUG:fetchLessons(Quiz) -ModuleId: $moduleId');
      final response = await _client.post(
        '/graphql',
        data: {
          'query': query,
          'variables': {'id': moduleId},
        },
      );
      debugPrint(
        'DEBUG:fetchLessons(Quiz) -Response status: ${response.statusCode}',
      );

      final Map<String, dynamic> responseData =
          response.data as Map<String, dynamic>;
      if (responseData['errors'] != null) {
        debugPrint(
          'DEBUG:fetchLessons(Quiz)GraphQL Error: ${responseData['errors'][0]['message']}',
        );
        return [];
      }

      final List? lessonsData = responseData['data']?['module']?['lessons'];
      if (lessonsData == null) return [];

      return lessonsData
          .map((l) => LearnLesson.fromJson({...l, 'moduleId': moduleId}))
          .toList();
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      debugPrint('DEBUG:fetchLessons(Quiz)CATCH: $e');
      return [];
    }
  }

  //Methods for Collections(now using Folders)
  // ...existing folder methods...

  Future<bool> toggleSaveQuestion(int questionId, {int? folderId}) async {
    const String mutation = r'''
  mutation ToggleSave($questionId:ID!, $folderId:ID) {
    toggleSaveQuestion(questionId: $questionId,folderId: $folderId)
   }
 ''';
    try {
      final response = await _client.post(
        '/graphql',
        data: {
          'query': mutation,
          'variables': {
            'questionId': questionId.toString(),
            'folderId': folderId?.toString(),
          },
        },
      );
      final Map<String, dynamic> responseData =
          response.data as Map<String, dynamic>;
      if (responseData['errors'] != null) {
        throw Exception(responseData['errors'][0]['message']);
      }
      return responseData['data']?['toggleSaveQuestion'] as bool? ?? false;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to toggle save: $e');
    }
  }

  Future<List<QuestionFolder>> fetchQuestionFolders() async {
    const String query = r'''
  query{
    myQuestionFolders{
      id
      name
      color
      user_id
     }
   }
 ''';
    try {
      final response = await _client.post('/graphql', data: {'query': query});
      final Map<String, dynamic> responseData =
          response.data as Map<String, dynamic>;
      if (responseData['errors'] != null) {
        throw Exception(responseData['errors'][0]['message']);
      }
      final List? foldersData = responseData['data']?['myQuestionFolders'];
      if (foldersData == null) return [];
      return foldersData.map((f) => QuestionFolder.fromJson(f)).toList();
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e, stack) {
      debugPrint('DEBUG:fetchQuestionFolders ERROR: $e');
      debugPrint('DEBUG:fetchQuestionFolders STACK: $stack');
      rethrow;
    }
  }

  Future<QuestionFolder> createQuestionFolder(
    String name, {
    String? color,
  }) async {
    const String mutation = r'''
  mutation CreateFolder($name:String!, $color:String) {
    createQuestionFolder(name: $name,color: $color) {
      id
      name
      color
      user_id
     }
   }
 ''';
    try {
      final response = await _client.post(
        '/graphql',
        data: {
          'query': mutation,
          'variables': {'name': name, 'color': color},
        },
      );
      final data = response.data['data']['createQuestionFolder'];
      return QuestionFolder.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to create folder: $e');
    }
  }

  Future<bool> deleteQuestionFolder(int id) async {
    const String mutation = r'''
  mutation DeleteFolder($id:ID!) {
    deleteQuestionFolder(id: $id)
   }
 ''';
    try {
      final response = await _client.post(
        '/graphql',
        data: {
          'query': mutation,
          'variables': {'id': id.toString()},
        },
      );
      return response.data['data']['deleteQuestionFolder'] as bool;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to delete folder: $e');
    }
  }

  Future<QuestionFolder> renameQuestionFolder(
    int id,
    String name, {
    String? color,
  }) async {
    const String mutation = r'''
  mutation RenameFolder($id:ID!, $name:String!, $color:String) {
    renameQuestionFolder(id: $id,name: $name,color: $color) {
      id
      name
      color
      user_id
     }
   }
 ''';
    try {
      final response = await _client.post(
        '/graphql',
        data: {
          'query': mutation,
          'variables': {'id': id.toString(), 'name': name, 'color': color},
        },
      );
      final data = response.data['data']['renameQuestionFolder'];
      return QuestionFolder.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to rename folder: $e');
    }
  }

  Future<QuestionComment> addComment(
    int questionId,
    String text, {
    String? parentId,
  }) async {
    const String mutation = r'''
  mutation AddComment($questionId:ID!, $text:String!, $parentId:ID) {
    addQuestionComment(question_id: $questionId,text: $text,parent_id: $parentId) {
      id
      parent_id
      text
      is_edited
      upvotes
      downvotes
      my_vote
      is_mine
      created_at
      user{
        name
       }
      replies{
        id
        parent_id
        text
        is_edited
        upvotes
        downvotes
        my_vote
        is_mine
        created_at
        user{
          name
         }
       }
     }
   }
 ''';
    try {
      final response = await _client.post(
        '/graphql',
        data: {
          'query': mutation,
          'variables': {
            'questionId': questionId.toString(),
            'text': text,
            'parentId': parentId,
          },
        },
      );
      final Map<String, dynamic> responseData =
          response.data as Map<String, dynamic>;
      if (responseData['errors'] != null) {
        throw Exception(responseData['errors'][0]['message']);
      }
      final data = responseData['data']['addQuestionComment'];
      return QuestionComment.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<QuestionComment> voteComment(String commentId, int vote) async {
    const String mutation = r'''
  mutation VoteComment($commentId:ID!, $vote:Int!) {
    voteComment(comment_id: $commentId,vote: $vote) {
      id
      parent_id
      text
      is_edited
      upvotes
      downvotes
      my_vote
      is_mine
      created_at
      user{
        name
       }
      replies{
        id
        parent_id
        text
        is_edited
        upvotes
        downvotes
        my_vote
        is_mine
        created_at
        user{
          name
         }
       }
     }
   }
 ''';
    try {
      final response = await _client.post(
        '/graphql',
        data: {
          'query': mutation,
          'variables': {'commentId': commentId, 'vote': vote},
        },
      );
      final data = response.data['data']['voteComment'];
      return QuestionComment.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to vote: $e');
    }
  }

  Future<QuestionComment> editComment(String commentId, String text) async {
    const String mutation = r'''
  mutation EditComment($id:ID!, $text:String!) {
    editQuestionComment(id: $id,text: $text) {
      id
      parent_id
      text
      is_edited
      upvotes
      downvotes
      my_vote
      is_mine
      created_at
      user{
        name
       }
      replies{
        id
        parent_id
        text
        is_edited
        upvotes
        downvotes
        my_vote
        is_mine
        created_at
        user{
          name
         }
       }
     }
   }
 ''';
    try {
      final response = await _client.post(
        '/graphql',
        data: {
          'query': mutation,
          'variables': {'id': commentId, 'text': text},
        },
      );
      final data = response.data['data']['editQuestionComment'];
      return QuestionComment.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to edit comment: $e');
    }
  }

  Future<void> deleteComment(String commentId) async {
    const String mutation = r'''
  mutation DeleteComment($id:ID!) {
    deleteQuestionComment(id: $id)
   }
 ''';
    try {
      await _client.post(
        '/graphql',
        data: {
          'query': mutation,
          'variables': {'id': commentId},
        },
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  Future<void> reportQuestion(
    int questionId,
    String reason,
    String? description,
  ) async {
    const String mutation = r'''
  mutation ReportQuestion($questionId:ID!, $reason:String!, $description:String) {
    reportQuestion(question_id: $questionId,reason: $reason,description: $description)
   }
 ''';
    try {
      await _client.post(
        '/graphql',
        data: {
          'query': mutation,
          'variables': {
            'questionId': questionId.toString(),
            'reason': reason,
            'description': description,
          },
        },
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to report question: $e');
    }
  }

  Future<void> reportComment(String commentId, String reason) async {
    const String mutation = r'''
  mutation ReportComment($commentId:ID!, $reason:String!) {
    reportComment(comment_id: $commentId,reason: $reason)
   }
 ''';
    try {
      await _client.post(
        '/graphql',
        data: {
          'query': mutation,
          'variables': {'commentId': commentId, 'reason': reason},
        },
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to report comment: $e');
    }
  }

  Future<void> syncHighlights(int questionId, String highlightsJson) async {
    const String mutation = r'''
  mutation SyncHighlights($questionId:ID!, $highlights:JSON!) {
    syncQuestionHighlights(question_id: $questionId,highlights: $highlights)
   }
 ''';
    try {
      await _client.post(
        '/graphql',
        data: {
          'query': mutation,
          'variables': {
            'questionId': questionId.toString(),
            'highlights': highlightsJson,
          },
        },
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to sync highlights: $e');
    }
  }

  Future<void> syncClinicalCaseHighlights(
    int clinicalCaseId,
    String highlightsJson,
  ) async {
    const String mutation = r'''
  mutation SyncClinicalCaseHighlights($id:ID!, $highlights:JSON!) {
    syncClinicalCaseHighlights(clinical_case_id: $id,highlights: $highlights)
   }
 ''';
    try {
      await _client.post(
        '/graphql',
        data: {
          'query': mutation,
          'variables': {
            'id': clinicalCaseId.toString(),
            'highlights': highlightsJson,
          },
        },
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to sync clinical case highlights: $e');
    }
  }

  Future<void> syncClinicalCaseNote(int clinicalCaseId, String text) async {
    const String mutation = r'''
  mutation AddClinicalCaseNote($id:ID!, $text:String) {
    addClinicalCaseNote(clinical_case_id: $id,text: $text) {
      id
     }
   }
 ''';
    try {
      await _client.post(
        '/graphql',
        data: {
          'query': mutation,
          'variables': {'id': clinicalCaseId.toString(), 'text': text},
        },
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to sync clinical case note: $e');
    }
  }

  Future<void> deleteClinicalCaseNote(int noteId) async {
    const String mutation = r'''
  mutation DeleteClinicalCaseNote($id:ID!) {
    deleteClinicalCaseNote(id: $id)
   }
 ''';
    try {
      await _client.post(
        '/graphql',
        data: {
          'query': mutation,
          'variables': {'id': noteId.toString()},
        },
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to delete clinical case note: $e');
    }
  }

  Future<void> syncSrsReview({
    required int questionId,
    required int interval,
    required double easeFactor,
    required int repetitionCount,
    required DateTime nextReview,
    DateTime? lastReview,
  }) async {
    const String mutation = r'''
  mutation SyncReview(
     $questionId:ID!
     $interval:Int!
     $easeFactor:Float!
     $repetitionCount:Int!
     $nextReview:DateTime!
     $lastReview:DateTime
   ) {
    syncReview(
      question_id: $questionId
      interval: $interval
      ease_factor: $easeFactor
      repetition_count: $repetitionCount
      next_review: $nextReview
      last_review: $lastReview
     ) {
      id
     }
   }
 ''';

    try {
      await _client.post(
        '/graphql',
        data: {
          'query': mutation,
          'variables': {
            'questionId': questionId.toString(),
            'interval': interval,
            'easeFactor': easeFactor,
            'repetitionCount': repetitionCount,
            'nextReview': nextReview.toIso8601String(),
            'lastReview': lastReview?.toIso8601String(),
          },
        },
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      debugPrint('DEBUG:syncSrsReview CATCH: $e');
      throw Exception('Failed to sync SRS review: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllReviews() async {
    const String query = r'''
  query MyReviews{
    myReviews{
      id
      questionId
      interval
      easeFactor
      repetitionCount
      nextReview
      lastReview
     }
   }
 ''';

    try {
      final response = await _client.post('/graphql', data: {'query': query});

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) {
        throw Exception('Empty response from server');
      }
      if (responseData['errors'] != null) {
        throw Exception(responseData['errors'][0]['message']);
      }

      final reviewsData = responseData['data']?['myReviews'] as List?;
      if (reviewsData == null) return [];

      return reviewsData.map((e) => e as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      debugPrint('DEBUG:fetchAllReviews error: $e');
      throw Exception('Failed to fetch all reviews: $e');
    }
  }

  Future<List<SavedQuestion>> fetchSavedQuestions() async {
    const String query = r'''
  query{
    mySavedQuestions{
      id
      user_id
      question_id
      folder_id
      question{
        id
        text
        propositions{
          id
          label
          text
          is_correct
         }
        lesson{
          title
          module{
            name
            year
           }
         }
        saved_by_user
        clinicalCase{
          id
          text
          title
          my_highlights
          my_note{
            id
            text
            thumbnail_url
           }
         }
       }
      created_at
     }
   }
 ''';
    try {
      final response = await _client.post('/graphql', data: {'query': query});
      final Map<String, dynamic> responseData =
          response.data as Map<String, dynamic>;
      if (responseData['errors'] != null) {
        throw Exception(responseData['errors'][0]['message']);
      }
      final List? savedData = responseData['data']?['mySavedQuestions'];
      debugPrint('DEBUG:fetchSavedQuestions-Received${savedData?.length}items');
      if (savedData == null) return [];
      return savedData.map((s) => SavedQuestion.fromJson(s)).toList();
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e, stack) {
      debugPrint('DEBUG:fetchSavedQuestions ERROR: $e');
      debugPrint('DEBUG:fetchSavedQuestions STACK: $stack');
      rethrow;
    }
  }

  Future<String> getDebugInfo() async {
    const String query = r'''
  query{
    debugSavedQuestions
   }
 ''';
    try {
      final response = await _client.post('/graphql', data: {'query': query});
      if (response.data['errors'] != null) {
        return 'Error: ${response.data['errors'][0]['message']}';
      }
      return response.data['data']['debugSavedQuestions'].toString();
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      return 'Debug Fetch Error: $e';
    }
  }

  Future<void> saveSavedSession({
    required QuizSession session,
    required int timeSeconds,
    required bool showFeedback,
    required Set<int> selectedOptionIds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionMap = session.toJson();
    final wrapper = {
      'session': sessionMap,
      'timeSeconds': timeSeconds,
      'showFeedback': showFeedback,
      'selectedOptionIds': selectedOptionIds.toList(),
    };
    await prefs.setString('saved_quiz_session', json.encode(wrapper));
  }

  Future<Map<String, dynamic>?> getSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('saved_quiz_session');
    if (str == null) return null;
    try {
      return json.decode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_quiz_session');
  }
}

class SavedQuizSession {
  final QuizSession session;
  final int timeSeconds;
  final bool showFeedback;
  final Set<int> selectedOptionIds;

  SavedQuizSession({
    required this.session,
    required this.timeSeconds,
    required this.showFeedback,
    required this.selectedOptionIds,
  });
}

//PROVIDERS
final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return QuizRepository(dioClient);
});

final savedQuizSessionProvider = FutureProvider<SavedQuizSession?>((ref) async {
  final repository = ref.watch(quizRepositoryProvider);
  final savedData = await repository.getSavedSession();
  if (savedData == null) return null;
  final sessionJson = savedData['session'] as Map<String, dynamic>;
  final session = QuizSession.fromJson(sessionJson);
  final timeSeconds = savedData['timeSeconds'] as int? ?? 0;
  final showFeedback = savedData['showFeedback'] as bool? ?? false;
  final selectedOptionIds = (savedData['selectedOptionIds'] as List?)
      ?.map((e) => e as int)
      .toSet() ?? <int>{};
  return SavedQuizSession(
    session: session,
    timeSeconds: timeSeconds,
    showFeedback: showFeedback,
    selectedOptionIds: selectedOptionIds,
  );
});

final hasSavedQuizSessionProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(quizRepositoryProvider);
  final savedData = await repository.getSavedSession();
  return savedData != null;
});

final quizSessionFetcherProvider =
    FutureProvider.family<QuizSession, QuizFilters>((ref, filters) async {
      final repository = ref.watch(quizRepositoryProvider);
      return repository.startPracticeSession(filters);
    });

final quizYearsProvider = FutureProvider<List<int>>((ref) async {
  final repository = ref.watch(quizRepositoryProvider);
  final years = await repository.fetchYears();
  return years.toSet().toList()..sort();
});

final quizModulesProvider = FutureProvider<List<LearnModule>>((ref) async {
  final repository = ref.watch(quizRepositoryProvider);
  final allTopModules = await repository.fetchModules();

  //Flatten the list to include all children
  final Map<String, LearnModule> flatModules = {};
  for (final m in allTopModules) {
    flatModules[m.id] = m;
    if (m.children != null) {
      for (final child in m.children!) {
        flatModules[child.id] = child;
      }
    }
  }

  return flatModules.values.toList();
});

final myQuestionFoldersProvider = FutureProvider<List<QuestionFolder>>((
  ref,
) async {
  final repository = ref.watch(quizRepositoryProvider);
  return repository.fetchQuestionFolders();
});

class QuizSourcesParams extends Equatable {
  final List<int>? years;
  final List<String>? moduleIds;
  final List<String>? lessonIds;

  const QuizSourcesParams({this.years, this.moduleIds, this.lessonIds});

  @override
  List<Object?> get props => [years, moduleIds, lessonIds];
}

final quizSourcesProvider =
    FutureProvider.family<List<String>, QuizSourcesParams>((ref, params) async {
  final repository = ref.watch(quizRepositoryProvider);
  return repository.fetchSources(
    years: params.years,
    moduleIds: params.moduleIds,
    lessonIds: params.lessonIds,
  );
});

final quizLessonsProvider = FutureProvider.family<List<LearnLesson>, String>((
  ref,
  moduleId,
) async {
  final repository = ref.watch(quizRepositoryProvider);
  return repository.fetchLessons(moduleId);
});

final modulesLessonsProvider =
    FutureProvider.family<List<LearnLesson>, List<String>>((
      ref,
      moduleIds,
    ) async {
      final repository = ref.watch(quizRepositoryProvider);
      final lessonsFutures = moduleIds.map((id) => repository.fetchLessons(id));
      final lessonsLists = await Future.wait(lessonsFutures);
      return lessonsLists.expand((list) => list).toList();
    });

final mySavedQuestionsProvider = FutureProvider<List<SavedQuestion>>((
  ref,
) async {
  final repository = ref.watch(quizRepositoryProvider);
  final allSaved = await repository.fetchSavedQuestions();
  final user = ref.watch(authControllerProvider).value;
  if (user != null && user.year >= 1 && user.year <= 6) {
    return allSaved.where((s) => s.question?.year == user.year).toList();
  }
  return allSaved;
});
