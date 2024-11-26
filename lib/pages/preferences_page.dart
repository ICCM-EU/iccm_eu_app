import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/toggle_button.dart';
import 'package:iccm_eu_app/components/toggle_is_dark_mode.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Center(
      //     child: const Text('Preferences'),
      //   ),
      //   automaticallyImplyLeading: false,
      //   backgroundColor: Theme
      //       .of(context)
      //       .appBarTheme
      //       .backgroundColor,
      //   foregroundColor: Theme
      //       .of(context)
      //       .appBarTheme
      //       .foregroundColor,
      // ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Text(
            'Preferences',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text('Theme',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          ToggleIsDarkModeListTile(context: context),
          const Divider(),
          Text('Calendar Colors',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          ValueListenableBuilder<bool>(
            valueListenable: PreferencesProvider.calendarColorByRoomNotifier,
            builder: (context, builderValue, child) {
              return ToggleButtonListTile(
                value: builderValue,
                onChanged: (bool newValue) {
                  PreferencesProvider.setCalendarColorByRoom(newValue);
                },
                title: 'Calendar Color by Room',
                toggleTitle: 'Calendar Colors',
              );
            },
          ),
          // const Divider(),
          // const Text('Profile',
          //   style: TextStyle(
          //     fontSize: 18,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
        ],
      ),
    );
  }
}