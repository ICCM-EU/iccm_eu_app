import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/appProviders/page_index_provider.dart';
import 'package:iccm_eu_app/data/model/travel_details_data.dart';
import 'package:iccm_eu_app/pages/travel_details_page.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TravelDetailsPage Tests', () {
    testWidgets('renders TravelDetailsPage with name and direction details', (WidgetTester tester) async {
      final sampleDetails = TravelDetailsData.fromJson({
        'imageUrl': '',
        'name': 'By Train',
        'details': 'Take line S1 to Central Station.',
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => PageIndexProvider()),
          ],
          child: MaterialApp(home: TravelDetailsPage(item: sampleDetails)),
        ),
      );
      await tester.pump();

      expect(find.text('Travel Directions'), findsOneWidget);
      expect(find.text('By Train'), findsOneWidget);
      expect(find.text('Take line S1 to Central Station.'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
