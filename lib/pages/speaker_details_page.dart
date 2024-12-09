import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/event_list_tile.dart';
import 'package:iccm_eu_app/components/url_button.dart';
import 'package:iccm_eu_app/controls/nav_bar.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';
import 'package:iccm_eu_app/data/model/speaker_data.dart';
import 'package:provider/provider.dart';

class SpeakerDetailsPage extends StatelessWidget {
  final SpeakerData item;
  const SpeakerDetailsPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    EventsProvider eventsProvider = Provider.of<EventsProvider>(
      context,
      listen: false,
    );
    List<EventData> listItems = eventsProvider.eventsBySpeaker(
      name: item.name,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text("Speaker Details"),
        actions: const [
        ],
      ),
      body:
      ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (item.imageUrl.startsWith("http"))
                  CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    imageBuilder: (context, imageProvider) =>
                        CircleAvatar(
                          backgroundImage: imageProvider,
                          radius: 50,
                        ),
                    placeholder: (context,
                        url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.error),
                  )
                else
                  const SizedBox.shrink(),
                const SizedBox(height: 16),
                Text(item.name,
                  style: Theme
                      .of(context)
                      .textTheme
                      .headlineSmall,
                ),
                if (item.company != null && item.company!.isNotEmpty)
                  Text(item.company ?? '',
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyMedium,
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(item.details,
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium,
                ),
                if (item.weblink != null &&
                    item.weblink!.startsWith('https://'))
                  UrlButton(
                    title: 'Web Link',
                    url: item.weblink,
                  )
                else
                  SizedBox.shrink(),
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