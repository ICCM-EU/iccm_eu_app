import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/url_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UrlText Tests', () {
    testWidgets('renders SelectableText when url starts with http', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UrlText(url: 'https://iccm-europe.org'),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SelectableText), findsOneWidget);
      expect(find.text('https://iccm-europe.org'), findsOneWidget);
    });

    testWidgets('renders SizedBox.shrink when url is null or invalid', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UrlText(url: null),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SelectableText), findsNothing);
    });
  });
}
