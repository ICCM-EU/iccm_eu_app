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
    surface: Colors.grey[900]!,
    onSurface: Colors.grey[700]!,
    primary: Colors.grey[100]!,
    secondary: Colors.grey[400]!,
    tertiary: Colors.grey[700]!,
    inversePrimary: Colors.black,
    inverseSurface: Colors.black,

  ),

  textTheme: TextTheme(
    bodyMedium: TextStyle(
      color: Colors.grey[300]!,
    ),
    headlineMedium: TextStyle(
      color: Colors.grey[300]!,
      fontSize: 24,
    ),
    headlineSmall: TextStyle(
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      color: Colors.grey[300]!,
    ),
  ),
);