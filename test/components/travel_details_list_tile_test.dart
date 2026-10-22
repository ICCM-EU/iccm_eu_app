import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/travel_details_list_tile.dart';
import 'package:iccm_eu_app/data/model/travel_details_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TravelDetailsListTile Tests', () {
    testWidgets('renders TravelDetailsListTile with name and emoji', (WidgetTester tester) async {
      final sampleItem = TravelDetailsData.fromJson({
        'imageUrl': '',
        'name': 'By Train',
        'details': 'Direct connection from Airport Station.',
        'emoji': '🚆',
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TravelDetailsListTile(item: sampleItem),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('By Train', findRichText: true), findsOneWidget);
      expect(find.text('🚆'), findsOneWidget);
    });
  });
}
