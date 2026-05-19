import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class HighlightModel extends Equatable {
  final String id;
  final String text;
  final int start;
  final int end;
  final Color color;
  final String? note;
  final DateTime createdAt;

  HighlightModel({
    required this.id,
    required this.text,
    required this.start,
    required this.end,
    required this.color,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  HighlightModel copyWith({
    String? id,
    String? text,
    int? start,
    int? end,
    Color? color,
    String? note,
    DateTime? createdAt,
  }) {
    return HighlightModel(
      id: id ?? this.id,
      text: text ?? this.text,
      start: start ?? this.start,
      end: end ?? this.end,
      color: color ?? this.color,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'start': start,
    'end': end,
    'color': color.value,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
  };

  factory HighlightModel.fromJson(Map<String, dynamic> json) {
    return HighlightModel(
      id: json['id'] as String,
      text: json['text'] as String,
      start: json['start'] as int,
      end: json['end'] as int,
      color: Color(json['color'] as int),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, text, start, end, color, note, createdAt];
}
