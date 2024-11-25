import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/event_list_tile.dart';
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
      name: item.name.text.toString(),
    );
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
                if (item.imageUrl.startsWith("http"))
                  CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      backgroundImage: imageProvider,
                      radius: 50,
                    ),
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  )
                else
                  const SizedBox.shrink(),
                const SizedBox(height: 16),
                Text(item.name.text!,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(item.details.text!,
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