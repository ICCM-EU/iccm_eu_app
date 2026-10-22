import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/track_list_tile.dart';
import 'package:iccm_eu_app/data/model/track_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TrackListTile Tests', () {
    testWidgets('renders TrackListTile with track name and details', (WidgetTester tester) async {
      final sampleTrack = TrackData(
        name: 'Technical Track',
        details: 'Deep dive technical presentations and workshops',
        imageUrl: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrackListTile(item: sampleTrack),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Technical Track', findRichText: true), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });
  });
}
