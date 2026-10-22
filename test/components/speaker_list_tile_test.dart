import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/speaker_list_tile.dart';
import 'package:iccm_eu_app/data/model/speaker_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SpeakerListTile Tests', () {
    testWidgets('renders SpeakerListTile with speaker name and details', (WidgetTester tester) async {
      final sampleSpeaker = SpeakerData(
        name: 'Alice Smith',
        company: 'Tech Corp',
        details: 'Senior Systems Architect',
        imageUrl: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpeakerListTile(item: sampleSpeaker),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Alice Smith', findRichText: true), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });
  });
}
