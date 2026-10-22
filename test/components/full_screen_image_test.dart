import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/full_screen_image.dart';
import 'package:photo_view/photo_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FullScreenImage Tests', () {
    testWidgets('renders PhotoView with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FullScreenImage(imageUrl: 'https://example.com/image.png'),
        ),
      );
      await tester.pump();

      expect(find.text('Full Screen Image'), findsOneWidget);
      expect(find.byType(PhotoView), findsOneWidget);
    });
  });
}
