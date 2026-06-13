import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meducyte_app/features/auth/models/user.dart';

class ExamEvent extends Equatable {
  final String id;
  final String title;
  final DateTime date;

  const ExamEvent({required this.id, required this.title, required this.date});

  @override
  List<Object?> get props => [id, title, date];

  factory ExamEvent.fromJson(Map<String, dynamic> json) {
    return ExamEvent(
      id: json['id'].toString(),
      title: json['title'],
      date: DateTime.parse(json['date']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date.toUtc().toIso8601String(),
  };
}

class FocusSound extends Equatable {
  final String id;
  final String name;
  final String iconAsset; //Or Iconsax icon
  final String soundUrl;

  const FocusSound({
    required this.id,
    required this.name,
    required this.iconAsset,
    required this.soundUrl,
  });

  @override
  List<Object?> get props => [id, name, iconAsset, soundUrl];
}

class StudyStats extends Equatable {
  final int currentStreak;
  final int totalHours;
  final int completedPomodorosToday;
  final int completedShortBreaksToday;
  final int completedLongBreaksToday;
  final int totalPomodorosGoal;
  final Map<String, double> moduleScores; //Keep for productivity analytics

  const StudyStats({
    required this.currentStreak,
    required this.totalHours,
    required this.completedPomodorosToday,
    required this.completedShortBreaksToday,
    required this.completedLongBreaksToday,
    required this.totalPomodorosGoal,
    required this.moduleScores,
  });

  @override
  List<Object?> get props => [
    currentStreak,
    totalHours,
    completedPomodorosToday,
    completedShortBreaksToday,
    completedLongBreaksToday,
    totalPomodorosGoal,
    moduleScores,
  ];
}

class DailyGoal extends Equatable {
  final String id;
  final String title;
  final int targetValue;
  final int currentValue;
  final IconData icon;

  const DailyGoal({
    required this.id,
    required this.title,
    required this.targetValue,
    this.currentValue = 0,
    required this.icon,
  });

  bool get isCompleted => currentValue >= targetValue;

  @override
  List<Object?> get props => [id, title, targetValue, currentValue, icon];
}

class MedicalReference extends Equatable {
  final String id;
  final String name;
  final String source; //e.g.,HAS,AHA,ESC
  final IconData icon;
  final String url;

  const MedicalReference({
    required this.id,
    required this.name,
    required this.source,
    required this.icon,
    required this.url,
  });

  @override
  List<Object?> get props => [id, name, source, icon, url];
}

class StudyPulse extends Equatable {
  final int cardsDueToday;
  final int currentReviewStreak;
  final double masteryLevel; //0.0 to 1.0 overall

  const StudyPulse({
    required this.cardsDueToday,
    required this.currentReviewStreak,
    required this.masteryLevel,
  });

  @override
  List<Object?> get props => [cardsDueToday, currentReviewStreak, masteryLevel];
}

class ScheduledBlock extends Equatable {
  final String id;
  final String title;
  final Duration duration;
  final String reason; //e.g., 'Weakest module', 'Upcoming exam'
  final Color color;

  const ScheduledBlock({
    required this.id,
    required this.title,
    required this.duration,
    required this.reason,
    required this.color,
  });

  @override
  List<Object?> get props => [id, title, duration, reason, color];
}

enum StudyGroupType { silent, qcmBattle, focus }

class StudyGroup extends Equatable {
  final String id;
  final String title;
  final String description;
  final int membersCount;
  final int totalPomodoros;
  final List<String> tags;
  final Color themeColor;
  final IconData icon;
  final StudyGroupType type;
  final String? category;
  final bool isJoined;
  final List<String> memberIds;
  final List<User> members;

  const StudyGroup({
    required this.id,
    required this.title,
    required this.description,
    required this.membersCount,
    required this.totalPomodoros,
    required this.tags,
    required this.themeColor,
    required this.icon,
    required this.type,
    this.category,
    this.isJoined = false,
    this.activeQuizSessionId,
    this.isAdmin = false,
    this.isPublic = false,
    this.memberIds = const [],
    this.members = const [],
  });

  final String? activeQuizSessionId;
  final bool isAdmin;
  final bool isPublic;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    membersCount,
    totalPomodoros,
    tags,
    themeColor,
    icon,
    type,
    category,
    isJoined,
    activeQuizSessionId,
    isAdmin,
    isPublic,
    memberIds,
    members,
  ];

  StudyGroup copyWith({
    String? id,
    String? title,
    String? description,
    int? membersCount,
    int? totalPomodoros,
    List<String>? tags,
    Color? themeColor,
    IconData? icon,
    StudyGroupType? type,
    String? category,
    bool? isJoined,
    String? activeQuizSessionId,
    bool? isAdmin,
    bool? isPublic,
    List<String>? memberIds,
    List<User>? members,
  }) {
    return StudyGroup(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      membersCount: membersCount ?? this.membersCount,
      totalPomodoros: totalPomodoros ?? this.totalPomodoros,
      tags: tags ?? this.tags,
      themeColor: themeColor ?? this.themeColor,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      category: category ?? this.category,
      isJoined: isJoined ?? this.isJoined,
      activeQuizSessionId: activeQuizSessionId ?? this.activeQuizSessionId,
      isAdmin: isAdmin ?? this.isAdmin,
      isPublic: isPublic ?? this.isPublic,
      memberIds: memberIds ?? this.memberIds,
      members: members ?? this.members,
    );
  }
}

class StudyGroupMessage extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isEdited;
  final bool isMine;

