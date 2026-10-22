import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/room_list_tile.dart';
import 'package:iccm_eu_app/data/model/room_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RoomListTile Tests', () {
    testWidgets('renders RoomListTile with room name and details', (WidgetTester tester) async {
      final sampleRoom = RoomData(
        name: 'Main Auditorium',
        details: 'Keynote and main track venue',
        imageUrl: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoomListTile(item: sampleRoom),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Main Auditorium', findRichText: true), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });
  });
}
