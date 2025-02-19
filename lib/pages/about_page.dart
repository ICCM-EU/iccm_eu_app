import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/url_button.dart';
import 'package:iccm_eu_app/data/dataProviders/home_provider.dart';
import 'package:provider/provider.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Consumer<HomeProvider>(
          builder: (context, itemProvider, child) {
            final itemList = itemProvider.items();
            if (itemList.isEmpty) {
              return const Center(
                child: Text('Loading dynamic content...'),
              );
            }
            final item = itemList.first; // Use the first item
            String devUrl = item.devShareUrl ?? '';
            String appUrl = item.appShareUrl ?? '';
            DateTime now = DateTime.now();
            return Padding(
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
                  (devUrl.startsWith('https://')) ? UrlButton(
                    title: 'Development URL',
                    url: devUrl,
                  ) : SizedBox.shrink(),
                  SizedBox(height: 32),
                  const Divider(),
                  if (kIsWeb) ...[
                    Text(
                      'Special Web URLs',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    (appUrl.startsWith('https://')) ? UrlButton(
                      title: 'Events List - Direct URL',
                      url: '$appUrl?page=events',
                    ) : SizedBox.shrink(),
                    (appUrl.startsWith('https://')) ? UrlButton(
                      title: 'Countdown - Direct URL',
                      url: '$appUrl?page=countdown',
                    ) : SizedBox.shrink(),
                    SizedBox(height: 32) ,
                    const Divider(),
                  ],
                  Text(
                    'Copyright © 2024-${now.year.toString()} ICCM Europe',
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
                    applicationLegalese: 'Licensed under MIT license',
                    aboutBoxChildren: [
                      // Add additional custom information here
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      )
    );
  }
}