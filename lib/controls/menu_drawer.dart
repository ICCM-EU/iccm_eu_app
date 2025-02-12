import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/page_title.dart';
import 'package:iccm_eu_app/pages/countdown_page.dart';

import 'nav_bar.dart';

class MenuDrawer extends StatelessWidget {
  final Function(int) setPageIndex;

  const MenuDrawer({
    super.key,
    required this.setPageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            const PageTitle(title: "More Options"),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Preferences"),
              onTap: () {
                Scaffold.of(context).closeDrawer();
                setPageIndex(PageList.preferences.index);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.directions_train),
              title: const Text("Travel Information"),
              onTap: () {
                Scaffold.of(context).closeDrawer();
                setPageIndex(PageList.travelInformation.index);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.hourglass_bottom),
              title: const Text("Countdown Timer"),
              onTap: () {
                Scaffold.of(context).closeDrawer();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CountdownPage(),
                    fullscreenDialog: true, // Open fullscreen
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("About"),
              onTap: () {
                Scaffold.of(context).closeDrawer();
                setPageIndex(PageList.about.index);
              },            ),
          ],
        )
    );
  }
}
