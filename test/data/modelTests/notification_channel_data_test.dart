import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/model/notification_channel_data.dart';

void main() {
  group('NotificationChannelData Tests', () {
    test('instantiates with channel id, name, and description', () {
      final channel = NotificationChannelData(
        id: 'channel_id_1',
        name: 'Alerts',
        description: 'Important channel',
      );
      expect(channel.id, equals('channel_id_1'));
      expect(channel.name, equals('Alerts'));
      expect(channel.description, equals('Important channel'));
    });
  });
}
