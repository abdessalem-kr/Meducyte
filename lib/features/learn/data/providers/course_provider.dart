import 'package:meducyte_app/core/network/dio_client.dart';
import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/shared/providers/network_provider.dart';
import 'package:meducyte_app/core/database/app_database.dart';
import 'package:meducyte_app/shared/providers/database_provider.dart';
import 'dart:convert';

// REPOSITORY
class CourseRepository {
  final DioClient _client;
  final AppDatabase _db;

  CourseRepository(this._client, this._db);

  Future<List<LearnModule>> fetchModules({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      try {
        final cachedJson = await _db.getModulesCache();
        if (cachedJson != null) {
          debugPrint('DEBUG: fetchModules - Loading from cache...');
          final decoded = jsonDecode(cachedJson);
          if (decoded is List) {
            return decoded
                .map(
                  (item) => LearnModule.fromJson(item as Map<String, dynamic>),
                )
                .toList();
          }
        }
      } catch (e) {
        debugPrint('DEBUG: fetchModules Cache Error: $e');
      }
    }

    const String query = r'''
      query GetModules {
        modules {
          id
          name
          description
          year
          parent {
            id
          }
          children {
            id
            name
            year
            lessons {
              id
              title
              is_studied
            }
          }
          lessons {
            id
            title
            is_studied
          }
        }
      }
    ''';
    try {
      debugPrint('DEBUG: fetchModules - Sending request...');
      final response = await _client.post('/graphql', data: {'query': query});
      debugPrint(
        'DEBUG: fetchModules - Response status: ${response.statusCode}',
      );
      debugPrint('DEBUG: fetchModules - Response body: ${response.data}');

      final mapData = response.data as Map<String, dynamic>?;
      if (mapData == null) throw Exception('Response data is null');

      if (mapData['errors'] != null) {
        final errorMsg = mapData['errors'][0]['message'];
        debugPrint('DEBUG: fetchModules GraphQL Error: $errorMsg');
        throw Exception('GraphQL: $errorMsg');
      }

      final data = mapData['data']?['modules'];
      if (data == null) {
        throw Exception('Field "modules" missing in response.data');
      }

      final List modulesList = data as List;
      final modules = modulesList
          .map((item) => LearnModule.fromJson(item as Map<String, dynamic>))
          .toList();

      // Update cache
      try {
        final modulesJson = jsonEncode(modules.map((m) => m.toJson()).toList());
        await _db.saveModulesCache(modulesJson);
        debugPrint('DEBUG: fetchModules - Cache updated.');
      } catch (e) {
        debugPrint('DEBUG: fetchModules - Failed to update cache: $e');
      }

      return modules;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      debugPrint('DEBUG: fetchModules CATCH: $e');
      throw Exception('Failed to fetch modules: $e');
    }
  }

