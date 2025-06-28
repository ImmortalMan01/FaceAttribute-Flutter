import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme() {
    const baseColor = Color(0xFFF3F6FA);
    final base = ThemeData.light();
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      headlineLarge:
          GoogleFonts.inter(fontWeight: FontWeight.w700, textStyle: base.textTheme.headlineLarge),
      headlineMedium:
          GoogleFonts.inter(fontWeight: FontWeight.w600, textStyle: base.textTheme.headlineMedium),
      bodyLarge:
          GoogleFonts.inter(fontWeight: FontWeight.w400, textStyle: base.textTheme.bodyLarge),
    );
    return base.copyWith(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF3B82F6),
        secondary: Color(0xFFF59E0B),
        background: baseColor,
      ),
      scaffoldBackgroundColor: baseColor,
      textTheme: textTheme,
    );
  }

  static NeumorphicThemeData lightNeumorphicTheme() {
    return const NeumorphicThemeData(
      baseColor: Color(0xFFF3F6FA),
      accentColor: Color(0xFF3B82F6),
      variantColor: Color(0xFFF59E0B),
      depth: 4,
    );
  }

  static ThemeData darkTheme() {
    const baseColor = Color(0xFF17191C);
    final base = ThemeData.dark();
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      headlineLarge:
          GoogleFonts.inter(fontWeight: FontWeight.w700, textStyle: base.textTheme.headlineLarge),
      headlineMedium:
          GoogleFonts.inter(fontWeight: FontWeight.w600, textStyle: base.textTheme.headlineMedium),
      bodyLarge:
          GoogleFonts.inter(fontWeight: FontWeight.w400, textStyle: base.textTheme.bodyLarge),
    );
    return base.copyWith(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF60A5FA),
        secondary: Color(0xFFFBBF24),
        background: baseColor,
      ),
      scaffoldBackgroundColor: baseColor,
      textTheme: textTheme,
    );
  }

  static NeumorphicThemeData darkNeumorphicTheme() {
    return const NeumorphicThemeData(
      baseColor: Color(0xFF17191C),
      accentColor: Color(0xFF60A5FA),
      variantColor: Color(0xFFFBBF24),
      depth: 4,
    );
  }
}
