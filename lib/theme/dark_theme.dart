import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  // This is the theme of your application.
  //
  // TRY THIS: Try running your application with "flutter run". You'll see
  // the application has a purple toolbar. Then, without quitting the app,
  // try changing the seedColor in the colorScheme below to Colors.green
  // and then invoke "hot reload" (save your changes or press the "hot
  // reload" button in a Flutter-supported IDE, or press "r" if you used
  // the command line to start the app).
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black,
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
    displayMedium: TextStyle(
      color: Colors.grey[300]!,
    ),
  ),
  useMaterial3: true,
);