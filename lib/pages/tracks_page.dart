import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/track_list_tile.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:provider/provider.dart';

class TracksPage extends StatelessWidget {
  TracksPage({super.key}) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    PreferencesProvider.loadUseTestData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Tracks'),
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
      body: Consumer<TracksProvider>(
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
    );
  }
}
