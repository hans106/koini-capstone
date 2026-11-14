import 'package:flutter/material.dart';

import 'package:koini/models/koini_data.dart';

abstract final class KColors {
  static const sky = Color(0xff0d1233);
  static const skyBottom = Color(0xff1c2364);
  static const panel = Color(0xff2b2f70);
  static const bright = Color(0xff3a3f8f);
  static const line = Color(0xff5157b8);
  static const soft = Color(0xffb6bae5);
  static const text = Color(0xffe4e6ff);
  static const gold = Color(0xffffc93c);
  static const shade = Color(0xffb47a09);
  static const ink = Color(0xff261700);
  static const mint = Color(0xff68e6ad);
  static const peach = Color(0xffffaf76);
  static const lavender = Color(0xffcdb6fa);
  static const error = Color(0xffffa6ae);
  static const field = Color(0xff12163f);

  static Color jar(Jar jar) => switch (jar) {
    Jar.tabung => mint,
    Jar.jajan => peach,
    Jar.berbagi => lavender,
  };
}

String _fontFamily(String family, String? package) =>
    package == null ? family : 'packages/$package/$family';

ThemeData koiniTheme({String? fontPackage}) => ThemeData(
  brightness: Brightness.dark,
  fontFamily: _fontFamily('Nunito', fontPackage),
  scaffoldBackgroundColor: KColors.sky,
  colorScheme: const ColorScheme.dark(
    primary: KColors.gold,
    onPrimary: KColors.ink,
    surface: KColors.panel,
    onSurface: Colors.white,
    error: KColors.error,
  ),
  textTheme: TextTheme(
    headlineMedium: TextStyle(fontFamily: _fontFamily('Baloo 2', fontPackage)),
    bodyMedium: const TextStyle(
      fontSize: 14,
      height: 1.36,
      color: Colors.white,
    ),
    bodySmall: const TextStyle(fontSize: 12, height: 1.35, color: KColors.text),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: KColors.field,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: KColors.line, width: 1.4),
      borderRadius: BorderRadius.circular(16),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: KColors.gold, width: 1.6),
      borderRadius: BorderRadius.circular(16),
    ),
    hintStyle: const TextStyle(color: KColors.soft),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.transparent,
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: KColors.bright,
    contentTextStyle: TextStyle(color: Colors.white),
  ),
);

String art(String name) => 'assets/illustrations/$name.png';
const dreamArt = ['book', 'bike', 'game', 'shirt', 'shoe', 'ball'];
String jarArt(Jar jar) => switch (jar) {
  Jar.tabung => 'piggy',
  Jar.jajan => 'snack',
  Jar.berbagi => 'gift',
};
