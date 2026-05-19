import 'package:flutter/material.dart';
import 'package:meducyte_app/core/themes/app_colors.dart';

class QuizThemeExtension extends ThemeExtension<QuizThemeExtension> {
  final Color backgroundColor;
  final Color cardColor;
  final Color cardSelectedColor;
  final Color correctBorderColor;
  final Color incorrectBorderColor;
  final Color correctTextColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color statCardBackgroundColor;
  final List<Color> highlightColors;

  const QuizThemeExtension({
    required this.backgroundColor,
    required this.cardColor,
    required this.cardSelectedColor,
    required this.correctBorderColor,
    required this.incorrectBorderColor,
    required this.correctTextColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.statCardBackgroundColor,
    required this.highlightColors,
  });

  @override
  QuizThemeExtension copyWith({
    Color? backgroundColor,
    Color? cardColor,
    Color? cardSelectedColor,
    Color? correctBorderColor,
    Color? incorrectBorderColor,
    Color? correctTextColor,
    Color? primaryTextColor,
    Color? secondaryTextColor,
    Color? statCardBackgroundColor,
    List<Color>? highlightColors,
  }) {
    return QuizThemeExtension(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      cardColor: cardColor ?? this.cardColor,
      cardSelectedColor: cardSelectedColor ?? this.cardSelectedColor,
      correctBorderColor: correctBorderColor ?? this.correctBorderColor,
      incorrectBorderColor: incorrectBorderColor ?? this.incorrectBorderColor,
      correctTextColor: correctTextColor ?? this.correctTextColor,
      primaryTextColor: primaryTextColor ?? this.primaryTextColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      statCardBackgroundColor:
          statCardBackgroundColor ?? this.statCardBackgroundColor,
      highlightColors: highlightColors ?? this.highlightColors,
    );
  }

  @override
  QuizThemeExtension lerp(ThemeExtension<QuizThemeExtension>? other, double t) {
    if (other is! QuizThemeExtension) return this;
    return QuizThemeExtension(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      cardSelectedColor: Color.lerp(
        cardSelectedColor,
        other.cardSelectedColor,
        t,
      )!,
      correctBorderColor: Color.lerp(
        correctBorderColor,
        other.correctBorderColor,
        t,
      )!,
      incorrectBorderColor: Color.lerp(
        incorrectBorderColor,
        other.incorrectBorderColor,
        t,
      )!,
      correctTextColor: Color.lerp(
        correctTextColor,
        other.correctTextColor,
        t,
      )!,
      primaryTextColor: Color.lerp(
        primaryTextColor,
        other.primaryTextColor,
        t,
      )!,
      secondaryTextColor: Color.lerp(
        secondaryTextColor,
        other.secondaryTextColor,
        t,
      )!,
      statCardBackgroundColor: Color.lerp(
        statCardBackgroundColor,
        other.statCardBackgroundColor,
        t,
      )!,
      highlightColors: List.generate(
        highlightColors.length,
        (index) => Color.lerp(
          highlightColors[index],
          other.highlightColors[index],
          t,
        )!,
      ),
    );
  }

  static const dark = QuizThemeExtension(
    backgroundColor: AppColors.quizBackgroundDark,
    cardColor: AppColors.quizCardDark,
    cardSelectedColor: Color(0xFF16315A),
    correctBorderColor: AppColors.quizCorrectBorder,
    incorrectBorderColor: AppColors.quizIncorrectBorder,
    correctTextColor: AppColors.quizCorrectText,
    primaryTextColor: Colors.white,
    secondaryTextColor: Colors.white70,
    statCardBackgroundColor: Color(0xFF0A1D37),
    highlightColors: [
      Color(0x80326399), //Primary blue
      Color(0x80FFB300), //Amber
      Color(0x804CAF50), //Green
      Color(0x80E91E63), //Rose
    ],
  );

  static const light = QuizThemeExtension(
    backgroundColor: AppColors.quizBackgroundLight,
    cardColor: Colors.white,
    cardSelectedColor: Color(0xFFE3EDF7),
    correctBorderColor: AppColors.quizCorrectBorder,
    incorrectBorderColor: AppColors.quizIncorrectBorder,
    correctTextColor: Color(0xFF2E7D32),
    primaryTextColor: AppColors.textPrimaryLight,
    secondaryTextColor: AppColors.textSecondaryLight,
    statCardBackgroundColor: Color(0xFFF8FAFC),
    highlightColors: [
      Color(0x40326399), //Primary blue
      Color(0x40FFB300), //Amber
      Color(0x404CAF50), //Green
      Color(0x40E91E63), //Rose
    ],
  );
}
