import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/model/provider_data.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';
import 'package:provider/provider.dart';

class EventsProvider extends ProviderData<EventData> with ChangeNotifier {
  @override
  String get worksheetTitle => "Schedule";

  List<EventData> get items => _items;
  final List<EventData> _items = [];
  final GsheetsProvider sheetsProvider;
  final BuildContext context;

  factory EventsProvider(BuildContext context) {
    final sheetsProvider = Provider.of<GsheetsProvider>(context, listen: false);
    return EventsProvider._(
      sheetsProvider: sheetsProvider,
      context: context,
    );
  }

  EventsProvider._({
    required this.sheetsProvider,
    required this.context,
  }) {
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
    add(
        EventData(
          name: TextSpan(text: 'An event 1'),
          details: TextSpan(text: 'A description 1'),
          start: date.subtract(Duration(hours: 1)),
          end: date.add(Duration(hours: 18, minutes: 30)),
          backgroundColor: Colors.red,
          padding: EdgeInsets.all(0),
        )
    );
    add(
        EventData(
          name: TextSpan(text: 'An event 2a'),
          details: TextSpan(text: 'A description 2'),
          start: date.add(Duration(hours: 19)),
          end: date.add(Duration(hours: 22)),
          backgroundColor: Colors.indigo,
          padding: EdgeInsets.all(0),
        )
    );
    add(
        EventData(
          name: TextSpan(text: 'An event 2b'),
          details: TextSpan(text: 'A description 2'),
          start: date.add(Duration(hours: 19)),
          end: date.add(Duration(hours: 22)),
          backgroundColor: Colors.green,
          padding: EdgeInsets.all(0),
        )
    );
    add(
        EventData(
          name: TextSpan(text: 'An event 2c'),
          details: TextSpan(text: 'A description 2'),
          start: date.add(Duration(hours: 19)),
          end: date.add(Duration(hours: 22)),
          backgroundColor: Colors.purpleAccent,
          padding: EdgeInsets.all(0),
        )
    );
    add(
        EventData(
          name: TextSpan(text: 'An event 3'),
          details: TextSpan(text: 'A description 3'),
          start: date.add(Duration(hours: 23, minutes: 30)),
          end: date.add(Duration(hours: 25, minutes: 30)),
          backgroundColor: Colors.teal,
          padding: EdgeInsets.all(0),
        )
    );
    add(
        EventData(
          name: TextSpan(text: 'An event 4'),
          details: TextSpan(text: 'A description 4 with an extra long text'
              ' and a second line coming up.\n\nThis is the extra line then.'),
          start: date.add(Duration(hours: 20)),
          end: date.add(Duration(hours: 21)),
          backgroundColor: Colors.grey,
          padding: EdgeInsets.all(0),
        )
    );
    add(
        EventData(
          name: TextSpan(text: 'An event 5'),
          details: TextSpan(text: 'A description 5'),
          start: date.add(Duration(hours: 20)),
          end: date.add(Duration(hours: 21)),
          backgroundColor: Colors.blueGrey,
          padding: EdgeInsets.all(0),
        )
    );

    sheetsProvider.fetchData(context);
  }

  @override
  void add(EventData item) {
    _items.add(item);
    notifyListeners();
  }

  @override
  void clear() {
    _items.clear();
    notifyListeners();
  }
}