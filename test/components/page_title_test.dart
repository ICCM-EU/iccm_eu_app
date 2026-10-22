import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/page_title.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PageTitle Tests', () {
    testWidgets('renders title text centered with specified style', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PageTitle(title: 'Settings Title'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Settings Title'), findsOneWidget);
      final textWidget = tester.widget<Text>(find.text('Settings Title'));
      expect(textWidget.style?.fontSize, equals(30));
    });
  });
}
