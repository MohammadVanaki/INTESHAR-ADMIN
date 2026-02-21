import 'package:flutter/material.dart';

class MyThemes {
  static final ThemeData darkTheme = ThemeData(
    fontFamily: 'dijlah',
    useMaterial3: true,
    dividerTheme: const DividerThemeData(
      color: Color.fromARGB(50, 210, 210, 210),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black87,
        backgroundColor: const Color.fromARGB(255, 254, 194, 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color.fromARGB(255, 44, 44, 44),
      onPrimary: Color.fromARGB(255, 245, 245, 245),
      surface: Color.fromARGB(255, 55, 55, 55),
      onSurface: Color.fromARGB(255, 245, 245, 245),
      secondary: Color.fromARGB(255, 254, 194, 0),
      onSecondary: Color.fromARGB(255, 63, 34, 34),
      error: Color.fromARGB(255, 249, 52, 62),
      onError: Color(0xffffb4ab),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'dijlah',
    useMaterial3: true,
    dividerTheme: const DividerThemeData(color: Colors.black26),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black87,
        backgroundColor: const Color.fromARGB(255, 254, 194, 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color.fromARGB(255, 255, 255, 255),
      onPrimary: Color.fromARGB(255, 20, 20, 20),
      surface: Color.fromARGB(255, 208, 208, 208),
      onSurface: Color.fromARGB(255, 20, 20, 20),
      secondary: Color.fromARGB(255, 254, 194, 0),
      onSecondary: Color(0xff22323f),
      error: Color.fromARGB(255, 249, 52, 62),
      onError: Color(0xffffb4ab),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color.fromARGB(205, 208, 208, 208),
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      iconColor: Colors.transparent,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Colors.white, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Colors.white, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Colors.white, width: 1.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Colors.red, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Colors.red, width: 2.0),
      ),
    ),
  );
}
