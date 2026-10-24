import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/qr_scanner.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QrScannerPage Tests', () {
    testWidgets('renders QrScannerPage with AppBar and MobileScanner', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QrScanner(),
        ),
      );
      await tester.pump();

      expect(find.text('Scan QR Code'), findsOneWidget);
      expect(find.byType(MobileScanner), findsOneWidget);
    });
  });
}
