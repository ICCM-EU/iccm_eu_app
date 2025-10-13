import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.grey,
    titleTextStyle: const TextStyle(
      fontSize: 20,
      color: Colors.grey,
    ),
  ),

  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    onSurface: Colors.grey.shade100,
    primary: Colors.grey.shade100,
    secondary: Colors.grey.shade600,
    tertiary: Colors.grey.shade700,
    inversePrimary: Colors.black,
    inverseSurface: Colors.black,
  ),

  textTheme: TextTheme(
    bodyMedium: TextStyle(
      color: Colors.grey.shade300,
    ),
    headlineMedium: TextStyle(
      color: Colors.grey.shade300,
      fontSize: 24,
    ),
    headlineSmall: TextStyle(
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      color: Colors.grey.shade300,
    ),
  ),
);