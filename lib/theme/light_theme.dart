import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  appBarTheme: AppBarTheme(
    backgroundColor: Colors.green.shade900,
    foregroundColor: Colors.white,
    titleTextStyle: TextStyle(
      fontSize: 20,
      color: Colors.white,
    ),
  ),

  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade100,
    onSurface: Colors.grey.shade900,
    primary: Colors.grey.shade900,
    secondary: Colors.grey.shade600,
    tertiary: Colors.grey.shade300,
    inversePrimary: Colors.white,
    inverseSurface: Colors.grey.shade900,
  ),

  textTheme: TextTheme(
    bodyMedium: TextStyle(
      color: Colors.grey.shade900,
    ),
    headlineMedium: TextStyle(
      color: Colors.grey.shade900,
      fontSize: 24,
    ),
    headlineSmall: TextStyle(
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      color: Colors.grey.shade900,
    ),
  ),
);