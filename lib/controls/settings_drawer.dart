import 'package:flutter/material.dart';
import "package:provider/provider.dart" show Provider;

import 'package:iccm_eu_app/theme/theme_provider.dart';
//import 'package:iccm_eu_app/data/preferences_provider.dart';


class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({super.key});

  @override
  State<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  @override
  Widget build(BuildContext context) {
    //final PrefsProvider prefsProvider = Provider.of<PrefsProvider>(context);
    return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green[400]!,
              ),
              child: Wrap(
                children: <Widget>[
                  const Text("Settings",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SwitchListTile(
                    activeColor: Colors.black,
                    activeTrackColor: Colors.grey[800]!.withOpacity(0.4),
                    inactiveThumbColor: Colors.grey[300]!.withOpacity(0.4),
                    inactiveTrackColor: Colors.grey[700]!.withOpacity(0.4),
                    splashRadius: 20,
                    title: const Text('Dark Mode'),
                    secondary: const Icon(Icons.lightbulb_outline),
                    value: Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
                    onChanged: (value) => setState(() {
                      Provider.of<ThemeProvider>(context, listen: false).saveTheme(value);
                    }),
                  ),
                ],
              ),
            ),
            //Switch.adaptive(

            const ListTile(
              leading: Icon(Icons.question_mark),
              title: Text("Profile"),
              //onTap: () => print("Tapped"),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.question_mark),
              title: Text("About"),
              //onTap: () => AboutDialog(
              //  applicationName: Text("ICCM Europe App"),
              //  applicationVersion: Text("2025"),
              //  applicationLegalese: Text("Made by participants."),
              // ),
            ),
          ],
        )
    );
  }
}
