import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/controls/nav_bar.dart';
import 'package:iccm_eu_app/data/appProviders/page_index_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PageList Enum Tests', () {
    test('enum indices match expected page positions', () {
      expect(PageList.home.index, equals(0));
      expect(PageList.events.index, equals(1));
      expect(PageList.tracks.index, equals(2));
      expect(PageList.speakers.index, equals(3));
      expect(PageList.rooms.index, equals(4));
      expect(PageList.preferences.index, equals(5));
      expect(PageList.travelInformation.index, equals(6));
      expect(PageList.communication.index, equals(7));
      expect(PageList.about.index, equals(8));
      expect(PageList.share.index, equals(9));
    });
  });

  group('NavBar Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('bottomNavigationBarItems contains expected labels', () {
      final labels = NavBar.bottomNavigationBarItems.map((item) => item.label).toList();
      expect(labels, equals(['Home', 'Schedule', 'Tracks', 'Speakers', 'Rooms']));
    });

    test('widgetOptions contains 10 page options', () {
      const navBar = NavBar();
      expect(navBar.widgetOptions, hasLength(10));
    });

    testWidgets('renders BottomNavigationBar and responds to tab taps', (WidgetTester tester) async {
      final pageIndexProvider = PageIndexProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<PageIndexProvider>.value(
          value: pageIndexProvider,
          child: const MaterialApp(
            home: Scaffold(
              bottomNavigationBar: NavBar(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Schedule'), findsOneWidget);
      expect(find.text('Tracks'), findsOneWidget);
      expect(find.text('Speakers'), findsOneWidget);
      expect(find.text('Rooms'), findsOneWidget);

      await tester.tap(find.text('Schedule'));
      await tester.pump();

      expect(pageIndexProvider.selectedIndex, equals(1));

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
