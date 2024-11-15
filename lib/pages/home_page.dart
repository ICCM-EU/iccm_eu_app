import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/event_list_tile.dart';
import 'package:iccm_eu_app/components/url_button.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/home_provider.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late List<EventData> _upcomingEvents = [];
  late DateTime? _nextEventTime = DateTime.now();
  Duration _remainingDuration = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    int seconds = 1;
    if (_nextEventTime!.difference(DateTime.now()).inDays > 0) {
      seconds = 60;
    }
    setState(() {
      if (_nextEventTime == null) {
        _remainingDuration = Duration.zero;
      } else {
        _remainingDuration = _nextEventTime!.difference(DateTime.now());
      }
    });

    _timer = Timer.periodic(Duration(seconds: seconds), (timer) {
      setState(() {
        if (_nextEventTime == null) {
          _remainingDuration = Duration.zero;
        } else {
          _remainingDuration = _nextEventTime!.difference(DateTime.now());
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EventsProvider eventsProvider = Provider.of<EventsProvider>(context);
    _nextEventTime = eventsProvider.nextStartTime();
    if (_remainingDuration <= Duration.zero) {
      _upcomingEvents = eventsProvider.filterPastEvents().take(5).toList();
    }

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Home'),
      // ),
      // backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Consumer<HomeProvider>(
              builder: (context, itemProvider, child) {
                final itemList = itemProvider.items();
                if (itemList.isEmpty) {
                  return const Center(
                      child: Text('Loading dynamic content...'),
                  );
                }
                final item = itemList.first; // Use the first item
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          return ClipRect(
                            child: Align(
                              alignment: Alignment.center,
                              child: ConstrainedBox( // Wrap SizedBox with ConstrainedBox
                                constraints: BoxConstraints(
                                  maxWidth: constraints.maxWidth * 0.9,
                                  maxHeight: constraints.maxHeight * 0.3,
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: item.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16.0),
                      RichText(
                        text: TextSpan(
                          text: item.name.text,
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          )
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      RichText(
                        text: item.details,
                      ),
                      UrlButton(
                        title: 'Now Page',
                        url: item.nowPageUrl,
                      ),
                      UrlButton(
                        title: 'Voting Page',
                        url: item.votingPageUrl,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final isFirstItem = index == 0;
                return Column( // Wrap the list item and Divider in a Column
                  children: [
                    if (isFirstItem) const Divider(),
                    Consumer<EventsProvider>(
                      builder: (context, itemList, child) {
                        return EventListTile(
                          item: _upcomingEvents[index],
                        );
                      },
                    ),
                  ],
                );
              },
              childCount: _upcomingEvents.length,
            ),
          ),
        ],
      ),
    );
  }
}