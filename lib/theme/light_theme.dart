import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  appBarTheme: AppBarTheme(
    backgroundColor: Colors.green[900]!,
    foregroundColor: Colors.white,
    titleTextStyle: TextStyle(
      fontSize: 20,
      color: Colors.white,
    ),
  ),

  colorScheme: ColorScheme.light(
    surface: Colors.grey[100]!,
    onSurface: Colors.grey[900]!,
    primary: Colors.grey[900]!,
    secondary: Colors.grey[600]!,
    tertiary: Colors.grey[300]!,
    inversePrimary: Colors.white,
    inverseSurface: Colors.grey[900]!,
  ),

  textTheme: TextTheme(
    bodyMedium: TextStyle(
      color: Colors.grey[900]!,
    ),
    headlineMedium: TextStyle(
      color: Colors.grey[900]!,
      fontSize: 24,
    ),
    displayMedium: TextStyle(
      color: Colors.grey[900]!,
    ),
  ),
);