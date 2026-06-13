import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:meducyte_app/core/database/app_database.dart';
import 'package:meducyte_app/core/network/dio_client.dart';
import 'package:meducyte_app/features/learn/data/providers/course_provider.dart';
import 'package:meducyte_app/features/learn/domain/models/course.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// A mock secure storage for constructing DioClient
class FakeFlutterSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<String?> read({required String key, IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async {
    return _data[key];
  }

  @override
  Future<void> write({required String key, required String? value, IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<void> delete({required String key, IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async {
    _data.remove(key);
  }
}

// A fake AppDatabase to mock module cache storage
class FakeAppDatabase extends Fake implements AppDatabase {
  String? cachedModulesJson;

  @override
  Future<void> saveModulesCache(String json) async {
    cachedModulesJson = json;
  }

  @override
  Future<String?> getModulesCache() async {
    return cachedModulesJson;
  }

  @override
  Future<void> clearModulesCache() async {
    cachedModulesJson = null;
  }

  @override
  Future<void> close() async {}
}

// A fake DioClient that lets us intercept and count GraphQL POST requests
class FakeDioClient extends Fake implements DioClient {
  int postCallCount = 0;
  Map<String, dynamic>? nextResponse;

  @override
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    postCallCount++;
    return Response(
      requestOptions: RequestOptions(path: path),
      data: nextResponse ?? {'data': {}},
      statusCode: 200,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAppDatabase db;
  late FakeDioClient fakeDio;
  late CourseRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = FakeAppDatabase();
    fakeDio = FakeDioClient();
    repository = CourseRepository(fakeDio, db);
  });

  group('CourseRepository Caching Tests', () {
    test('fetchLessonsByModule checks cache first and caches network response', () async {
      final mockLessonsResponse = {
        'data': {
          'module': {
            'lessons': [
              {
                'id': 'lesson_1',
                'title': 'Introduction to Cardiology',
                'order': 1,
                'is_studied': false,
              }
            ]
          }
        }
      };

      fakeDio.nextResponse = mockLessonsResponse;

      // 1. First call (Cache empty) -> should hit the network
      final lessonsFirst = await repository.fetchLessonsByModule('module_a');
      expect(lessonsFirst.length, 1);
      expect(lessonsFirst[0].id, 'lesson_1');
      expect(fakeDio.postCallCount, 1);

      // 2. Second call -> should hit cache and NOT hit network again
      final lessonsSecond = await repository.fetchLessonsByModule('module_a');
      expect(lessonsSecond.length, 1);
      expect(lessonsSecond[0].id, 'lesson_1');
      expect(fakeDio.postCallCount, 1); // call count remains 1!

      // 3. Third call with forceRefresh = true -> should bypass cache and hit network
      fakeDio.nextResponse = mockLessonsResponse;
      final lessonsThird = await repository.fetchLessonsByModule('module_a', forceRefresh: true);
      expect(lessonsThird.length, 1);
      expect(fakeDio.postCallCount, 2); // call count increased to 2!
    });

    test('fetchLessonDetails checks cache first and caches network response', () async {
      final mockDetailsResponse = {
        'data': {
          'lesson': {
            'id': 'lesson_1',
            'title': 'Introduction to Cardiology',
            'order': 1,
            'paragraphs': [
              {
                'id': 'p_1',
                'title': 'Anatomy of the Heart',
                'lessonId': 'lesson_1',
                'content': 'The heart is a muscular organ...',
                'order': 1,
                'has_quiz': false,
                'my_note': null,
                'my_highlights': [],
              }
            ]
          }
        }
      };

      fakeDio.nextResponse = mockDetailsResponse;

      // 1. First call -> should hit network
      final lessonFirst = await repository.fetchLessonDetails('lesson_1');
      expect(lessonFirst.id, 'lesson_1');
      expect(lessonFirst.paragraphs?.length, 1);
      expect(fakeDio.postCallCount, 1);

      // 2. Second call -> should load from cache
      final lessonSecond = await repository.fetchLessonDetails('lesson_1');
      expect(lessonSecond.id, 'lesson_1');
      expect(lessonSecond.paragraphs?.length, 1);
      expect(fakeDio.postCallCount, 1); // remains 1!

      // 3. Force refresh -> should hit network again
      fakeDio.nextResponse = mockDetailsResponse;
      final lessonThird = await repository.fetchLessonDetails('lesson_1', forceRefresh: true);
      expect(lessonThird.id, 'lesson_1');
      expect(fakeDio.postCallCount, 2); // increased to 2!
    });

    test('toggleLessonStudied invalidates and clears correct caches', () async {
      // Setup: cache a lesson details and lessons list
      final prefs = await SharedPreferences.getInstance();

      final cachedLesson = LearnLesson(
        id: 'lesson_1',
        moduleId: 'module_a',
        title: 'Cached Lesson',
        order: 1,
      );

      // Cache details
      await prefs.setString(
        'meducyte_lesson_details_lesson_1',
        jsonEncode(cachedLesson.toJson()),
      );

      // Cache module lessons
      await prefs.setString(
        'meducyte_lessons_module_module_a',
        jsonEncode([cachedLesson.toJson()]),
      );

      // Cache top level modules in DB
      await db.saveModulesCache(jsonEncode([]));

      // Verify they are initially cached
      expect(prefs.containsKey('meducyte_lesson_details_lesson_1'), true);
      expect(prefs.containsKey('meducyte_lessons_module_module_a'), true);
      expect(await db.getModulesCache(), isNotNull);

      // Mock toggle mutation response
      fakeDio.nextResponse = {
        'data': {
          'toggleLessonStudied': true,
        }
      };

      // Call toggleLessonStudied
      final result = await repository.toggleLessonStudied('lesson_1');
      expect(result, true);

      // Verify caches are cleared / invalidated
      expect(prefs.containsKey('meducyte_lesson_details_lesson_1'), false);
      expect(prefs.containsKey('meducyte_lessons_module_module_a'), false);
      expect(await db.getModulesCache(), isNull);
    });
  });
}
