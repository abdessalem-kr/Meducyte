import 'package:meducyte_app/core/access/feature_access.dart';
import 'package:meducyte_app/features/subscription/data/models/subscription_model.dart';

class User {
  final int id;
  final String name;
  final String email;
  final int year;
  final String specialty;
  final UserSubscription? activeSubscription;

  //New Profile Fields
  final String? avatarKey;
  final String? learningGoal;
  final String? heardFrom;
  final String? quizPreference;
  final String? studyTime;
  final String? studyDuration;
  final List<String> interests;
  final DateTime? nextExamDate;
  final bool enableDailyChallenge;
  final bool showToFaculty;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.year,
    required this.specialty,
    this.activeSubscription,
    this.avatarKey,
    this.learningGoal,
    this.heardFrom,
    this.quizPreference,
    this.studyTime,
    this.studyDuration,
    this.interests = const [],
    this.nextExamDate,
    this.enableDailyChallenge = true,
    this.showToFaculty = true,
  });

  SubscriptionTier get tier {
    final sub = activeSubscription;
    if (sub == null || !sub.isActive) {
      return SubscriptionTier.free;
    }

    final plan = sub.plan;
    if (plan == null) return SubscriptionTier.free;

    final level = plan.accessLevel.toLowerCase();

    if (level == 'premium' || level == 'residency' || plan.hasAiAccess) {
      return SubscriptionTier.premium;
    }

    if (level == 'basic' || level == 'student') {
      return SubscriptionTier.basic;
    }

    return SubscriptionTier.free;
  }

  bool hasAccess(FeatureId feature) {
    return tier >= FeaturePolicy.getRequiredTier(feature);
  }

  bool get hasAiAccess => hasAccess(FeatureId.aiTutor);

  ///Whether the user has paid for ANY plan
  bool get isSubscriber => tier != SubscriptionTier.free;

  ///Premium plans(with AI)get full Module/Lesson access
  bool get hasModuleAccess => hasAccess(FeatureId.premiumCourses);

  bool get hasPremiumAccess => tier == SubscriptionTier.premium;

  bool get hasResidencyPremium {
    final sub = activeSubscription;
    if (sub == null || !sub.isActive) return false;
    final plan = sub.plan;
    if (plan == null) return false;
    return plan.accessLevel.toLowerCase() == 'residency' && plan.hasAiAccess;
  }

  factory User.fromJson(Map<String, dynamic> data) {
    return User(
      id: data['id'] != null ? int.tryParse(data['id'].toString()) ?? 0 : 0,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      year: data['year'] != null
          ? int.tryParse(data['year'].toString()) ?? 1
          : 1,
      specialty: data['specialty'] ?? data['faculte'] ?? '',
      avatarKey: data['avatar_key'],
      learningGoal: data['learning_goal'],
      heardFrom: data['heard_from'],
      quizPreference: data['quiz_preference'],
      studyTime: data['study_time'],
      studyDuration: data['study_duration'],
      interests: data['interests'] != null
          ? List<String>.from(data['interests'])
          : [],
      nextExamDate: data['next_exam_date'] != null
          ? DateTime.tryParse(data['next_exam_date'].toString())?.toLocal()
          : null,
      enableDailyChallenge: data['enable_daily_challenge'] ?? true,
      showToFaculty: data['show_to_faculty'] ?? true,
      activeSubscription:
          (data['active_subscription'] ?? data['activeSubscription']) != null
          ? UserSubscription.fromJson(
              data['active_subscription'] ?? data['activeSubscription'],
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'year': year,
    'specialty': specialty,
    'avatar_key': avatarKey,
    'learning_goal': learningGoal,
    'heard_from': heardFrom,
    'quiz_preference': quizPreference,
    'study_time': studyTime,
    'study_duration': studyDuration,
    'interests': interests,
    'next_exam_date': nextExamDate?.toUtc().toIso8601String(),
    'enable_daily_challenge': enableDailyChallenge,
    'show_to_faculty': showToFaculty,
    'active_subscription': activeSubscription?.toJson(),
  };

  User copyWith({
    int? id,
    String? name,
    String? email,
    int? year,
    String? specialty,
    UserSubscription? activeSubscription,
    String? avatarKey,
    String? learningGoal,
    String? heardFrom,
    String? quizPreference,
    String? studyTime,
    String? studyDuration,
    List<String>? interests,
    DateTime? nextExamDate,
    bool? enableDailyChallenge,
    bool? showToFaculty,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      year: year ?? this.year,
      specialty: specialty ?? this.specialty,
      activeSubscription: activeSubscription ?? this.activeSubscription,
      avatarKey: avatarKey ?? this.avatarKey,
      learningGoal: learningGoal ?? this.learningGoal,
      heardFrom: heardFrom ?? this.heardFrom,
      quizPreference: quizPreference ?? this.quizPreference,
      studyTime: studyTime ?? this.studyTime,
      studyDuration: studyDuration ?? this.studyDuration,
      interests: interests ?? this.interests,
      nextExamDate: nextExamDate ?? this.nextExamDate,
      enableDailyChallenge: enableDailyChallenge ?? this.enableDailyChallenge,
      showToFaculty: showToFaculty ?? this.showToFaculty,
    );
  }
}
