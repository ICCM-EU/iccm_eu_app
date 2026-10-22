import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/toggle_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ToggleButtonListTile Tests', () {
    testWidgets('renders SwitchListTile with title and value', (WidgetTester tester) async {
      bool currentValue = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: ToggleButtonListTile(
                  value: currentValue,
                  title: 'Dark Mode',
                  toggleTitle: 'Theme',
                  onChanged: (val) {
                    setState(() {
                      currentValue = val;
                    });
                  },
                ),
              ),
            );
          },
        ),
      );
      await tester.pump();

      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);

      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();

      expect(currentValue, isTrue);
    });
  });
}
