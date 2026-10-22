import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/link_list_tile.dart';
import 'package:iccm_eu_app/data/model/communication_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LinkListTile Tests', () {
    testWidgets('renders LinkListTile with title and url subtitle', (WidgetTester tester) async {
      final sampleItem = CommunicationData.fromJson({
        'leading': '🌐',
        'title': 'Official Website',
        'url': 'https://iccm-europe.org',
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkListTile(
              item: sampleItem,
              inApp: false,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Official Website', findRichText: true), findsOneWidget);
      expect(find.text('https://iccm-europe.org', findRichText: true), findsOneWidget);
    });
  });
}
