import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/room_list_tile.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/rooms_provider.dart';
import 'package:provider/provider.dart';

class RoomsPage extends StatelessWidget {
  RoomsPage({super.key}) {
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
            child: const Text('Rooms'),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Theme
              .of(context)
              .appBarTheme
              .backgroundColor,
          foregroundColor: Theme
              .of(context)
              .appBarTheme
              .foregroundColor
      ),
      body: PrimaryScrollController(
        controller: ScrollController(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Use Expanded to allow ListView.builder to take available space
              Expanded(
                child: Consumer<
                    RoomsProvider>( // Wrap ListView.builder with Consumer
                  builder: (context, itemList, child) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: itemList
                          .items()
                          .length,
                      itemBuilder: (context, index) {
                        return RoomListTile(item: itemList.items()[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}