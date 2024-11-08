import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/event_list_tile.dart';
import 'package:iccm_eu_app/controls/nav_bar.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';
import 'package:iccm_eu_app/data/model/track_data.dart';
import 'package:provider/provider.dart';


class TrackDetailsPage extends StatelessWidget {
  final TrackData item;
  const TrackDetailsPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    EventsProvider eventsProvider = Provider.of<EventsProvider>(
        context,
        listen: false,
    );
    List<EventData> listItems = eventsProvider.eventsByTrack(
        name: item.name.text.toString(),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Details"),
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
                RichText(
                  text: item.name,
                  // style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: item.details,
                  // style: const TextStyle(fontSize: 18),
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