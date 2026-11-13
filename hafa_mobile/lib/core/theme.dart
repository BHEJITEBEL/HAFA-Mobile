import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Warna tema warisan Malaysia (sama seperti tailwind.config.js "heritage").
class HC {
  HC._();
  static const emerald = Color(0xFF0F4C3A);
  static const emeraldLight = Color(0xFF1A6B52);
  static const emeraldDark = Color(0xFF0A3325);
  static const gold = Color(0xFFD4AF37);
  static const goldLight = Color(0xFFE6C962);
  static const goldDark = Color(0xFFB8962E);
  static const cream = Color(0xFFF8F5EE);
  static const creamDark = Color(0xFFE8E3D8);
  static const teak = Color(0xFF3E2723);
  static const maroon = Color(0xFF7A1F1F);
  static const bronze = Color(0xFFB87333);
  static const forest = Color(0xFF2D6A4F);
  static const sand = Color(0xFFE9D8A6);
  static const navy = Color(0xFF1B263B);

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [emeraldDark, emerald, forest],
  );
}

extension ColorOpacityX on Color {
  /// Ubah kelegapan (0..1). Guna withAlpha supaya serasi dengan semua versi Flutter.
  Color o(double opacity) => withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
}

/// Gaya tajuk (Playfair Display).
TextStyle heading(
  double size, {
  Color color = HC.emeraldDark,
  FontWeight weight = FontWeight.w700,
  double? letterSpacing,
  FontStyle? style,
  double? height,
}) =>
    GoogleFonts.playfairDisplay(
      fontSize: size,
      color: color,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      fontStyle: style,
      height: height,
    );

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: HC.emerald,
      primary: HC.emerald,
      secondary: HC.gold,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: HC.cream,
  );
  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: HC.emerald,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: HC.emeraldDark,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
  );
}
