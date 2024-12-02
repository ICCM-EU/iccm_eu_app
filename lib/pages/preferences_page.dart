import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/toggle_button.dart';
import 'package:iccm_eu_app/components/toggle_is_dark_mode.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/error_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:provider/provider.dart';

class PreferencesPage extends StatelessWidget {
  PreferencesPage({super.key}) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    PreferencesProvider.loadCalendarColorByRoom();
    PreferencesProvider.loadUseTestData();
  }

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
            style: Theme
                .of(context)
                .textTheme
                .titleLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text('Theme',
            style: Theme
                .of(context)
                .textTheme
                .titleLarge,
          ),
          ToggleIsDarkModeListTile(context: context),
          const Divider(),
          Text('Calendar Colors',
            style: Theme
                .of(context)
                .textTheme
                .titleLarge,
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
          if (kDebugMode)
            const Divider()
          else
            const SizedBox.shrink(),
          if (kDebugMode)
            Text('Test Data',
              style: Theme
                  .of(context)
                  .textTheme
                  .titleLarge,
            )
          else
            const SizedBox.shrink(),
          if (kDebugMode)
            ValueListenableBuilder<bool>(
              valueListenable: PreferencesProvider.useTestDataNotifier,
              builder: (context, builderValue, child) {
                return ToggleButtonListTile(
                  value: builderValue,
                  onChanged: (bool newValue) {
                    PreferencesProvider.setUseTestData(newValue);
                    Provider.of<GsheetsProvider>(context, listen: false).fetchData(
                      errorProvider: Provider.of<ErrorProvider>(context, listen: false),
                      force: true,
                    );
                  },
                  title: 'Use Test Data',
                  toggleTitle: 'Test Data',
                );
              },
            )
          else
            const SizedBox.shrink(),
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