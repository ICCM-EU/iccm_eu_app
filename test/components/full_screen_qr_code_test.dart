import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/full_screen_qr_code.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FullScreenQrCode Tests', () {
    testWidgets('renders FullScreenQrCode with title and QrImageView', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FullScreenQrCode(url: 'https://iccm-europe.org'),
        ),
      );
      await tester.pump();

      expect(find.text('Full Screen QR Code'), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('hides human-readable text when showText is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FullScreenQrCode(
            url: 'super_secret_password',
            title: 'FCM Admin Password',
            showText: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('FCM Admin Password'), findsOneWidget);
      expect(find.text('super_secret_password'), findsNothing);
      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
