import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/page_title.dart';
import 'package:iccm_eu_app/components/toggle_button.dart';
import 'package:iccm_eu_app/components/toggle_is_dark_mode.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: <Widget>[
        const PageTitle(title: 'Preferences Page'),
        const Divider(),
        const Text('Theme',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        ToggleIsDarkModeListTile(context: context),
        const Divider(),
        const Text('Calendar Colors',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
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
    );
  }
}