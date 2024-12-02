import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/room_list_tile.dart';
import 'package:iccm_eu_app/components/speaker_list_tile.dart';
import 'package:iccm_eu_app/components/track_list_tile.dart';
import 'package:iccm_eu_app/controls/nav_bar.dart';
import 'package:iccm_eu_app/data/dataProviders/favorites_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/rooms_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/speakers_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';
import 'package:iccm_eu_app/data/model/room_data.dart';
import 'package:iccm_eu_app/data/model/speaker_data.dart';
import 'package:iccm_eu_app/data/model/track_data.dart';
import 'package:iccm_eu_app/utils/date_functions.dart';
import 'package:provider/provider.dart';

class EventDetailsPage extends StatelessWidget {
  final EventData item;
  const EventDetailsPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    TracksProvider tracksProvider = Provider.of<TracksProvider>(
      context,
      listen: false,
    );
    List<TrackData> trackItems = [];
    TrackData? trackItem = tracksProvider.getDataByName(
      item.track!,
    );
    if (trackItem != null) {
      trackItems.add(trackItem);
    }

    SpeakersProvider speakersProvider = Provider.of<SpeakersProvider>(
      context,
      listen: false,
    );
    List<SpeakerData> speakerItems = [];
    SpeakerData? speakerItem = speakersProvider.getDataByName(
      item.speaker!,
    );
    if (speakerItem != null) {
      speakerItems.add(speakerItem);
    }

    RoomsProvider roomsProvider = Provider.of<RoomsProvider>(
      context,
      listen: false,
    );
    List<RoomData> roomItems = [];
    RoomData? roomItem = roomsProvider.getDataByName(
      item.room!,
    );
    if (roomItem != null) {
      roomItems.add(roomItem);
    }

    FavoritesProvider favProvider =
        Provider.of<FavoritesProvider>(context, listen: true);
    bool isFavorite = favProvider.isInFavorites(item.name);
    String imageUrl = item.imageUrl ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Details"),
        actions: const [
        ],
      ),
      body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (imageUrl.startsWith("http"))
                  CachedNetworkImage(
                    imageUrl: imageUrl,
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
                  const SizedBox.shrink(), // Display a placeholder widget
                const SizedBox(height: 16),
                Text(item.title,
                  style: Theme
                      .of(context)
                      .textTheme
                      .headlineSmall,
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleMedium,
                    children: [
                      if (item.notifyAfterBreak == true) TextSpan(
                        text: '📢 ',
                        style: Theme
                            .of(context)
                            .textTheme
                            .titleMedium,
                      ),
                      TextSpan(
                        text: DateFunctions().formatDate(
                            date: item.start,
                            format: 'EEE, dd.MM.yyyy, HH:mm'),
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 30,
                    color: Colors.red,
                  ),
                  color: Colors.red,
                  onPressed: () {
                    if (isFavorite) {
                      favProvider.rmEvent(item.name);
                    } else {
                      favProvider.addEvent(item.name);
                    }
                    isFavorite = !isFavorite;
                  },
                ),
                const SizedBox(height: 8),
                Text(item.description,
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium,
                ),
                const SizedBox(height: 8),
                if (speakerItems.isNotEmpty)
                  RichText(
                    text: TextSpan(
                      text: 'Speaker',
                    ),
                    // style: const TextStyle(fontSize: 18),
                  )
                else
                  const SizedBox.shrink(),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: speakerItems.length,
                  itemBuilder: (context, index) {
                    return SpeakerListTile(item: speakerItems[index]);
                  },
                ),
                const SizedBox(height: 8),
                if (roomItems.isNotEmpty)
                  RichText(
                    text: TextSpan(
                      text: 'Room',
                    ),
                    // style: const TextStyle(fontSize: 18),
                  )
                else
                  const SizedBox.shrink(),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: roomItems.length,
                  itemBuilder: (context, index) {
                    return RoomListTile(item: roomItems[index]);
                  },
                ),
                const SizedBox(height: 8),
                if (roomItems.isNotEmpty)
                  RichText(
                    text: TextSpan(
                      text: 'Track',
                    ),
                    // style: const TextStyle(fontSize: 18),
                  )
                else
                  const SizedBox.shrink(),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: trackItems.length,
                  itemBuilder: (context, index) {
                    return TrackListTile(item: trackItems[index]);
                  },
                ),
                const SizedBox(height: 8),
                item.facilitator != null ? RichText(
                  text: TextSpan(
                    text: 'Facilitator: ${item.facilitator}',
                    style: TextStyle(
                      fontSize: 8,
                    ),
                  ),
                  // style: const TextStyle(fontSize: 18),
                ) : const SizedBox.shrink(),
              ],
            ),
          ]
      ),
      bottomNavigationBar: const NavBar(),
    );
  }
}