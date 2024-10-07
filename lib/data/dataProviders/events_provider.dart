import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';

class EventsProvider with ChangeNotifier {
  List<FlutterWeekViewEvent> get items => _items;
  final List<FlutterWeekViewEvent> _items = [];

  EventsProvider() {
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
    add(
        FlutterWeekViewEvent(
          title: 'An event 1',
          description: 'A description 1',
          start: date.subtract(Duration(hours: 1)),
          end: date.add(Duration(hours: 18, minutes: 30)),
          backgroundColor: Colors.red,
          padding: EdgeInsets.all(0),
        )
    );
    add(
        FlutterWeekViewEvent(
          title: 'An event 2a',
          description: 'A description 2',
          start: date.add(Duration(hours: 19)),
          end: date.add(Duration(hours: 22)),
          backgroundColor: Colors.indigo,
          padding: EdgeInsets.all(0),
        )
    );
    add(
        FlutterWeekViewEvent(
          title: 'An event 2b',
          description: 'A description 2',
          start: date.add(Duration(hours: 19)),
          end: date.add(Duration(hours: 22)),
          backgroundColor: Colors.green,
          padding: EdgeInsets.all(0),
        )
    );
    add(
        FlutterWeekViewEvent(
            title: 'An event 2c',
            description: 'A description 2',
            start: date.add(Duration(hours: 19)),
            end: date.add(Duration(hours: 22)),
            backgroundColor: Colors.purpleAccent,
            padding: EdgeInsets.all(0),
        )
    );
    add(
        FlutterWeekViewEvent(
          title: 'An event 3',
          description: 'A description 3',
          start: date.add(Duration(hours: 23, minutes: 30)),
          end: date.add(Duration(hours: 25, minutes: 30)),
          backgroundColor: Colors.teal,
          padding: EdgeInsets.all(0),
        )
    );
    add(
        FlutterWeekViewEvent(
          title: 'An event 4',
          description: 'A description 4',
          start: date.add(Duration(hours: 20)),
          end: date.add(Duration(hours: 21)),
          backgroundColor: Colors.grey,
          padding: EdgeInsets.all(0),
        )
    );
    add(
        FlutterWeekViewEvent(
          title: 'An event 5',
          description: 'A description 5',
          start: date.add(Duration(hours: 20)),
          end: date.add(Duration(hours: 21)),
          backgroundColor: Colors.blueGrey,
          padding: EdgeInsets.all(0),
        )
    );
  }

  void add(FlutterWeekViewEvent item) {
    _items.add(item);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