  const StudyGroupMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.isEdited = false,
    this.isMine = false,
  });

  @override
  List<Object?> get props => [
    id,
    senderId,
    senderName,
    text,
    timestamp,
    isEdited,
    isMine,
  ];
}

class StudyGroupQuizQuestion extends Equatable {
  final String id;
  final String text;
  final List<String> options;
  final List<int> correctIndices;
  final String explanation;
  final String? clinicalCase;
  final String? sourceExam;
  final String? moduleName;
  final int? year;

  const StudyGroupQuizQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndices,
    required this.explanation,
    this.clinicalCase,
    this.sourceExam,
    this.moduleName,
    this.year,
  });

  @override
  List<Object?> get props => [
    id,
    text,
    options,
    correctIndices,
    explanation,
    clinicalCase,
    sourceExam,
    moduleName,
    year,
  ];

  factory StudyGroupQuizQuestion.fromJson(Map<String, dynamic> json) {
    final rawCorrectIndices = json['correctIndices'] ?? json['correct_indices'];
    List<int> correctIndices;

    if (rawCorrectIndices is List) {
      correctIndices = rawCorrectIndices
          .map((i) => (i as num?)?.toInt() ?? 0)
          .toList();
    } else if (rawCorrectIndices is Map) {
      //PHP sometimes serializes non-sequential arrays as objects/maps
      correctIndices = rawCorrectIndices.values
          .map((i) => (i as num?)?.toInt() ?? 0)
          .toList();
    } else {
      //Fallback to single index
      final singleIndex = json['correctIndex'] ?? json['correct_index'] ?? 0;
      correctIndices = [(singleIndex as num?)?.toInt() ?? 0];
    }

    return StudyGroupQuizQuestion(
      id: json['id']?.toString() ?? '',
      text: (json['text'] as String?) ?? '',
      options: List<String>.from((json['options'] as List?) ?? []),
      correctIndices: correctIndices,
      explanation: (json['explanation'] as String?) ?? '',
      clinicalCase: (json['clinical_case'] ?? json['clinicalCase']) as String?,
      sourceExam: json['source_exam'] as String?,
      moduleName: json['module_name'] as String?,
      year: json['year'] as int?,
    );
  }
}

class StudyGroupQuizSession extends Equatable {
  final String id;
  final String studyGroupId;
  final String quizId;
  final String title;
  final List<String> participantIds;
  final Map<String, int> participantScores;
  final List<StudyGroupQuizQuestion> questions;
  final bool isActive;
  final DateTime startTime;
  final int secondsPerQuestion;

  const StudyGroupQuizSession({
    required this.id,
    required this.studyGroupId,
    required this.quizId,
    required this.title,
    required this.participantIds,
    required this.participantScores,
    required this.questions,
    required this.isActive,
    required this.startTime,
    this.secondsPerQuestion = 15,
  });

  @override
  List<Object?> get props => [
    id,
    studyGroupId,
    quizId,
    title,
    participantIds,
    participantScores,
    questions,
    isActive,
    startTime,
    secondsPerQuestion,
  ];

  StudyGroupQuizSession copyWith({
    String? id,
    String? studyGroupId,
    String? quizId,
    String? title,
    List<String>? participantIds,
    Map<String, int>? participantScores,
    List<StudyGroupQuizQuestion>? questions,
    bool? isActive,
    DateTime? startTime,
    int? secondsPerQuestion,
  }) {
    return StudyGroupQuizSession(
      id: id ?? this.id,
      studyGroupId: studyGroupId ?? this.studyGroupId,
      quizId: quizId ?? this.quizId,
      title: title ?? this.title,
      participantIds: participantIds ?? this.participantIds,
      participantScores: participantScores ?? this.participantScores,
      questions: questions ?? this.questions,
      isActive: isActive ?? this.isActive,
      startTime: startTime ?? this.startTime,
      secondsPerQuestion: secondsPerQuestion ?? this.secondsPerQuestion,
    );
  }

  StudyGroupQuizSession copyWithParticipant(String participantId) {
    return copyWith(participantIds: [...participantIds, participantId]);
  }
}

class StudyGroupMember extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isOnline;
  final int pomodorosToday;

  const StudyGroupMember({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isOnline = false,
    this.pomodorosToday = 0,
  });

  @override
  List<Object?> get props => [id, name, avatarUrl, isOnline, pomodorosToday];
}
