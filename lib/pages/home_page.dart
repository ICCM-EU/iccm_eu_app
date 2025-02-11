import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/event_list_tile.dart';
import 'package:iccm_eu_app/components/url_button.dart';
import 'package:iccm_eu_app/data/appProviders/next_event_provider.dart';
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
    final EventsProvider eventsProvider =
    Provider.of<EventsProvider>(context, listen: false);
    _nextEventTime = eventsProvider.nextStartTime();
    if (_remainingDuration <= Duration.zero) {
      _upcomingEvents = eventsProvider.filterPastEvents(withCurrent: false).
      take(5).toList();
    }

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Home'),
      // ),
      // backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery
                .of(context)
                .size
                .height * 0.3, // 30% of screen height
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Consumer<HomeProvider>(
                      builder: (context, itemProvider, child) {
                        final itemList = itemProvider.items();
                        if (itemList.isEmpty) {
                          return const Center(
                            child: Text('Loading dynamic content...'),
                          );
                        }
                        final item = itemList.first;
                        return CachedNetworkImage(
                          imageUrl: item.imageUrl,
                          fit: BoxFit.cover,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          placeholder: (context,
                              url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                          colorBlendMode: BlendMode.srcIn,
                        );
                      },
                    );
                  }
              ),
            ),
          ),
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
                      const SizedBox(height: 16.0),
                      Text(
                        item.name,
                        style: Theme
                            .of(context)
                            .textTheme
                            .titleLarge,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        item.details,
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyMedium,
                      ),
                      if (item.nowPageUrl != null &&
                          item.nowPageUrl!.startsWith('https://'))
                        UrlButton(
                          title: 'Now Page',
                          url: item.nowPageUrl,
                        )
                      else
                        SizedBox.shrink(),
                      if (item.votingPageUrl != null &&
                          item.votingPageUrl!.startsWith('https://'))
                        UrlButton(
                          title: 'Voting Page',
                          url: item.votingPageUrl,
                        )
                      else
                        SizedBox.shrink(),
                      if (item.bofPageUrl != null &&
                          item.bofPageUrl!.startsWith('https://'))
                        UrlButton(
                          title: 'BOF Page',
                          url: item.bofPageUrl,
                        )
                      else
                        SizedBox.shrink(),                    ],
                  ),
                );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final isFirstItem = index == 0;
              return ValueListenableBuilder<DateTime?>(
                valueListenable: NextEventNotifier.nextEventNotifier,
                builder: (context, nextEventTime, _) {
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