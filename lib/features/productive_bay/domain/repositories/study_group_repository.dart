import 'package:meducyte_app/features/productive_bay/domain/models/productive_bay_models.dart';
import 'package:meducyte_app/features/auth/models/user.dart';

abstract class StudyGroupRepository {
  Future<List<StudyGroup>> getAvailableGroups();
  Future<List<StudyGroup>> getMyGroups();
  Future<StudyGroup?> getGroup(String groupId);
  Future<StudyGroup> createGroup(StudyGroup group);
  Future<StudyGroup> updateGroup(StudyGroup group);
  Future<void> deleteGroup(String groupId);
  Future<void> joinGroup(String groupId);
  Future<void> submitScore(String sessionId, String userId, int score);
  Future<void> leaveGroup(String groupId);
  Future<void> inviteFriend(String groupId, String friendId);
  Future<List<User>> searchUsers(String query);

  //Collaboration
  Future<List<StudyGroupMessage>> getMessages(String groupId);
  Future<void> sendMessage(String groupId, StudyGroupMessage message);
  Future<void> editMessage(String messageId, String text);
  Future<void> deleteMessage(String messageId);
  Future<void> reportMessage(String messageId, String reason);
  Future<StudyGroupQuizSession?> getActiveQuizSession(String groupId);
  Future<List<StudyGroupQuizSession>> getAllActiveQuizSessions();
  Future<StudyGroupQuizSession?> startQuizSession(
    String groupId,
    String quizId,
    String title, {
    List<String>? lessonIds,
    int? questionCount,
    bool? isClinical,
    int? secondsPerQuestion,
  });
  Future<void> joinQuizSession(String groupId, String sessionId);
  Future<StudyGroupQuizSession?> updateQuizSession(
    String sessionId, {
    String? title,
    int? questionCount,
    bool? isClinical,
    int? secondsPerQuestion,
  });
}
