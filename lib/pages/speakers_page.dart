import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/speaker_list_tile.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/speakers_provider.dart';
import 'package:provider/provider.dart';

class SpeakersPage extends StatelessWidget {
  SpeakersPage({super.key}) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    PreferencesProvider.loadUseTestData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text('Speakers'),
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
          // ListView(
          //     shrinkWrap: true,
          //     // Important to prevent unbounded height issues
          //     physics: const NeverScrollableScrollPhysics(),
          //     // Disable scrolling for static list
          //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //     children: const <Widget>[
          //       PageTitle(title: 'Speakers'),
          //     ]
          // ),
          Expanded( // Use Expanded to allow ListView.builder to take available space
            child: Consumer<
                SpeakersProvider>( // Wrap ListView.builder with Consumer
              builder: (context, itemList, child) {
                return ListView.builder(
                  itemCount: itemList
                      .items()
                      .length,
                  itemBuilder: (context, index) {
                    return SpeakerListTile(item: itemList.items()[index]);
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
