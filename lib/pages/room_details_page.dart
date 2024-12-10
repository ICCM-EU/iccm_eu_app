import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/event_list_tile.dart';
import 'package:iccm_eu_app/components/image_carousel.dart';
import 'package:iccm_eu_app/controls/nav_bar.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';
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
    EventsProvider eventsProvider = Provider.of<EventsProvider>(
      context,
      listen: false,
    );
    List<EventData> listItems = eventsProvider.eventsByRoom(
      name: item.name,
    );
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
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listItems.length,
                  itemBuilder: (context, index) {
                    return EventListTile(item: listItems[index]);
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