  Future<List<LearnLesson>> fetchLessonsByModule(String moduleId, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedJson = prefs.getString('meducyte_lessons_module_$moduleId');
        if (cachedJson != null) {
          // debugPrint('DEBUG: fetchLessonsByModule - Loading from cache for $moduleId...');
          final decoded = jsonDecode(cachedJson);
          if (decoded is List) {
            return decoded
                .map((item) => LearnLesson.fromJson(item as Map<String, dynamic>))
                .toList();
          }
        }
      } catch (e) {
        debugPrint('DEBUG: fetchLessonsByModule Cache Error: $e');
      }
    }

    // Fetch lessons through the module relationship — bypasses the broken
    // top-level "lessons" query entirely. No backend changes needed.
    const String query = r'''
      query GetModuleLessons($id: ID!) {
        module(id: $id) {
          lessons {
            id
            title
            order
            is_studied
          }
        }
      }
    ''';
    try {
      debugPrint(
        'DEBUG: fetchLessonsByModule - Sending request for moduleId: $moduleId',
      );
      final response = await _client.post(
        '/graphql',
        data: {
          'query': query,
          'variables': {'id': moduleId},
        },
      );
      debugPrint(
        'DEBUG: fetchLessonsByModule - Response status: ${response.statusCode}',
      );
      debugPrint(
        'DEBUG: fetchLessonsByModule - Response body: ${response.data}',
      );

      final mapData = response.data as Map<String, dynamic>?;
      if (mapData == null) throw Exception('Response data is null');

      if (mapData['errors'] != null) {
        final errorMsg = mapData['errors'][0]['message'];
        debugPrint('DEBUG: fetchLessonsByModule GraphQL Error: $errorMsg');
        throw Exception('GraphQL: $errorMsg');
      }

      final moduleData = mapData['data']?['module'];
      if (moduleData == null) {
        debugPrint('DEBUG: fetchLessonsByModule - Module not found or is null for $moduleId');
        return <LearnLesson>[];
      }

      final data = moduleData['lessons'];
      if (data == null) {
        throw Exception('Field "lessons" missing in response.data');
      }

      final List lessonsList = data as List;
      final lessons = lessonsList
          .map((item) => LearnLesson.fromJson(item as Map<String, dynamic>))
          .toList();

      // Update cache
      try {
        final prefs = await SharedPreferences.getInstance();
        final lessonsJson = jsonEncode(lessons.map((l) => l.toJson()).toList());
        await prefs.setString('meducyte_lessons_module_$moduleId', lessonsJson);
        debugPrint('DEBUG: fetchLessonsByModule - Cache updated for $moduleId.');
      } catch (e) {
        debugPrint('DEBUG: fetchLessonsByModule - Failed to update cache: $e');
      }

      return lessons;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      debugPrint('DEBUG: fetchLessonsByModule CATCH: $e');
      throw Exception('Failed to fetch lessons: $e');
    }
  }

  Future<void> clearLessonsByModuleCache(String moduleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('meducyte_lessons_module_$moduleId');
      debugPrint('DEBUG: clearLessonsByModuleCache - Cleared cache for $moduleId.');
    } catch (e) {
      debugPrint('DEBUG: clearLessonsByModuleCache Error: $e');
    }
  }

  Future<void> clearLessonDetailsCache(String lessonId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('meducyte_lesson_details_$lessonId');
      debugPrint('DEBUG: clearLessonDetailsCache - Cleared cache for $lessonId.');
    } catch (e) {
      debugPrint('DEBUG: clearLessonDetailsCache Error: $e');
    }
  }

  Future<void> clearAllLessonsByModuleCaches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('meducyte_lessons_module_')) {
          await prefs.remove(key);
        }
      }
      debugPrint('DEBUG: clearAllLessonsByModuleCaches - Cleared all module lessons caches.');
    } catch (e) {
      debugPrint('DEBUG: clearAllLessonsByModuleCaches Error: $e');
    }
  }

  Future<void> _clearCachesForLesson(String lessonId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final detailsKey = 'meducyte_lesson_details_$lessonId';
      final cachedJson = prefs.getString(detailsKey);
      if (cachedJson != null) {
        final decoded = jsonDecode(cachedJson);
        final moduleId = decoded['moduleId']?.toString();
        if (moduleId != null && moduleId.isNotEmpty) {
          await prefs.remove('meducyte_lessons_module_$moduleId');
          debugPrint('DEBUG: _clearCachesForLesson - Cleared module cache for $moduleId.');
        } else {
          await clearAllLessonsByModuleCaches();
        }
      } else {
        await clearAllLessonsByModuleCaches();
      }
      await prefs.remove(detailsKey);
      await _db.clearModulesCache();
      debugPrint('DEBUG: _clearCachesForLesson - Cleared lesson details and modules caches.');
    } catch (e) {
      debugPrint('DEBUG: _clearCachesForLesson Error: $e');
    }
  }

  Future<bool> toggleLessonStudied(String lessonId) async {
    // Clear caches first to prevent stale state loading
    await _clearCachesForLesson(lessonId);

    const String query = r'''
      mutation ToggleLessonStudied($lessonId: ID!) {
        toggleLessonStudied(lesson_id: $lessonId)
      }
    ''';
    try {
      final response = await _client.post(
        '/graphql',
        data: {
          'query': query,
          'variables': {'lessonId': lessonId},
        },
      );
      final mapData = response.data as Map<String, dynamic>?;
      if (mapData?['errors'] != null) {
        throw Exception(mapData!['errors'][0]['message']);
      }
      return response.data['data']['toggleLessonStudied'] as bool;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to toggle lesson studied status: $e');
    }
  }

  Future<LearnLesson> fetchLessonDetails(String lessonId, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedJson = prefs.getString('meducyte_lesson_details_$lessonId');
        if (cachedJson != null) {
          debugPrint('DEBUG: fetchLessonDetails - Loading from cache for $lessonId...');
          final decoded = jsonDecode(cachedJson);
          return LearnLesson.fromJson(decoded as Map<String, dynamic>);
        }
      } catch (e) {
        debugPrint('DEBUG: fetchLessonDetails Cache Error: $e');
      }
    }

    const String query = r'''
      query GetLessonDetails($id: ID!) {
        lesson(id: $id) {
          id
          title
          order
          paragraphs {
            id
            title
            content
            order
            has_quiz
            my_note {
              id
              text
              thumbnail_url
            }
            my_highlights
          }
        }
      }
    ''';
    try {
      final response = await _client.post(
        '/graphql',
        data: {
          'query': query,
          'variables': {'id': lessonId},
        },
      );
      final mapData = response.data as Map<String, dynamic>?;
      if (mapData == null) throw Exception('Response data is null');

      if (mapData['errors'] != null) {
        final errorMsg = mapData['errors'][0]['message'];
        throw Exception('GraphQL: $errorMsg');
      }

      final data = mapData['data']?['lesson'];
      if (data == null) throw Exception('Lesson not found');
      final lesson = LearnLesson.fromJson(data);

      // Update cache
      try {
        final prefs = await SharedPreferences.getInstance();
        final lessonJson = jsonEncode(lesson.toJson());
        await prefs.setString('meducyte_lesson_details_$lessonId', lessonJson);
        debugPrint('DEBUG: fetchLessonDetails - Cache updated for $lessonId.');
      } catch (e) {
        debugPrint('DEBUG: fetchLessonDetails - Failed to update cache: $e');
      }

      return lesson;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to fetch lesson details: $e');
    }
  }

  Future<void> addLessonComment(
    String lessonId,
    String text, {
    String? parentId,
  }) async {
    const String query = r'''
      mutation AddLessonComment($lessonId: ID!, $text: String!, $parentId: ID) {
        addLessonComment(lesson_id: $lessonId, text: $text, parent_id: $parentId) {
          id
        }
      }
    ''';
    try {
      await _client.post(
        '/graphql',
        data: {
          'query': query,
          'variables': {
            'lessonId': lessonId,
            'text': text,
            'parentId': parentId,
          },
        },
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to add lesson comment: $e');
    }
  }

  Future<void> addCourseComment(
    String moduleId,
    String text, {
    String? parentId,
  }) async {
    const String query = r'''
      mutation AddCourseComment($moduleId: ID!, $text: String!, $parentId: ID) {
        addModuleComment(module_id: $moduleId, text: $text, parent_id: $parentId) {
          id
        }
      }
    ''';
    try {
      await _client.post(
        '/graphql',
        data: {
          'query': query,
          'variables': {
            'moduleId': moduleId,
            'text': text,
            'parentId': parentId,
          },
        },
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to add course comment: $e');
    }
  }

  Future<void> reportLesson(
    String lessonId,
    String reason,
    String? description,
  ) async {
    const String query = r'''
      mutation ReportLesson($lessonId: ID!, $reason: String!, $description: String) {
        reportLesson(lesson_id: $lessonId, reason: $reason, description: $description)
      }
    ''';
    try {
      await _client.post(
        '/graphql',
        data: {
          'query': query,
          'variables': {
            'lessonId': lessonId,
            'reason': reason,
            'description': description,
          },
        },
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to report lesson: $e');
    }
  }

  Future<void> reportCourse(
    String moduleId,
    String reason,
    String? description,
  ) async {
    const String query = r'''
      mutation ReportModule($moduleId: ID!, $reason: String!, $description: String) {
        reportModule(module_id: $moduleId, reason: $reason, description: $description)
      }
    ''';
    try {
      await _client.post(
        '/graphql',
        data: {
          'query': query,
          'variables': {
            'moduleId': moduleId,
            'reason': reason,
            'description': description,
          },
        },
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to report course: $e');
    }
  }

  Future<void> editLessonComment(String commentId, String text) async {
    const String query = r'''
      mutation EditLessonComment($id: ID!, $text: String!) {
        editLessonComment(id: $id, text: $text) {
          id
        }
      }
    ''';
    try {
      await _client.post(
        '/graphql',
        data: {
          'query': query,
          'variables': {'id': commentId, 'text': text},
        },
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to edit lesson comment: $e');
    }
  }

  Future<void> deleteLessonComment(String commentId) async {
    const String query = r'''
      mutation DeleteLessonComment($id: ID!) {
        deleteLessonComment(id: $id)
      }
    ''';
    try {
      await _client.post(
        '/graphql',
        data: {
          'query': query,
          'variables': {'id': commentId},
        },
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to delete lesson comment: $e');
    }
  }

  Future<void> editCourseComment(String commentId, String text) async {
    const String query = r'''
      mutation EditCourseComment($id: ID!, $text: String!) {
        editModuleComment(id: $id, text: $text) {
          id
        }
      }
    ''';
    try {
      await _client.post(
        '/graphql',
        data: {
          'query': query,
          'variables': {'id': commentId, 'text': text},
        },
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to edit course comment: $e');
    }
  }

  Future<void> deleteCourseComment(String commentId) async {
    const String query = r'''
      mutation DeleteCourseComment($id: ID!) {
        deleteModuleComment(id: $id)
      }
    ''';
    try {
      await _client.post(
        '/graphql',
        data: {
          'query': query,
          'variables': {'id': commentId},
        },
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to delete course comment: $e');
    }
  }

  Future<void> voteComment(String commentId, int vote) async {
    const String query = r'''
      mutation VoteComment($commentId: ID!, $vote: Int!) {
        voteComment(comment_id: $commentId, vote: $vote) {
          id
          upvotes
          downvotes
          my_vote
        }
      }
    ''';
    try {
      await _client.post(
        '/graphql',
        data: {
          'query': query,
          'variables': {'commentId': commentId, 'vote': vote},
        },
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to vote on comment: $e');
    }
  }

  Future<void> addParagraphNote(String paragraphId, String text) async {
    const String query = r'''
      mutation AddParagraphNote($paragraphId: ID!, $text: String) {
        addParagraphNote(paragraph_id: $paragraphId, text: $text) {
          id
          text
        }
      }
    ''';
    try {
      await _client.post(
        '/graphql',
        data: {
          'query': query,
          'variables': {'paragraphId': paragraphId, 'text': text},
        },
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to add paragraph note: $e');
    }
  }

  Future<void> deleteParagraphNote(String noteId) async {
    const String query = r'''
      mutation DeleteParagraphNote($id: ID!) {
        deleteParagraphNote(id: $id)
      }
    ''';
    try {
      await _client.post(
        '/graphql',
        data: {
          'query': query,
          'variables': {'id': noteId},
        },
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to delete paragraph note: $e');
    }
  }

  Future<void> syncParagraphHighlights(
    String paragraphId,
    List<Map<String, dynamic>> highlights,
  ) async {
    const String query = r'''
      mutation SyncParagraphHighlights($paragraphId: ID!, $highlights: JSON!) {
        syncParagraphHighlights(paragraph_id: $paragraphId, highlights: $highlights)
      }
    ''';
    try {
      await _client.post(
        '/graphql',
        data: {
          'query': query,
          'variables': {'paragraphId': paragraphId, 'highlights': highlights},
        },
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to sync paragraph highlights: $e');
    }
  }

  // Support for classification filtering (mapped to modules)
  Future<List<String>> fetchClassifications(String type) async {
    if (type == 'specialties') {
      final modules = await fetchModules();
      return modules.map((m) => m.name).toList();
    }
    return [];
  }
}

// PROVIDERS
final learnRepositoryProvider = Provider((ref) {
  final client = ref.watch(dioClientProvider);
  final db = ref.watch(appDatabaseProvider);
  return CourseRepository(client, db);
});

final learnModulesProvider = FutureProvider<List<LearnModule>>((ref) async {
  final allModules = await ref.watch(learnRepositoryProvider).fetchModules();
  final userAsync = ref.watch(authControllerProvider);
  final user = userAsync.value;

  if (user == null) return allModules;

  final isSubscriber = user.isSubscriber;

  // 7th Year (Residency) Subscribed users see EVERYTHING
  if (user.year >= 7 && isSubscriber) {
    return allModules;
  }

  // All other users (Students or Free Residents) see ONLY their current year's TOP-LEVEL modules.
  // We filter for parentId == null to show UEIs or stand-alone modules.
  return allModules
      .where((m) => m.year == user.year && m.parentId == null)
      .toList();
});

final moduleLessonsProvider = FutureProvider.family<List<LearnLesson>, String>((
  ref,
  moduleId,
) async {
  return ref.watch(learnRepositoryProvider).fetchLessonsByModule(moduleId);
});

final lessonDetailsProvider = FutureProvider.family<LearnLesson, String>((
  ref,
  lessonId,
) async {
  return ref.watch(learnRepositoryProvider).fetchLessonDetails(lessonId);
});

final allLessonsProvider = FutureProvider<List<LearnLesson>>((ref) async {
  final repo = ref.watch(learnRepositoryProvider);
  final modules = await ref.watch(learnModulesProvider.future);

  final lessonsFutures = modules.map((m) => repo.fetchLessonsByModule(m.id));
  final lessonsLists = await Future.wait(lessonsFutures);

  return lessonsLists.expand((list) => list).toList();
});
