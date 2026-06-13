import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meducyte_app/shared/providers/network_provider.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/productive_bay_models.dart';
import 'package:meducyte_app/features/productive_bay/domain/repositories/study_group_repository.dart';
import 'package:meducyte_app/features/productive_bay/data/repositories/api_study_group_repository.dart';
import 'package:meducyte_app/features/auth/application/providers/auth_provider.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/pomodoro_provider.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/pomodoro_models.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import 'package:collection/collection.dart';

final studyGroupRepositoryProvider = Provider<StudyGroupRepository>((ref) {
  final client = ref.watch(dioClientProvider);
  return ApiStudyGroupRepository(client);
});

final availableStudyGroupsProvider = FutureProvider<List<StudyGroup>>((ref) {
  return ref.watch(studyGroupRepositoryProvider).getAvailableGroups();
});

/// Returns the groups that the current user is a member of.
/// Since the backend has no `myStudyGroups` query, we fetch all groups and
/// filter client-side using the `is_admin` flag and the members list.
final myStudyGroupsProvider = FutureProvider<List<StudyGroup>>((ref) async {
  final allGroups = await ref.watch(availableStudyGroupsProvider.future);
  final currentUser = ref.watch(authControllerProvider).value;

  if (currentUser == null) return [];

  final currentUserId = currentUser.id.toString();

  return allGroups.where((group) {
    // Admin of this group
    if (group.isAdmin) return true;
    // Or a member (memberIds populated from the members array in the response)
    if (group.memberIds.contains(currentUserId)) return true;
    return false;
  }).toList();
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

class FocusGroupMemberState extends Equatable {
  final int userId;
  final String name;
  final String? avatarKey;
  final bool isOnline;
  final bool isFocusing;
  final int focusTimeSeconds;

  const FocusGroupMemberState({
    required this.userId,
    required this.name,
    this.avatarKey,
    required this.isOnline,
    required this.isFocusing,
    required this.focusTimeSeconds,
  });

  FocusGroupMemberState copyWith({
    int? userId,
    String? name,
    String? avatarKey,
    bool? isOnline,
    bool? isFocusing,
    int? focusTimeSeconds,
  }) {
    return FocusGroupMemberState(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatarKey: avatarKey ?? this.avatarKey,
      isOnline: isOnline ?? this.isOnline,
      isFocusing: isFocusing ?? this.isFocusing,
      focusTimeSeconds: focusTimeSeconds ?? this.focusTimeSeconds,
    );
  }

  @override
  List<Object?> get props => [userId, name, avatarKey, isOnline, isFocusing, focusTimeSeconds];
}

class FocusGroupSessionNotifier extends StateNotifier<List<FocusGroupMemberState>> {
  final Ref ref;
  final String groupId;
  Timer? _timer;

  FocusGroupSessionNotifier(this.ref, this.groupId) : super([]) {
    _init();
  }

  void _init() {
    final groupAsync = ref.read(studyGroupProvider(groupId));
    final group = groupAsync.value;
    if (group != null) {
      _setupInitialMembers(group);
    }

    ref.listen(studyGroupProvider(groupId), (prev, next) {
      final updatedGroup = next.value;
      if (updatedGroup != null) {
        _setupInitialMembers(updatedGroup);
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _setupInitialMembers(StudyGroup group) {
    final currentUser = ref.read(authControllerProvider).value;
    final currentUserId = currentUser?.id;
    final currentList = state;

    final newList = group.members.map((m) {
      final existing = currentList.firstWhereOrNull((x) => x.userId == m.id);
      if (existing != null) return existing;

      final isMe = m.id == currentUserId;
      final randomTime = isMe ? 0 : (m.id % 5 + 1) * 300 + (m.id % 60);
      final isOnline = isMe ? true : (m.id % 2 == 0);
      final isFocusing = isMe ? false : (isOnline && m.id % 3 == 0);

      return FocusGroupMemberState(
        userId: m.id,
        name: m.name,
        avatarKey: m.avatarKey,
        isOnline: isOnline,
        isFocusing: isFocusing,
        focusTimeSeconds: randomTime,
      );
    }).toList();

    state = newList;
  }

  void _tick() {
    final currentUser = ref.read(authControllerProvider).value;
    final currentUserId = currentUser?.id;
    final pomodoro = ref.read(pomodoroProvider);
    final isUserFocusing = pomodoro.state == PomodoroState.running;

    state = state.map((member) {
      if (member.userId == currentUserId) {
        return member.copyWith(
          isFocusing: isUserFocusing,
          focusTimeSeconds: isUserFocusing
              ? member.focusTimeSeconds + 1
              : member.focusTimeSeconds,
        );
      } else {
        if (member.isOnline && member.isFocusing) {
          return member.copyWith(
            focusTimeSeconds: member.focusTimeSeconds + 1,
          );
        }
      }
      return member;
    }).toList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final focusGroupSessionsProvider = StateNotifierProvider.family<
    FocusGroupSessionNotifier,
    List<FocusGroupMemberState>,
    String
>((ref, groupId) {
  return FocusGroupSessionNotifier(ref, groupId);
});
