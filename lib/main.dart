import "package:provider/provider.dart" show ChangeNotifierProvider, Provider;

import 'package:flutter/material.dart';
import 'package:iccm_eu_app/theme/theme_provider.dart';
import 'package:iccm_eu_app/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ICCM Europe App',
      home: const MyHomePage(title: 'ICCM Europe App'),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
