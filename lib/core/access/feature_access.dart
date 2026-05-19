enum SubscriptionTier {
  free(0),
  basic(1),
  premium(2);

  final int level;
  const SubscriptionTier(this.level);

  bool operator >=(SubscriptionTier other) => level >= other.level;
}

enum FeatureId {
  //Learn
  basicCourses,
  premiumCourses,

  //Quiz
  standardQuiz,
  customQuiz,
  advancedStats,

  //AI
  aiTutor,
  aiCaseAnalysis,

  //Tools
  basicCalculators,
  advancedCalculators,
  drugDatabase,

  //Productivity
  pomodoro,
  studyGroups,
  todoSync,
}

class FeaturePolicy {
  static SubscriptionTier getRequiredTier(FeatureId feature) {
    switch (feature) {
      case FeatureId.basicCourses:
      case FeatureId.standardQuiz:
      case FeatureId.basicCalculators:
      case FeatureId.pomodoro:
      case FeatureId.todoSync:
        return SubscriptionTier.free;

      case FeatureId.customQuiz:
      case FeatureId.advancedCalculators:
      case FeatureId.drugDatabase:
        return SubscriptionTier.basic;

      case FeatureId.premiumCourses:
      case FeatureId.advancedStats:
      case FeatureId.aiTutor:
      case FeatureId.aiCaseAnalysis:
      case FeatureId.studyGroups:
        return SubscriptionTier.premium;
    }
  }

  static String getFeatureLabel(FeatureId feature) {
    switch (feature) {
      case FeatureId.basicCourses:
        return "Basic Courses";
      case FeatureId.premiumCourses:
        return "Premium Courses";
      case FeatureId.standardQuiz:
        return "Standard Quiz";
      case FeatureId.customQuiz:
        return "Custom Quiz";
      case FeatureId.advancedStats:
        return "Advanced Statistics";
      case FeatureId.aiTutor:
        return "AI Medical Tutor";
      case FeatureId.aiCaseAnalysis:
        return "AI Case Analysis";
      case FeatureId.basicCalculators:
        return "Basic Calculators";
      case FeatureId.advancedCalculators:
        return "Advanced Calculators";
      case FeatureId.drugDatabase:
        return "Drug Database";
      case FeatureId.pomodoro:
        return "Pomodoro Timer";
      case FeatureId.studyGroups:
        return "Study Groups";
      case FeatureId.todoSync:
        return "Todo Sync";
    }
  }
}
