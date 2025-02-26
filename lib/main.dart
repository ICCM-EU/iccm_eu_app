import 'package:iccm_eu_app/data/appProviders/error_provider.dart';
import 'package:iccm_eu_app/data/appProviders/expand_content_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/favorites_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/home_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/rooms_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/speakers_provider.dart';
import 'package:iccm_eu_app/data/appProviders/page_index_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/travel_details_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/travel_provider.dart';
import 'package:iccm_eu_app/theme/dark_theme.dart';
import 'package:iccm_eu_app/theme/light_theme.dart';
import "package:provider/provider.dart" show ChangeNotifierProvider, ChangeNotifierProxyProvider, Consumer, MultiProvider, Provider;
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/appProviders/theme_provider.dart';
import 'package:iccm_eu_app/pages/base_page.dart';
import 'package:iccm_eu_app/platform/platform.dart';
import 'package:iccm_eu_app/platform/multiplatform.dart';
import 'package:window_manager/window_manager.dart';

import 'components/error_overlay.dart';

void main() async {
  Platform platform = getPlatform();
  WidgetsFlutterBinding.ensureInitialized();
  if (platform == Platform.windows ||
      platform == Platform.linux ||
      platform == Platform.macos) {
    WindowOptions windowOptions = WindowOptions(
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      windowManager.setFullScreen(false);
      await windowManager.show();
      await windowManager.focus();
    });
    await windowManager.ensureInitialized();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PageIndexProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ErrorProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => GsheetsProvider(
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ExpandContentProvider(
          ),
        ),
        ChangeNotifierProxyProvider<GsheetsProvider, TracksProvider>(
          create: (context) => TracksProvider(
              gsheetsProvider: Provider.of<GsheetsProvider>(context, listen: false),
          ),
          update: (context, gsheetsProvider, thisProvider) => thisProvider!..updateCache(),
        ),
        ChangeNotifierProxyProvider<GsheetsProvider, EventsProvider>(
          create: (context) => EventsProvider(
            gsheetsProvider: Provider.of<GsheetsProvider>(context, listen: false),
          ),
          update: (context, gsheetsProvider, thisProvider) => thisProvider!..updateCache(),
        ),
        ChangeNotifierProxyProvider<GsheetsProvider, RoomsProvider>(
          create: (context) => RoomsProvider(
            gsheetsProvider: Provider.of<GsheetsProvider>(context, listen: false),
          ),
          update: (context, gsheetsProvider, thisProvider) => thisProvider!..updateCache(),
        ),
        ChangeNotifierProxyProvider<GsheetsProvider, SpeakersProvider>(
          create: (context) => SpeakersProvider(
            gsheetsProvider: Provider.of<GsheetsProvider>(context, listen: false),
          ),
          update: (context, gsheetsProvider, thisProvider) => thisProvider!..updateCache(),
        ),
        ChangeNotifierProxyProvider<GsheetsProvider, HomeProvider>(
          create: (context) => HomeProvider(
            gsheetsProvider: Provider.of<GsheetsProvider>(context, listen: false),
          ),
          update: (context, gsheetsProvider, thisProvider) => thisProvider!..updateCache(),
        ),
        ChangeNotifierProxyProvider<GsheetsProvider, TravelProvider>(
          create: (context) => TravelProvider(
            gsheetsProvider: Provider.of<GsheetsProvider>(context, listen: false),
          ),
          update: (context, gsheetsProvider, thisProvider) => thisProvider!..updateCache(),
        ),
        ChangeNotifierProxyProvider<GsheetsProvider, TravelDetailsProvider>(
          create: (context) => TravelDetailsProvider(
            gsheetsProvider: Provider.of<GsheetsProvider>(context, listen: false),
          ),
          update: (context, gsheetsProvider, thisProvider) => thisProvider!..updateCache(),
        ),
        ChangeNotifierProvider(
          create: (context) => FavoritesProvider(),
        ),
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Future
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Platform platform = getPlatform();
    return MaterialApp(
        title: 'ICCM Europe App',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: Provider
            .of<ThemeProvider>(context)
            .themeMode,
        home: Scaffold(
            body: Column(
              children: [
                if (platform == Platform.windows ||
                    platform == Platform.linux ||
                    platform == Platform.macos) Consumer<ExpandContentProvider>(
                  builder: (context, expandContentProvider, child) {
                    return expandContentProvider.isExpanded ?
                    SizedBox.shrink() :
                    DragToMoveArea(
                      child: Container(
                        height: 32,
                        color: Theme
                            .of(context)
                            .appBarTheme
                            .backgroundColor,
                        child: WindowCaption(
                          brightness: Brightness.dark,
                          backgroundColor: Theme
                              .of(context)
                              .appBarTheme
                              .backgroundColor,
                        ),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Navigator( // Use a Navigator for page transitions
                        onGenerateRoute: (settings) {
                          // Define routes for different pages
                          if (settings.name == '/') {
                            return MaterialPageRoute(
                                builder: (context) => const BasePage());
                          }
                          return null; // Handle unknown routes
                        },
                      ),
                      const ErrorOverlay(),
                    ],
                  ),
                ),
              ],
            )
        )
    );
  }
}
