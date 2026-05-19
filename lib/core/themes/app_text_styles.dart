import 'package:meducyte_app/export.dart';

class AppTextStyles {
  ///Helper method to build text theme based on brightness
  ///Uses Inter for headings and body text,JetBrains Mono for data display
  static TextTheme buildTextTheme({
    required bool isLight,
    bool highContrast = false,
  }) {
    final Color textPrimary = highContrast
        ? (isLight ? Colors.black : Colors.white)
        : (isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark);

    final Color textSecondary = highContrast
        ? (isLight ? Colors.black : Colors.white)
        : (isLight
              ? AppColors.textSecondaryLight
              : AppColors.textSecondaryDark);

    final FontWeight boldWeight = highContrast
        ? FontWeight.w800
        : FontWeight.w700;
    final FontWeight mediumWeight = highContrast
        ? FontWeight.w700
        : FontWeight.w600;
    final FontWeight normalWeight = highContrast
        ? FontWeight.w500
        : FontWeight.w400;

    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: boldWeight,
        color: textPrimary,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: boldWeight,
        color: textPrimary,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: mediumWeight,
        color: textPrimary,
        letterSpacing: 0,
        height: 1.22,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: mediumWeight,
        color: textPrimary,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: mediumWeight,
        color: textPrimary,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: mediumWeight,
        color: textPrimary,
        letterSpacing: 0,
        height: 1.33,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: 0.15,
        height: 1.50,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: normalWeight,
        color: textPrimary,
        letterSpacing: 0.5,
        height: 1.50,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: normalWeight,
        color: textPrimary,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: highContrast ? FontWeight.w500 : FontWeight.w400,
        color: textSecondary,
        letterSpacing: 0.4,
        height: 1.33,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }

  static TextStyle dataTextStyle({
    required bool isLight,
    bool highContrast = false,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: 14,
      fontWeight: highContrast ? FontWeight.w500 : FontWeight.w400,
      color: highContrast
          ? (isLight ? Colors.black : Colors.white)
          : (isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark),
      letterSpacing: 0,
      height: 1.43,
    );
  }

  static TextStyle dataTextStyleBold({
    required bool isLight,
    bool highContrast = false,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: 16,
      fontWeight: highContrast ? FontWeight.w700 : FontWeight.w500,
      color: highContrast
          ? (isLight ? Colors.black : Colors.white)
          : (isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark),
      letterSpacing: 0,
      height: 1.50,
    );
  }

  static TextStyle captionStyle({
    required bool isLight,
    bool highContrast = false,
  }) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: highContrast ? FontWeight.w500 : FontWeight.w400,
      color: highContrast
          ? (isLight ? Colors.black : Colors.white)
          : (isLight
                ? AppColors.textSecondaryLight
                : AppColors.textSecondaryDark),
      letterSpacing: 0.4,
      height: 1.33,
    );
  }

  static TextStyle captionStyleMedium({
    required bool isLight,
    bool highContrast = false,
  }) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: highContrast ? FontWeight.w600 : FontWeight.w500,
      color: highContrast
          ? (isLight ? Colors.black : Colors.white)
          : (isLight
                ? AppColors.textSecondaryLight
                : AppColors.textSecondaryDark),
      letterSpacing: 0.4,
      height: 1.33,
    );
  }
}
