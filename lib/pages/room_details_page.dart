import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/event_list_tile.dart';
import 'package:iccm_eu_app/components/image_carousel.dart';
import 'package:iccm_eu_app/controls/nav_bar.dart';
import 'package:iccm_eu_app/data/appProviders/next_event_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/model/room_data.dart';
import 'package:provider/provider.dart';

class RoomDetailsPage extends StatelessWidget {
  final RoomData item;
  const RoomDetailsPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = [];
    if (item.imageUrl.startsWith('https://')) {
      imageUrls.add(item.imageUrl);
    }
    if (item.mapImageUrl != null &&
        item.mapImageUrl!.startsWith('https://')) {
      imageUrls.add(item.mapImageUrl ?? '');
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Room Details"),
        actions: const [
        ],
      ),
      body:
      ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImageCarousel(imageUrls: imageUrls),
                const SizedBox(height: 16),
                Text(item.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(item.details,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Consumer<EventsProvider>(
                  builder: (context, itemProvider, child) {
                    final itemList = itemProvider.eventsByRoom(
                        name: item.name,
                    );
                    if (itemList.isEmpty) {
                      return SizedBox.shrink();
                    } else {
                      return ValueListenableBuilder<DateTime?>(
                        valueListenable: NextEventNotifier.nextEventNotifier,
                        builder: (context, nextEventTime, _) {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: itemList.length,
                            itemBuilder: (context, index) {
                              return EventListTile(item: itemList[index]);
                            },
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ]
      ),
      bottomNavigationBar: const NavBar(),
    );
  }
}