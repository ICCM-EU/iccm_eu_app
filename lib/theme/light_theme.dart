import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  // This is the theme of your application.
  //
  // TRY THIS: Try running your application with "flutter run". You'll see
  // the application has a purple toolbar. Then, without quitting the app,
  // try changing the seedColor in the colorScheme below to Colors.green
  // and then invoke "hot reload" (save your changes or press the "hot
  // reload" button in a Flutter-supported IDE, or press "r" if you used
  // the command line to start the app).

  appBarTheme: AppBarTheme(
    backgroundColor: Colors.green[900]!,
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
  useMaterial3: true,
);