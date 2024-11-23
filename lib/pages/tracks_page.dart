import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/track_list_tile.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:provider/provider.dart';

class TracksPage extends StatelessWidget {
  const TracksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text('Tracks'),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Theme
            .of(context)
            .appBarTheme
            .backgroundColor,
        foregroundColor: Theme
            .of(context)
            .appBarTheme
            .foregroundColor,
      ),
      body: Column(
        children: [
          Expanded( // Use Expanded to allow ListView.builder to take available space
            child: Consumer<
                TracksProvider>( // Wrap ListView.builder with Consumer
              builder: (context, itemList, child) {
                return ListView.builder(
                  itemCount: itemList
                      .items()
                      .length,
                  itemBuilder: (context, index) {
                    return TrackListTile(item: itemList.items()[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}