
import 'package:iccm_eu_app/data/model/event_data.dart';
import 'package:iccm_eu_app/data/model/room_data.dart';
import 'package:iccm_eu_app/data/model/speaker_data.dart';
import 'package:iccm_eu_app/data/model/track_data.dart';


class TestData {
  static final List<RoomData> rooms = [
    RoomData(
      name: 'Room 1',
      details: 'First Room',
      imageUrl: '',
    ),
    RoomData(
      name: 'Room 2',
      details: 'Second Room',
      imageUrl: '',
    ),
    RoomData(
      name: 'Room 3',
      details: 'Third Room',
      imageUrl: '',
    ),
    RoomData(
      name: 'Room 4',
      details: 'Fourth Room',
      imageUrl: '',
    ),
  ];

  static final List<TrackData> tracks = [
    TrackData(
      name: 'Track 1',
      details: 'First Track',
      imageUrl: '',
    ),
    TrackData(
      name: 'Track 2',
      details: 'Second Track',
      imageUrl: '',
    ),
    TrackData(
      name: 'Track 3',
      details: 'Third Track',
      imageUrl: '',
    ),
    TrackData(
      name: 'Track 4',
      details: 'Fourth Track',
      imageUrl: '',
    ),
  ];

  static final List<SpeakerData> speakers = [
    SpeakerData(
      name: 'Speaker 1',
      details: 'First Speaker',
      imageUrl: '',
    ),
    SpeakerData(
      name: 'Speaker 2',
      details: 'Second Speaker',
      imageUrl: '',
    ),
    SpeakerData(
      name: 'Speaker 3',
      details: 'Third Speaker',
      imageUrl: '',
    ),
    SpeakerData(
      name: 'Speaker 4',
      details: 'Fourth Speaker',
      imageUrl: '',
    ),
  ];

  static List<EventData> getEvents() {
    List<EventData> items = [];
    // From previous day to next day
    // From 8:00 to 22:00
    // Schedule a series of events
    // Around now(), add a series of short events
    DateTime now = DateTime.now();
    DateTime scheduleStart = DateTime(now.year, now.month, now.day);
    List<DateTime> scheduleDays = [
      scheduleStart.subtract(Duration(days: 1)),
      scheduleStart,
      scheduleStart.add(Duration(days: 1)),
    ];
    int eventCount = 0;
    TrackData track;
    SpeakerData? speaker;
    RoomData room;
    for (DateTime day in scheduleDays) {
      DateTime startTime = day.add(Duration(hours: 8));
      while (startTime.hour < 22) {
        Duration duration;
        int parallel;
        if (startTime.isAfter(now.subtract(Duration(hours: 1, minutes: 1))) &&
            startTime.isBefore(now.add(Duration(hours: 1, minutes: 1)))) {
          // ----------------------------------------
          // Modify the duration around now here
          // duration = Duration(hours: 0, minutes: 6);
          duration = Duration(hours: 0, minutes: 30);
          // ----------------------------------------
          parallel = 2;
        } else {
          duration = Duration(hours: 1, minutes: 0);
          parallel = 0;
        }
        DateTime endTime = startTime.add(duration);
        for (int i = 0; i <= parallel; i++) {
          track = tracks[eventCount % tracks.length];
          room = rooms[eventCount % rooms.length];
          if (eventCount % 2 == 0) {
            speaker = speakers[eventCount % speakers.length];
          } else {
            speaker = null;
          }
          items.add(EventData(
            start: startTime,
            end: endTime,
            name: 'Event $eventCount',
            details: 'Details',
            track: track.name,
            speaker: speaker?.name,
            room: room.name,
          ));
          eventCount ++;
        }
        startTime = endTime;
      }
    }
    return items;
  }
}