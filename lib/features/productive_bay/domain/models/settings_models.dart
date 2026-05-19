import 'package:equatable/equatable.dart';

enum BaySectionType {
  fatigueTracker,
  navigationHub,
  pomodoroTimer,
  examCountdown,
  flashcardPulse,
  aiScheduler,
}

class BaySection extends Equatable {
  final String id;
  final String title;
  final BaySectionType type;
  final bool isEnabled;

  const BaySection({
    required this.id,
    required this.title,
    required this.type,
    this.isEnabled = true,
  });

  BaySection copyWith({
    String? id,
    String? title,
    BaySectionType? type,
    bool? isEnabled,
  }) {
    return BaySection(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'isEnabled': isEnabled,
    };
  }

  factory BaySection.fromJson(Map<String, dynamic> json) {
    return BaySection(
      id: json['id'],
      title: json['title'],
      type: BaySectionType.values.byName(json['type']),
      isEnabled: json['isEnabled'] ?? true,
    );
  }

  @override
  List<Object?> get props => [id, title, type, isEnabled];
}
