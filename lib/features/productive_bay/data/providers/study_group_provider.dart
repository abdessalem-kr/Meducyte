import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meducyte_app/shared/providers/network_provider.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/productive_bay_models.dart';
import 'package:meducyte_app/features/productive_bay/domain/repositories/study_group_repository.dart';
import 'package:meducyte_app/features/productive_bay/data/repositories/api_study_group_repository.dart';

final studyGroupRepositoryProvider = Provider<StudyGroupRepository>((ref) {
  final client = ref.watch(dioClientProvider);
  return ApiStudyGroupRepository(client);
});

final availableStudyGroupsProvider = FutureProvider<List<StudyGroup>>((ref) {
  return ref.watch(studyGroupRepositoryProvider).getAvailableGroups();
});

final myStudyGroupsProvider = FutureProvider<List<StudyGroup>>((ref) {
  return ref.watch(studyGroupRepositoryProvider).getMyGroups();
});

final studyGroupMessagesProvider =
    StreamProvider.family<List<StudyGroupMessage>, String>((
      ref,
      groupId,
    ) async* {
      final repo = ref.watch(studyGroupRepositoryProvider);
      //Initial fetch
      try {
        yield await repo.getMessages(groupId);
      } catch (e) {
        rethrow;
      }

      //Polling every 5 seconds
      while (true) {
        await Future.delayed(const Duration(seconds: 5));
        try {
          final messages = await repo.getMessages(groupId);
          yield messages;
        } catch (e) {
          rethrow;
        }
      }
    });

final activeStudyGroupQuizProvider =
    StreamProvider.family<StudyGroupQuizSession?, String>((
      ref,
      groupId,
    ) async* {
      final repo = ref.watch(studyGroupRepositoryProvider);
      //Initial fetch
      try {
        yield await repo.getActiveQuizSession(groupId);
      } catch (e) {
        rethrow;
      }

      //Polling every 5 seconds
      while (true) {
        await Future.delayed(const Duration(seconds: 5));
        try {
          final session = await repo.getActiveQuizSession(groupId);
          yield session;
        } catch (e) {
          rethrow;
        }
      }
    });

final activeQuizSessionsProvider = StreamProvider<List<StudyGroupQuizSession>>((
  ref,
) async* {
  final repo = ref.watch(studyGroupRepositoryProvider);
  //Initial fetch
  try {
    yield await repo.getAllActiveQuizSessions();
  } catch (e) {
    yield [];
  }

  //Polling every 10 seconds(slightly slower for global view)
  while (true) {
    await Future.delayed(const Duration(seconds: 10));
    try {
      final sessions = await repo.getAllActiveQuizSessions();
      yield sessions;
    } catch (e) {
      //Don't yield error for polling to keep UI stable
    }
  }
});

final studyGroupProvider = FutureProvider.family<StudyGroup?, String>((
  ref,
  id,
) {
  return ref.watch(studyGroupRepositoryProvider).getGroup(id);
});
