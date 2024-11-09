import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/room_list_tile.dart';
import 'package:iccm_eu_app/components/speaker_list_tile.dart';
import 'package:iccm_eu_app/components/track_list_tile.dart';
import 'package:iccm_eu_app/controls/nav_bar.dart';
import 'package:iccm_eu_app/data/dataProviders/rooms_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/speakers_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';
import 'package:iccm_eu_app/data/model/room_data.dart';
import 'package:iccm_eu_app/data/model/speaker_data.dart';
import 'package:iccm_eu_app/data/model/track_data.dart';
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
      item.track!.text.toString(),
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
      item.speaker!.text.toString(),
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
      item.room!.text.toString(),
    );
    if (roomItem != null) {
      roomItems.add(roomItem);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Details"),
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
                if (item.imageUrl!.startsWith("http"))
                  CachedNetworkImage(
                    imageUrl: item.imageUrl ?? '',
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      backgroundImage: imageProvider,
                      radius: 50,
                    ),
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  )
                else
                  const SizedBox.shrink(), // Display a placeholder widget
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                      text: item.title,
                  ),
                  // style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    text: item.description,
                  ),
                  // style: const TextStyle(fontSize: 18),
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
                    text: 'Facilitator: ${item.facilitator?.text}',
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