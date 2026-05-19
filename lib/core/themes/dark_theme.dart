import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';

ThemeData getDarkTheme({bool highContrast = false}) {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: highContrast
        ? Colors.black
        : const Color.fromARGB(255, 5, 12, 29),

    //AppBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: highContrast ? Colors.black : AppColors.primaryDark,
      foregroundColor: Colors.white,
      elevation: highContrast ? 0 : 1.0,
      shadowColor: highContrast ? Colors.transparent : AppColors.shadowLight,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: highContrast ? FontWeight.w700 : FontWeight.w600,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      toolbarTextStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: highContrast ? FontWeight.w600 : FontWeight.w500,
        color: Colors.white,
      ),
    ),

    //Card theme
    cardTheme: CardThemeData(
      color: highContrast ? Colors.black : AppColors.cardDark,
      elevation: highContrast ? 0 : 2.0,
      shadowColor: highContrast ? Colors.transparent : AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: highContrast
            ? const BorderSide(color: Colors.white, width: 2.0)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    //Bottom navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: highContrast ? Colors.black : AppColors.surfaceDark,
      selectedItemColor: Colors.white,
      unselectedItemColor: highContrast
          ? Colors.white70
          : AppColors.textSecondaryLight,
      elevation: highContrast ? 0 : 4.0,
      type: BottomNavigationBarType.fixed,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: highContrast ? Colors.black : AppColors.surfaceDark,
      indicatorColor: Colors.white.withOpacity(0.2),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          );
        }
        return GoogleFonts.inter(
          fontSize: 12,
          fontWeight: highContrast ? FontWeight.w600 : FontWeight.w500,
          color: highContrast ? Colors.white : AppColors.textSecondaryLight,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Colors.white, size: 24);
        }
        return IconThemeData(
          color: highContrast ? Colors.white : AppColors.textSecondaryLight,
          size: 24,
        );
      }),
    ),

    //Button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: highContrast ? 0 : 2.0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
          side: highContrast
              ? const BorderSide(color: Colors.white, width: 2.0)
              : BorderSide.none,
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: const BorderSide(color: Colors.white, width: 2.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: highContrast ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: 0.25,
        ),
      ),
    ),

    //Typography
    textTheme: AppTextStyles.buildTextTheme(
      isLight: false,
      highContrast: highContrast,
    ),

    //Input decoration
    inputDecorationTheme: InputDecorationTheme(
      fillColor: highContrast ? Colors.black : AppColors.surfaceDark,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: highContrast ? Colors.white : AppColors.dividerLight,
          width: highContrast ? 2.0 : 1.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: highContrast ? Colors.white : AppColors.dividerLight,
          width: highContrast ? 2.0 : 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.white, width: 2.0),
      ),
      labelStyle: GoogleFonts.inter(
        color: highContrast ? Colors.white : AppColors.textSecondaryLight,
        fontSize: 16,
        fontWeight: highContrast ? FontWeight.w600 : FontWeight.w400,
      ),
      hintStyle: GoogleFonts.inter(
        color: highContrast
            ? Colors.white.withOpacity(0.7)
            : AppColors.textSecondaryLight.withAlpha(179),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    //Switch theme
    switchTheme: SwitchThemeData(
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return highContrast ? Colors.white : Colors.grey[300];
      }),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return highContrast ? Colors.white : Colors.grey[300];
      }),
    ),

    //Divider theme
    dividerTheme: DividerThemeData(
      color: highContrast ? Colors.white : AppColors.dividerLight,
      thickness: highContrast ? 2.0 : 1.0,
    ),

    dialogTheme: const DialogThemeData(backgroundColor: Colors.black),
    extensions: [QuizThemeExtension.dark],
  );
}
