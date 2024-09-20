import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/toggle_is_dark_mode.dart';

class SettingsDrawer extends StatelessWidget {
  final Function(int) setPageIndex;

  const SettingsDrawer({
    super.key,
    required this.setPageIndex,
  });

  @override
  Widget build(BuildContext context) {
    //final PrefsProvider prefsProvider = Provider.of<PrefsProvider>(context);
    return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ToggleIsDarkModeListTile(context: context),
            const Divider(),
            ListTile(
              leading: Icon(Icons.question_mark),
              title: Text("Preferences"),
              onTap: ()  {
                //Navigator.pop(context);
                Scaffold.of(context).closeDrawer();
                setPageIndex(5);
              },
            ),
            const Divider(),
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
