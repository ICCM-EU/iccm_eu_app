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

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    titleTextStyle: TextStyle(
      fontSize: 20,
      color: Colors.black,
    ),
  ),
  colorScheme: ColorScheme.light(
    surface: Colors.grey[100]!,
    primary: Colors.grey[900]!,
    secondary: Colors.grey[600]!,
    tertiary: Colors.grey[300]!,
  ),
  useMaterial3: true,
);