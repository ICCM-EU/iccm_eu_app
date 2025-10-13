import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/event_list_tile.dart';
import 'package:iccm_eu_app/data/appProviders/next_event_provider.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';
import 'package:provider/provider.dart';

class EventList extends StatefulWidget {
  bool get futureEvents => _futureEvents;
  final bool _futureEvents;

  const EventList({
    required bool futureEvents,
    super.key,
  }) : _futureEvents = futureEvents;

  @override
  EventListState createState() => EventListState();
}

class EventListState extends State<EventList> {
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    PreferencesProvider.loadFutureEvents();
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScrollController(
      controller: ScrollController(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Use Expanded to allow ListView.builder to take available space
            Expanded(
              child: ValueListenableBuilder<bool>(
                  valueListenable: PreferencesProvider.futureEventsNotifier,
                  builder: (context, builderValue, child) {
                    return Consumer<
                        EventsProvider>(
                      builder: (context, itemList, child) {
                        List<EventData> items;
                        if (builderValue) {
                          items = itemList.filterPastEvents();
                        } else {
                          items = itemList.items();
                        }
                        return ValueListenableBuilder<DateTime?>(
                          valueListenable: NextEventNotifier.nextEventNotifier,
                          builder: (context, nextEventTime, _) {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                return EventListTile(item: items[index]);
                              },
                            );
                          },
                        );
                      },
                    );
                  }
              ),
            ),
          ],
        ),
      ),
    );
  }
}