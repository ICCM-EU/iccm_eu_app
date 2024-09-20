import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/toggle_is_dark_mode.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: <Widget>[
        const Center(
          child: const Text(
              'Preferences Page', style: const TextStyle(fontSize: 30)),
        ),
        const Divider(),
        const Text('Theme',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        ToggleIsDarkModeListTile(context: context),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.question_mark),
          title: Text("Profile"),
          //onTap: () => print("Tapped"),
        ),
      ],
    );
  }
}