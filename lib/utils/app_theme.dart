import 'package:flutter/material.dart';

// The app's colours in one place, so every screen matches.
// To change the look of the whole app, change these values.
class AppColors {
  // Blue colours: used for buttons, the bottom bar, icons and header cards
  static const primary = Color(0xFF02253E); // deep navy
  static const primaryDark = Color(0xFF004270); // the other end of gradients
  // Light colours: backgrounds and boxes. Keep these light so text is readable
  static const tint = Color(0xFFE6F0F8); // pale blue: tiles, icon circles, pills
  static const background = Color(0xFFF4F7FB); // light blue-grey page background
  static const surface = Color(0xFFFFFFFF); // white: boxes and cards
  // Text colours: keep ink DARK. It is the colour of ALL main text,
  // including what people type, so a light colour here makes text hard to read
  static const ink = Color(0xFF1B2A38); // near-black blue: main text
  static const muted = Color(0xFF6B7F8E); // grey-blue: secondary text
  static const line = Color(0xFFDCE5EE); // soft blue-grey borders
  static const accent = Color(0xFF7E9C7B); // sage green highlights
  static const danger = Color(0xFFC4493C); // delete / log out

  // The blue gradient used on header cards
  static const headerGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // The soft shadow under boxes, so they float a little above the page
  static const softShadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 6)),
  ];
}

// Headings use a serif font (like the titles in the design), body text doesn't
const _serif = 'serif';

// One theme for the whole app: buttons, inputs, cards and dialogs all get
// the same colours and rounded corners without styling each screen by hand
ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.tint,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.accent,
    secondaryContainer: AppColors.tint,
    onSecondaryContainer: AppColors.primaryDark,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    outline: AppColors.muted,
    outlineVariant: AppColors.line,
    error: AppColors.danger,
  );

  OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );

  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    textTheme: base.textTheme.copyWith(
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontFamily: _serif,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(fontFamily: _serif),
      titleMedium: base.textTheme.titleMedium?.copyWith(fontFamily: _serif),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: _serif,
        color: AppColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.line),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: inputBorder(AppColors.line),
      enabledBorder: inputBorder(AppColors.line),
      disabledBorder: inputBorder(AppColors.line),
      focusedBorder: inputBorder(AppColors.primary, 1.5),
      errorBorder: inputBorder(AppColors.danger),
      focusedErrorBorder: inputBorder(AppColors.danger, 1.5),
      labelStyle: const TextStyle(color: AppColors.muted),
      hintStyle: const TextStyle(color: AppColors.muted),
      prefixIconColor: AppColors.muted,
      suffixIconColor: AppColors.muted,
    ),
    // Pill-shaped buttons, like "Check Now" in the design
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(64, 50),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(64, 48),
        side: const BorderSide(color: AppColors.primary),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: StadiumBorder(),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: AppColors.tint,
      side: BorderSide.none,
      shape: StadiumBorder(),
      labelStyle: TextStyle(color: AppColors.primaryDark),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.line),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
    ),
  );
}
