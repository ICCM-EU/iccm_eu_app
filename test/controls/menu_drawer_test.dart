import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/controls/menu_drawer.dart';
import 'package:iccm_eu_app/controls/nav_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MenuDrawer Tests', () {
    testWidgets('renders drawer menu items and invokes setPageIndex on tap', (WidgetTester tester) async {
      int? selectedPageIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: MenuDrawer(
              setPageIndex: (index) {
                selectedPageIndex = index;
              },
            ),
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('More Options'), findsOneWidget);
      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Travel Information'), findsOneWidget);
      expect(find.text('Countdown Timer'), findsOneWidget);
      expect(find.text('Communication'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);

      await tester.tap(find.text('Preferences'));
      await tester.pumpAndSettle();

      expect(selectedPageIndex, equals(PageList.preferences.index));

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
