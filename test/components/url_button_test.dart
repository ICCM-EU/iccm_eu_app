import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/url_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UrlButton Tests', () {
    testWidgets('renders ElevatedButton with title when url starts with http', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UrlButton(
              title: 'Open Website',
              url: 'https://iccm-europe.org',
              inApp: false,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Open Website'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('renders QR code icon button when withQrCode is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UrlButton(
              title: 'Survey',
              url: 'https://iccm-europe.org/survey',
              inApp: true,
              withQrCode: true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('renders SizedBox.shrink when url is null or invalid', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UrlButton(
              title: 'Invalid',
              url: 'ftp://example.com',
              inApp: false,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ElevatedButton), findsNothing);
    });
  });
}
