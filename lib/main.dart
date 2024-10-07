import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/rooms_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/speakers_provider.dart';
import 'package:iccm_eu_app/data/appProviders/page_index_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:iccm_eu_app/data/model/speaker_data.dart';
import 'package:iccm_eu_app/pages/speaker_details_page.dart';
import "package:provider/provider.dart" show ChangeNotifierProvider, MultiProvider, Provider;
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/theme/theme_provider.dart';
import 'package:iccm_eu_app/pages/base_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //final PrefsProvider prefsProvider = PrefsProvider();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => SpeakersProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => TracksProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => RoomsProvider(),
        ),
        ChangeNotifierProvider(
            create: (context) => EventsProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => PageIndexProvider(),
        ),
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //final PrefsProvider prefsProvider = Provider.of<PrefsProvider>(context);
    return MaterialApp(
      title: 'ICCM Europe App',
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: Scaffold(
        body: Navigator( // Use a Navigator for page transitions
          onGenerateRoute: (settings) {
            // Define routes for different pages
            if (settings.name == '/') {
              return MaterialPageRoute(builder: (context) => const BasePage());
            } else if (settings.name == '/speakerDetails') {
              final args = settings.arguments as SpeakerData;
              return MaterialPageRoute(builder: (context) => SpeakerDetailsPage(item: args));
            }
            return null; // Handle unknown routes
          },
        ),
      ),
    );
  }
}
