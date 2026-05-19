import 'package:flutter/material.dart';

class AppColors {
  //brand colors
  //Medical Trust Palette-Color specifications
  static const Color primary = Color.fromARGB(255, 22, 70, 129);
  static const Color primaryLight = Color(0xFFdcf1f8);
  static const Color primaryDark = Color(0xFF102148);
  //background colors
  //Background colors optimized for extended mobile reading
  //Soft off-white
  static const Color backgroundLight = Color(0xFFF5F7FA);
  //Deep dark for clinical environments
  static const Color backgroundDark = Color(0xFF050C1D);

  //Medical Trust Palette-Color specifications
  static const Color secondaryLight = Color(0xFF00A86B); //Success green
  static const Color secondaryDark = Color(
    0xFF00C878,
  ); //Brighter success green for dark theme
  static const Color accentLight = Color(0xFFFF6B35); //Warm orange
  static const Color accentDark = Color(
    0xFFFF8A5B,
  ); //Softer orange for dark theme

  static const Color surfaceLight = Color(0xFFFFFFFF); //Pure white
  static const Color surfaceDark = Color(0xFF1A1F2E); //Dark surface

  //Error and warning colors for medical context
  static const Color errorLight = Color(0xFFE53E3E); //Clear red
  static const Color errorDark = Color(0xFFFC8181); //Softer red for dark theme
  static const Color warningLight = Color(0xFFF6AD55); //Amber
  static const Color warningDark = Color(
    0xFFFBD38D,
  ); //Lighter amber for dark theme

  //Text colors optimized for various lighting conditions
  static const Color textPrimaryLight = Color(0xFF1A202C); //Near-black
  static const Color textPrimaryDark = Color(0xFFF7FAFC); //Near-white
  static const Color textSecondaryLight = Color(0xFF718096); //Medium gray
  static const Color textSecondaryDark = Color(0xFFA0AEC0); //Light gray
  static const Color dividerLight = Color(0xFFE2E8F0); //Subtle gray
  static const Color dividerDark = Color(0xFF2D3748); //Dark divider

  //Card and dialog colors for content hierarchy
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1A1F2E);
  static const Color dialogLight = Color(0xFFFFFFFF);
  static const Color dialogDark = Color(0xFF2D3748);

  //Shadow colors with clinical restraint(max 0.12 opacity)
  static const Color shadowLight = Color(0x1F000000); //0.12 opacity
  static const Color shadowDark = Color(0x1FFFFFFF); //0.12 opacity

  //Quiz specialized colors
  static const Color quizBackgroundDark = Color(0xFF031024);
  static const Color quizBackgroundLight = Color(
    0xFFF0F4F8,
  ); //Soft light blue-gray

  static const Color quizCardDark = Color(0xFF0D2547);
  static const Color quizCardLight = Color(0xFFFFFFFF); //Clean white card

  static const Color quizCorrectBorder = Color(0xFF2E6B47);
  static const Color quizIncorrectBorder = Color(0xFFB63D3D);
  static const Color quizCorrectText = Color(0xFF4CAF50);
  static const Color success = Color(0xFF4CAF50);
}
