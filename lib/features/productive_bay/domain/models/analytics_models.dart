import 'package:equatable/equatable.dart';

enum FatigueLevel {
  peak, //Fresh,high focus
  optimal, //Sustained focus
  tired, //Slight drop in quality,switch subject
  exhausted, //High error risk,break mandatory
}

class FocusSession extends Equatable {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String subject;
  final double intensity; //0.0 to 1.0(derived from frequency of actions/MCQs)
  final int? confidenceScore; //1-5(User logged)
  final String? difficultConcept; //Post-session note

  const FocusSession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.subject,
    this.intensity = 0.8,
    this.confidenceScore,
    this.difficultConcept,
  });

  @override
  List<Object?> get props => [
    id,
    startTime,
    endTime,
    subject,
    intensity,
    confidenceScore,
    difficultConcept,
  ];
}

class FatigueStatus extends Equatable {
  final FatigueLevel level;
  final String recommendation;
  final String? recommendationKey;
  final double cognitiveLoad; //0.0 to 1.0 gauge value

  const FatigueStatus({
    required this.level,
    required this.recommendation,
    this.recommendationKey,
    required this.cognitiveLoad,
  });

  @override
  List<Object?> get props => [
    level,
    recommendation,
    recommendationKey,
    cognitiveLoad,
  ];
}
