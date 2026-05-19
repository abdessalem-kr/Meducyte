import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

enum StudyEventType {
  exam,
  deadline,
  todoSession,
  activeRecall,
  manual,
  revision,
  practice,
  quiz,
  other,
}

class StudyEvent extends Equatable {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
  final StudyEventType type;
  final bool isAIPlaced;
  final String? relatedId; //ID of TodoItem or ExamEvent

  const StudyEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.type,
    this.isAIPlaced = false,
    this.relatedId,
  });

  StudyEvent copyWith({
    String? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    Color? color,
    StudyEventType? type,
    bool? isAIPlaced,
    String? relatedId,
  }) {
    return StudyEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      type: type ?? this.type,
      isAIPlaced: isAIPlaced ?? this.isAIPlaced,
      relatedId: relatedId ?? this.relatedId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    startTime,
    endTime,
    color,
    type,
    isAIPlaced,
    relatedId,
  ];
}

enum CalendarViewMode { day, week, month }

class CalendarState extends Equatable {
  final DateTime selectedDate;
  final List<StudyEvent> events;
  final List<String> weeklyObjectives;
  final CalendarViewMode viewMode;

  const CalendarState({
    required this.selectedDate,
    required this.events,
    this.weeklyObjectives = const [],
    this.viewMode = CalendarViewMode.week,
  });

  CalendarState copyWith({
    DateTime? selectedDate,
    List<StudyEvent>? events,
    List<String>? weeklyObjectives,
    CalendarViewMode? viewMode,
  }) {
    return CalendarState(
      selectedDate: selectedDate ?? this.selectedDate,
      events: events ?? this.events,
      weeklyObjectives: weeklyObjectives ?? this.weeklyObjectives,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  @override
  List<Object?> get props => [selectedDate, events, weeklyObjectives, viewMode];
}
