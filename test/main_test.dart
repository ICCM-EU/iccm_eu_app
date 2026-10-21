import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/error_overlay.dart';
import 'package:iccm_eu_app/components/notification_permission_overlay.dart';
import 'package:iccm_eu_app/data/appProviders/error_provider.dart';
import 'package:iccm_eu_app/data/appProviders/expand_content_provider.dart';
import 'package:iccm_eu_app/data/appProviders/page_index_provider.dart';
import 'package:iccm_eu_app/data/appProviders/theme_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/communication_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/favorites_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/home_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/rooms_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/speakers_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/travel_details_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/travel_provider.dart';
import 'package:iccm_eu_app/main.dart';
import 'package:iccm_eu_app/pages/base_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget createTestApp({
  ThemeProvider? themeProvider,
  ExpandContentProvider? expandContentProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => themeProvider ?? ThemeProvider()),
      ChangeNotifierProvider(create: (_) => PageIndexProvider()),
      ChangeNotifierProvider(create: (_) => ErrorProvider()),
      ChangeNotifierProvider(create: (_) => GsheetsProvider()),
      ChangeNotifierProvider(create: (_) => expandContentProvider ?? ExpandContentProvider()),
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
      ChangeNotifierProxyProvider<GsheetsProvider, CommunicationProvider>(
        create: (context) => CommunicationProvider(
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
      ChangeNotifierProvider(create: (_) => FavoritesProvider()),
    ],
    child: const MyApp(),
  );
}

Future<void> pumpTestApp(WidgetTester tester, {
  ThemeProvider? themeProvider,
  ExpandContentProvider? expandContentProvider,
}) async {
  await tester.pumpWidget(createTestApp(
    themeProvider: themeProvider,
    expandContentProvider: expandContentProvider,
  ));
  await tester.runAsync(() async {
    await Future.delayed(const Duration(milliseconds: 500));
  });
  await tester.pump(const Duration(seconds: 30));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MyApp Widget & Route Generation Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders MyApp with BasePage, ErrorOverlay, and NotificationPermissionOverlay', (WidgetTester tester) async {
      await pumpTestApp(tester);

      expect(find.byType(MyApp), findsOneWidget);
      expect(find.byType(BasePage), findsOneWidget);
      expect(find.byType(ErrorOverlay), findsOneWidget);
      expect(find.byType(NotificationPermissionOverlay), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 30));
    });

    testWidgets('adapts themeMode from ThemeProvider', (WidgetTester tester) async {
      final themeProvider = ThemeProvider();
      await pumpTestApp(tester, themeProvider: themeProvider);

      final rootMaterialApp = tester.widget<MaterialApp>(find.byType(MaterialApp).first);
      expect(rootMaterialApp.themeMode, equals(themeProvider.themeMode));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 30));
    });

    testWidgets('handles route generation for root route / and unknown routes', (WidgetTester tester) async {
      await pumpTestApp(tester);

      final navigators = tester.widgetList<Navigator>(find.byType(Navigator));
      Navigator? myAppNavigator;
      for (final nav in navigators) {
        if (nav.onGenerateRoute != null) {
          final testRoute = nav.onGenerateRoute!(const RouteSettings(name: '/'));
          if (testRoute != null) {
            final builtWidget = (testRoute as MaterialPageRoute).builder(tester.element(find.byType(MyApp)));
            if (builtWidget is BasePage) {
              myAppNavigator = nav;
              break;
            }
          }
        }
      }

      expect(myAppNavigator, isNotNull);

      final Route<dynamic>? rootRoute = myAppNavigator!.onGenerateRoute!(const RouteSettings(name: '/'));
      expect(rootRoute, isA<MaterialPageRoute>());
      final Widget builtPage = (rootRoute as MaterialPageRoute).builder(tester.element(find.byType(MyApp)));
      expect(builtPage, isA<BasePage>());

      final Route<dynamic>? unknownRoute = myAppNavigator.onGenerateRoute!(const RouteSettings(name: '/unknown'));
      expect(unknownRoute, isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 30));
    });

    testWidgets('provides all required app providers in tree', (WidgetTester tester) async {
      await pumpTestApp(tester);

      final BuildContext context = tester.element(find.byType(MyApp));

      expect(Provider.of<ThemeProvider>(context, listen: false), isNotNull);
      expect(Provider.of<PageIndexProvider>(context, listen: false), isNotNull);
      expect(Provider.of<ErrorProvider>(context, listen: false), isNotNull);
      expect(Provider.of<GsheetsProvider>(context, listen: false), isNotNull);
      expect(Provider.of<ExpandContentProvider>(context, listen: false), isNotNull);
      expect(Provider.of<TracksProvider>(context, listen: false), isNotNull);
      expect(Provider.of<EventsProvider>(context, listen: false), isNotNull);
      expect(Provider.of<RoomsProvider>(context, listen: false), isNotNull);
      expect(Provider.of<SpeakersProvider>(context, listen: false), isNotNull);
      expect(Provider.of<HomeProvider>(context, listen: false), isNotNull);
      expect(Provider.of<CommunicationProvider>(context, listen: false), isNotNull);
      expect(Provider.of<TravelProvider>(context, listen: false), isNotNull);
      expect(Provider.of<TravelDetailsProvider>(context, listen: false), isNotNull);
      expect(Provider.of<FavoritesProvider>(context, listen: false), isNotNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 30));
    });
  });
}
