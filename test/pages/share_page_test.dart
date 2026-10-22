import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/url_text.dart';
import 'package:iccm_eu_app/pages/share_page.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharePage Tests', () {
    testWidgets('renders SharePage with URL text and QR code', (WidgetTester tester) async {
      const testUrl = 'https://iccm-europe.org';
      await tester.pumpWidget(
        const MaterialApp(
          home: SharePage(url: testUrl),
        ),
      );
      await tester.pump();

      expect(find.text('Share QR Code'), findsOneWidget);
      expect(find.byType(UrlText), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
