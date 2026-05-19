import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';

ThemeData getLightTheme({bool highContrast = false}) {
  return ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: highContrast
          ? AppColors.primary.withAlpha(51)
          : AppColors.primary.withAlpha(26),
      onPrimaryContainer: highContrast ? Colors.black : AppColors.primaryDark,
      secondary: AppColors.secondaryLight,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.primary,
      onSecondaryContainer: Colors.white,
      error: AppColors.errorLight,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: highContrast ? Colors.black : AppColors.primaryDark,
      tertiary: AppColors.accentLight,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.accentLight.withAlpha(26),
      onTertiaryContainer: AppColors.accentLight,
      onSurfaceVariant: highContrast
          ? Colors.black
          : AppColors.textSecondaryLight,
      outline: highContrast ? Colors.black : AppColors.dividerLight,
      outlineVariant: highContrast
          ? Colors.black54
          : AppColors.dividerLight.withAlpha(128),
      shadow: highContrast ? Colors.transparent : AppColors.shadowLight,
      scrim: Colors.black54,
      inverseSurface: AppColors.surfaceDark,
      onInverseSurface: AppColors.textPrimaryDark,
      inversePrimary: AppColors.primaryDark,
    ),

    scaffoldBackgroundColor: Colors.white,

    //AppBar theme with brand colors
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: highContrast ? 0 : 1.0,
      shadowColor: highContrast ? Colors.transparent : AppColors.shadowLight,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: highContrast ? FontWeight.w700 : FontWeight.w600,
        color: Colors.black,
        letterSpacing: -0.5,
      ),
      toolbarTextStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: highContrast ? FontWeight.w600 : FontWeight.w500,
        color: Colors.black,
      ),
    ),
    //Card theme for content hierarchy
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: highContrast ? 0 : 2.0,
      shadowColor: highContrast ? Colors.transparent : AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: highContrast
            ? const BorderSide(color: Colors.black, width: 2.0)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    //Bottom navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: highContrast
          ? Colors.black54
          : AppColors.textSecondaryLight,
      elevation: highContrast ? 0 : 4.0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: highContrast ? FontWeight.w600 : FontWeight.w400,
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: AppColors.primary.withOpacity(0.1),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          );
        }
        return GoogleFonts.inter(
          fontSize: 12,
          fontWeight: highContrast ? FontWeight.w600 : FontWeight.w500,
          color: highContrast ? Colors.black : AppColors.textSecondaryLight,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary, size: 24);
        }
        return IconThemeData(
          color: highContrast ? Colors.black : AppColors.textSecondaryLight,
          size: 24,
        );
      }),
    ),

    //Contextual floating action button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.accentLight,
      foregroundColor: Colors.white,
      elevation: highContrast ? 0 : 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: highContrast
            ? const BorderSide(color: Colors.black, width: 2.0)
            : BorderSide.none,
      ),
    ),

    //Button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        elevation: highContrast ? 0 : 2.0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: highContrast
              ? const BorderSide(color: Colors.black, width: 2.0)
              : BorderSide.none,
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: highContrast ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: const BorderSide(color: Colors.black, width: 2.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
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
      isLight: true,
      highContrast: highContrast,
    ),

    //Input decoration
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: highContrast ? Colors.black : AppColors.dividerLight,
          width: highContrast ? 2.0 : 1.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: highContrast ? Colors.black : AppColors.dividerLight,
          width: highContrast ? 2.0 : 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: AppColors.primary, width: 2.0),
      ),
      labelStyle: GoogleFonts.inter(
        color: highContrast ? Colors.black : AppColors.textSecondaryLight,
        fontSize: 16,
        fontWeight: highContrast ? FontWeight.w600 : FontWeight.w400,
      ),
      hintStyle: GoogleFonts.inter(
        color: highContrast
            ? Colors.black.withOpacity(0.7)
            : AppColors.textSecondaryLight.withAlpha(179),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    //Switch theme
    switchTheme: SwitchThemeData(
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return highContrast ? Colors.black : Colors.grey[300];
      }),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return highContrast ? Colors.black : Colors.grey[300];
      }),
    ),

    //Divider theme
    dividerTheme: DividerThemeData(
      color: highContrast ? Colors.black : AppColors.dividerLight,
      thickness: highContrast ? 2.0 : 1.0,
    ),

    dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
    extensions: [QuizThemeExtension.light],
  );
}
