import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/url_button.dart';
import 'package:iccm_eu_app/data/dataProviders/home_provider.dart';
import 'package:provider/provider.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Center(
      //     child: const Text('About'),
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Align children to the left
          //mainAxisAlignment: MainAxisAlignment.center, // Vertically center
          children: [
            Text(
              'About',
              style: Theme.of(context).textTheme.titleLarge,
              // textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'This app is designed to guide visitors through the ICCM Europe '
                  'conference and to offer some infrastructure to run the '
                  'conference.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.justify, // Center align text
            ),
            SizedBox(height: 32),
            Consumer<HomeProvider>(
              builder: (context, itemProvider, child) {
                final itemList = itemProvider.items();
                if (itemList.isEmpty) {
                  return const Center(
                    child: Text('Loading dynamic content...'),
                  );
                }
                final item = itemList.first; // Use the first item
                String shareUrl = item.appShareUrl ?? '';
                return (shareUrl.startsWith('https://')) ?
                UrlButton(
                  title: 'Development URL',
                  url: shareUrl,
                ) : SizedBox.shrink();
              },
            ),
            SizedBox(height: 32),
            Text(
              'Copyright © 2024 ICCM Europe',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 8),
            Text(
              'Authors: Hans-Jürgen Tappe',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 32),
            AboutListTile( // Use AboutListTile for Flutter info
              icon: Icon(Icons.label),
              applicationIcon: Icon(Icons.flutter_dash),
              applicationName: 'ICCM Europe Licenses',
              applicationVersion: '2025-eu.0',
              applicationLegalese: 'Licensed under GPLv3',
              aboutBoxChildren: [
                // Add additional custom information here
              ],
            ),
          ],
        ),
      ),
    );
  }
}