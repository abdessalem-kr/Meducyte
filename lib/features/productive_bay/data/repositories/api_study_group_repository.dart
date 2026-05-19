import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/network/dio_client.dart';
import 'package:meducyte_app/features/productive_bay/domain/repositories/study_group_repository.dart';

class ApiStudyGroupRepository implements StudyGroupRepository {
  final DioClient _client;

  ApiStudyGroupRepository(this._client);

  @override
  Future<List<StudyGroup>> getAvailableGroups() async {
    const String query = r'''
 query{
   studyGroups{
     id
     title
     description
     color
     type
     members{
       id
       }
     is_admin
     }
   }
 ''';
    try {
      final response = await _client.post('/graphql', data: {'query': query});
      final data = response.data['data']['studyGroups'] as List;
      return data.map((g) => _mapToStudyGroup(g)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<StudyGroup>> getMyGroups() async {
    const String query = r'''
 query{
   myStudyGroups{
     id
     title
     description
     color
     type
     members{
       id
       }
     is_admin
     }
   }
 ''';
    try {
      final response = await _client.post('/graphql', data: {'query': query});
      final data = response.data['data']['myStudyGroups'] as List;
      return data.map((g) => _mapToStudyGroup(g)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<StudyGroup?> getGroup(String id) async {
    const String query = r'''
 query GetGroup($id:ID!) {
   studyGroup(id: $id) {
     id
     title
     description
     color
     type
     members{
       id
       name
       }
     active_quiz_session_id
     is_admin
     }
   }
 ''';
    try {
      final response = await _client.post(
        '/graphql',
        data: {
          'query': query,
          'variables': {'id': id},
        },
      );
      final data = response.data['data']['studyGroup'];
      if (data == null) return null;
      return _mapToStudyGroup(data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<StudyGroup> createGroup(StudyGroup group) async {
    const String mutation = r'''
 mutation CreateGroup($title:String!, $description:String, $color:String!, $type:String) {
   createStudyGroup(title: $title,description: $description,color: $color,type: $type) {
     id
     title
     description
     color
     type
     is_admin
     }
   }
 ''';
    final response = await _client.post(
      '/graphql',
      data: {
        'query': mutation,
        'variables': {
          'title': group.title,
          'description': group.description,
          'color': _toHex(group.themeColor),
          'type': _toTypeName(group.type),
        },
      },
    );
    final data = response.data['data']['createStudyGroup'];
    return _mapToStudyGroup(data);
  }

  @override
  Future<StudyGroup> updateGroup(StudyGroup group) async {
    const String mutation = r'''
 mutation UpdateGroup($groupId:ID!, $title:String, $description:String, $color:String!, $type:String) {
   updateStudyGroup(groupId: $groupId,title: $title,description: $description,color: $color,type: $type) {
     id
     title
     description
     color
     type
     is_admin
     }
   }
 ''';
    final response = await _client.post(
      '/graphql',
      data: {
        'query': mutation,
        'variables': {
          'groupId': group.id,
          'title': group.title,
          'description': group.description,
          'color': _toHex(group.themeColor),
          'type': _toTypeName(group.type),
        },
      },
    );
    final data = response.data['data']['updateStudyGroup'];
    return _mapToStudyGroup(data);
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    const String mutation = r'''
 mutation DeleteGroup($groupId:ID!) {
   deleteStudyGroup(groupId: $groupId)
   }
 ''';
    await _client.post(
      '/graphql',
      data: {
        'query': mutation,
        'variables': {'groupId': groupId},
      },
    );
  }

  @override
  Future<void> joinGroup(String groupId) async {
    const String mutation = r'''
 mutation JoinGroup($groupId:ID!) {
   joinStudyGroup(groupId: $groupId)
   }
 ''';
    await _client.post(
      '/graphql',
      data: {
        'query': mutation,
        'variables': {'groupId': groupId},
      },
    );
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    const String mutation = r'''
 mutation LeaveGroup($groupId:ID!) {
   leaveStudyGroup(groupId: $groupId)
   }
 ''';
    await _client.post(
      '/graphql',
      data: {
        'query': mutation,
        'variables': {'groupId': groupId},
      },
    );
  }

  @override
  Future<void> inviteFriend(String groupId, String friendId) async {
    const String mutation = r'''
 mutation InviteFriend($groupId:ID!, $friendId:ID!) {
   inviteToStudyGroup(groupId: $groupId,friendId: $friendId)
   }
 ''';
    await _client.post(
      '/graphql',
      data: {
        'query': mutation,
        'variables': {'groupId': groupId, 'friendId': friendId},
      },
    );
  }

  @override
  Future<List<User>> searchUsers(String queryText) async {
    const String query = r'''
 query SearchUsers($query:String!) {
   searchUsers(query: $query) {
     id
     name
     email
     }
   }
 ''';
    try {
      final response = await _client.post(
        '/graphql',
        data: {
          'query': query,
          'variables': {'query': queryText},
        },
      );
      final data = response.data['data']['searchUsers'] as List;
      return data.map((u) => User.fromJson(u as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<StudyGroupMessage>> getMessages(String groupId) async {
    const String query = r'''
 query GetMessages($groupId:ID!) {
   studyGroupMessages(groupId: $groupId) {
     id
     text
     type
     created_at
     is_edited
     is_mine
     user{
       id
       name
       }
     }
   }
 ''';
    try {
      final response = await _client.post(
        '/graphql',
        data: {
          'query': query,
          'variables': {'groupId': groupId},
        },
      );

      if (response.data['errors'] != null) {
        throw Exception(response.data['errors'][0]['message']);
      }

      final data = response.data['data']?['studyGroupMessages'];
      if (data == null) return [];

      return (data as List).map((m) => _mapToMessage(m)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> editMessage(String messageId, String text) async {
    final response = await _client.post(
      '/graphql',
      data: {
        'query': '''
   mutation EditMessage(\$messageId:ID!, \$text:String!) {
     editStudyGroupMessage(messageId: \$messageId,text: \$text) {
       id
       is_edited
       }
     }
   ''',
        'variables': {'messageId': messageId, 'text': text},
      },
    );

    if (response.data['errors'] != null) {
      throw Exception(response.data['errors'][0]['message']);
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    final response = await _client.post(
      '/graphql',
      data: {
        'query': '''
   mutation DeleteMessage(\$messageId:ID!) {
     deleteStudyGroupMessage(messageId: \$messageId)
     }
   ''',
        'variables': {'messageId': messageId},
      },
    );

    if (response.data['errors'] != null) {
      throw Exception(response.data['errors'][0]['message']);
    }
  }

  @override
  Future<void> reportMessage(String messageId, String reason) async {
    final response = await _client.post(
      '/graphql',
      data: {
        'query': '''
   mutation ReportMessage(\$messageId:ID!, \$reason:String!) {
     reportStudyGroupMessage(messageId: \$messageId,reason: \$reason)
     }
   ''',
        'variables': {'messageId': messageId, 'reason': reason},
      },
    );

    if (response.data['errors'] != null) {
      throw Exception(response.data['errors'][0]['message']);
    }
  }

  @override
  Future<void> sendMessage(String groupId, StudyGroupMessage message) async {
    const String mutation = r'''
 mutation SendMsg($groupId:ID!, $text:String!) {
   sendMessage(groupId: $groupId,text: $text) {
     id
     }
   }
 ''';
    final response = await _client.post(
      '/graphql',
      data: {
        'query': mutation,
        'variables': {'groupId': groupId, 'text': message.text},
      },
    );

    if (response.data['errors'] != null) {
      throw Exception(response.data['errors'][0]['message']);
    }
  }

  @override
  Future<StudyGroupQuizSession?> getActiveQuizSession(String groupId) async {
    const String query = r'''
 query GetActiveQuizSession($groupId:ID!) {
   activeStudyGroupQuiz(groupId: $groupId) {
     id
     study_group_id
     title
     quiz_id
     scores
     status
     created_at
     questions
     seconds_per_question
     }
   }
 ''';
    try {
      final response = await _client.post(
        '/graphql',
        data: {
          'query': query,
          'variables': {'groupId': groupId},
        },
      );

      if (response.data['errors'] != null) {
        throw Exception(response.data['errors'][0]['message']);
      }

      final data = response.data['data']['activeStudyGroupQuiz'];
      if (data == null) return null;
      return _mapToSession(data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<StudyGroupQuizSession>> getAllActiveQuizSessions() async {
    const String query = r'''
 query{
   activeQuizSessions{
     id
     study_group_id
     title
     quiz_id
     status
     created_at
     scores
     questions
     seconds_per_question
     }
   }
 ''';
    try {
      final response = await _client.post('/graphql', data: {'query': query});
      final data = response.data['data']['activeQuizSessions'] as List;
      return data.map((s) => _mapToSession(s)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<StudyGroupQuizSession?> startQuizSession(
    String groupId,
    String quizId,
    String title, {
    List<String>? lessonIds,
    int? questionCount,
    bool? isClinical,
    int? secondsPerQuestion,
  }) async {
    const String mutation = r'''
 mutation StartQuiz($groupId:ID!, $quizId:ID!, $title:String, $lessonIds: [ID!], $limit:Int, $isClinicalQuiz:Boolean, $secondsPerQuestion:Int) {
   startStudyGroupQuiz(groupId: $groupId,quizId: $quizId,title: $title,lessonIds: $lessonIds,limit: $limit,isClinicalQuiz: $isClinicalQuiz,secondsPerQuestion: $secondsPerQuestion) {
     id
     study_group_id
     title
     quiz_id
     status
     created_at
     scores
     questions
     seconds_per_question
     }
   }
 ''';
    final response = await _client.post(
      '/graphql',
      data: {
        'query': mutation,
        'variables': {
          'groupId': groupId,
          'quizId': quizId,
          'title': title,
          'lessonIds': lessonIds,
          'limit': questionCount,
          'isClinicalQuiz': isClinical,
          'secondsPerQuestion': secondsPerQuestion,
        },
      },
    );

    if (response.data['errors'] != null) {
      throw Exception(response.data['errors'][0]['message']);
    }

    final data = response.data['data']['startStudyGroupQuiz'];
    if (data == null) return null;
    return _mapToSession(data);
  }

  @override
  Future<void> submitScore(String sessionId, String userName, int score) async {
    const String mutation = r'''
 mutation SubmitScore($sessionId:ID!, $score:Int!) {
   submitStudyGroupScore(sessionId: $sessionId,score: $score) {
     id
     scores
     }
   }
 ''';
    await _client.post(
      '/graphql',
      data: {
        'query': mutation,
        'variables': {'sessionId': sessionId, 'score': score},
      },
    );
  }

  @override
  Future<void> joinQuizSession(String groupId, String sessionId) async {
    //Logic to join an existing session—in this MVP,everyone is
    //automatically part of active session via polling.
  }

  @override
  Future<StudyGroupQuizSession?> updateQuizSession(
    String sessionId, {
    String? title,
    int? questionCount,
    bool? isClinical,
    int? secondsPerQuestion,
  }) async {
    const String mutation = r'''
 mutation UpdateQuiz($sessionId:ID!, $title:String, $limit:Int, $isClinicalQuiz:Boolean, $secondsPerQuestion:Int) {
   updateStudyGroupQuizSession(sessionId: $sessionId,title: $title,limit: $limit,isClinicalQuiz: $isClinicalQuiz,secondsPerQuestion: $secondsPerQuestion) {
     id
     study_group_id
     title
     quiz_id
     status
     created_at
     scores
     questions
     seconds_per_question
     }
   }
 ''';
    try {
      final response = await _client.post(
        '/graphql',
        data: {
          'query': mutation,
          'variables': {
            'sessionId': sessionId,
            'title': title,
            'limit': questionCount,
            'isClinicalQuiz': isClinical,
            'secondsPerQuestion': secondsPerQuestion,
          },
        },
      );
      final data = response.data['data']?['updateStudyGroupQuizSession'];
      if (data == null) return null;
      return _mapToSession(data);
    } catch (e) {
      return null;
    }
  }

  StudyGroup _mapToStudyGroup(Map<String, dynamic> json) {
    return StudyGroup(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      membersCount: (json['members'] as List?)?.length ?? 0,
      totalPomodoros: 0,
      tags: [],
      themeColor: _parseColor(json['color']),
      icon: _parseIcon(json['type']),
      type: _parseType(json['type']),
      activeQuizSessionId: json['active_quiz_session_id']?.toString(),
      isAdmin: json['is_admin'] as bool? ?? false,
      isPublic:
          (json['title'] as String? ?? '').toUpperCase().contains('PUBLIC') ||
          (json['title'] as String? ?? '').toUpperCase().contains('DEMO'),
    );
  }

  StudyGroupMessage _mapToMessage(Map<String, dynamic> json) {
    return StudyGroupMessage(
      id: json['id'].toString(),
      senderId: json['user']?['id']?.toString() ?? '',
      senderName: json['user']?['name'] ?? 'Inconnu',
      text: json['text'] ?? '',
      timestamp: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isEdited: json['is_edited'] ?? false,
      isMine: json['is_mine'] ?? false,
    );
  }

  StudyGroupQuizSession _mapToSession(Map<String, dynamic> json) {
    //The backend may serialize an empty scores array as[] (PHP array)rather
    //than{} (JSON object).Guard against that to prevent a TypeError.
    final rawScores = json['scores'];
    final scoresMap = rawScores is Map<String, dynamic>
        ? rawScores
        : <String, dynamic>{};
    return StudyGroupQuizSession(
      id: json['id'].toString(),
      studyGroupId: json['study_group_id']?.toString() ?? '',
      quizId: json['quiz_id']?.toString() ?? '',
      title: json['title'] ?? 'Battle Session',
      participantIds: scoresMap.keys.toList(),
      participantScores: scoresMap.map(
        (k, v) => MapEntry(k, (v as num).toInt()),
      ),
      questions: (json['questions'] as List? ?? [])
          .map(
            (q) => StudyGroupQuizQuestion.fromJson(q as Map<String, dynamic>),
          )
          .toList(),
      isActive: json['status'] == 'active',
      startTime: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      secondsPerQuestion: (json['seconds_per_question'] as num?)?.toInt() ?? 0,
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.blue;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.blue;
    }
  }

  String _toHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  IconData _parseIcon(String? type) {
    switch (type) {
      case 'focus':
        return Iconsax.timer_1;
      case 'quiz':
        return Iconsax.medal_star;
      case 'chat':
        return Iconsax.messages_3;
      default:
        return Iconsax.status_up;
    }
  }

  StudyGroupType _parseType(String? type) {
    switch (type) {
      case 'focus':
        return StudyGroupType.focus;
      case 'quiz':
        return StudyGroupType.qcmBattle;
      case 'chat':
        return StudyGroupType.silent;
      default:
        return StudyGroupType.focus;
    }
  }

  String _toTypeName(StudyGroupType type) {
    switch (type) {
      case StudyGroupType.focus:
        return 'focus';
      case StudyGroupType.qcmBattle:
        return 'quiz';
      case StudyGroupType.silent:
        return 'chat';
    }
  }
}
