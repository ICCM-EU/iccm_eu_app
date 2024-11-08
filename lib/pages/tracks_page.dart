import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/page_title.dart';
import 'package:iccm_eu_app/components/track_list_tile.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:provider/provider.dart';

class TracksPage extends StatelessWidget {
  const TracksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView(
            shrinkWrap: true, // Important to prevent unbounded height issues
            physics: const NeverScrollableScrollPhysics(), // Disable scrolling for static list
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: const <Widget>[
              PageTitle(title: 'Tracks'),
            ]
        ),
        Expanded( // Use Expanded to allow ListView.builder to take available space
          child: Consumer<TracksProvider>( // Wrap ListView.builder with Consumer
            builder: (context, itemList, child) {
              return ListView.builder(
                itemCount: itemList.items().length,
                itemBuilder: (context, index) {
                  return TrackListTile(item: itemList.items()[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}