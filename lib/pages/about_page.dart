import 'package:flutter/material.dart';

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