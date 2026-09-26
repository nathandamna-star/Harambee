import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Thème de l'application : Fraunces pour les titres, DM Sans pour le texte.
abstract final class AppTheme {
  static const rayonCarte = 16.0;
  static const rayonBouton = 12.0;
  static const tailleTactileMin = 48.0;

  static ThemeData get clair => _construire(
    const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.terracotta,
      onPrimary: Colors.white,
      secondary: AppColors.vert,
      onSecondary: Colors.white,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      surface: AppColors.creme,
      onSurface: AppColors.texte,
      onSurfaceVariant: AppColors.texteSecondaire,
      surfaceContainerLowest: AppColors.carte,
      surfaceContainerLow: AppColors.carte,
      surfaceContainer: AppColors.carte,
      outline: AppColors.bordure,
      outlineVariant: AppColors.bordure,
    ),
  );

  static ThemeData get sombre => _construire(
    const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.terracottaClair,
      onPrimary: AppColors.texte,
      secondary: AppColors.vertClair,
      onSecondary: AppColors.texte,
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      surface: AppColors.sombreFond,
      onSurface: AppColors.sombreTexte,
      onSurfaceVariant: AppColors.sombreTexteSecondaire,
      surfaceContainerLowest: AppColors.sombreCarte,
      surfaceContainerLow: AppColors.sombreCarte,
      surfaceContainer: AppColors.sombreCarte,
      outline: AppColors.sombreBordure,
      outlineVariant: AppColors.sombreBordure,
    ),
  );

  static ThemeData _construire(ColorScheme couleurs) {
    final base = ThemeData(colorScheme: couleurs, useMaterial3: true);
    final texte = GoogleFonts.dmSansTextTheme(base.textTheme);
    final titres = GoogleFonts.frauncesTextTheme(base.textTheme);
    final textTheme = texte
        .copyWith(
          displayLarge: titres.displayLarge,
          displayMedium: titres.displayMedium,
          displaySmall: titres.displaySmall,
          headlineLarge: titres.headlineLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          headlineMedium: titres.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          headlineSmall: titres.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          titleLarge: titres.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        )
        .apply(bodyColor: couleurs.onSurface, displayColor: couleurs.onSurface);

    final forme = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(rayonBouton),
    );
    const tailleMin = Size(tailleTactileMin, tailleTactileMin);

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: couleurs.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: couleurs.surface,
        foregroundColor: couleurs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: couleurs.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rayonCarte),
          side: BorderSide(color: couleurs.outline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: tailleMin, shape: forme),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: tailleMin,
          shape: forme,
          side: BorderSide(color: couleurs.outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: tailleMin, shape: forme),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: couleurs.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rayonBouton),
          borderSide: BorderSide(color: couleurs.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rayonBouton),
          borderSide: BorderSide(color: couleurs.outline),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: couleurs.surfaceContainerLowest,
        indicatorColor: couleurs.primary.withValues(alpha: 0.14),
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),
      dividerTheme: DividerThemeData(color: couleurs.outline, space: 1),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}
