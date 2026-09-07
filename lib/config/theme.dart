import 'package:flutter/material.dart';

class AppTheme {
  static const _ink = Color(0xFF172321);
  static const _white = Color(0xFFFFFFFF);
  static const _gray50 = Color(0xFFF9FAFB);
  static const _gray100 = Color(0xFFF3F4F6);
  static const _gray200 = Color(0xFFE5E7EB);
  static const _gray400 = Color(0xFF9CA3AF);
  static const _gray500 = Color(0xFF6B7280);
  static const _green600 = Color(0xFF16A34A);
  static const _red600 = Color(0xFFDC2626);
  static const _blue600 = Color(0xFF2563EB);
  static const _accent = Color(0xFF256B62);
  static const _accentStrong = Color(0xFF174F49);
  static const _tint = Color(0xFFF1F8F6);
  static const _sun = Color(0xFFF2C94C);

  static Color get ink => _ink;
  static Color get gray50 => _gray50;
  static Color get gray100 => _gray100;
  static Color get gray200 => _gray200;
  static Color get gray400 => _gray400;
  static Color get gray500 => _gray500;
  static Color get green600 => _green600;
  static Color get red600 => _red600;
  static Color get blue600 => _blue600;
  static Color get accent => _accent;
  static Color get accentStrong => _accentStrong;
  static Color get tint => _tint;
  static Color get sun => _sun;

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.light(
      primary: _accent,
      onPrimary: _white,
      surface: _white,
      onSurface: _ink,
      outline: _gray200,
    ),
    scaffoldBackgroundColor: _white,
    appBarTheme: const AppBarTheme(
      backgroundColor: _white,
      foregroundColor: _ink,
      elevation: 0,
      scrolledUnderElevation: 1,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        fontSize: 17,
        color: _ink,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _gray200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _gray200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _accent, width: 1.5),
      ),
      hintStyle: const TextStyle(color: _gray400, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _accent,
        foregroundColor: _white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _accent,
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _white,
      selectedColor: _accent,
      labelStyle: const TextStyle(fontSize: 13),
      side: const BorderSide(color: _gray200),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _white,
      selectedItemColor: _accent,
      unselectedItemColor: _gray400,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: const DividerThemeData(color: _gray100, thickness: 1),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: _gray200),
      ),
    ),
  );
}
