import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
        //mainAxisAlignment: MainAxisAlignment.center, // Vertically center
        children: [
          Text(
            'About',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'This app is designed to guide visitors through the ICCM Europe '
                'conference and to offer some infrastructure to run the '
                'conference.',
            textAlign: TextAlign.center, // Center align text
          ),
          SizedBox(height: 32),
          Text(
            'Copyright © 2024 ICCM Europe',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Authors: Hans-Jürgen Tappe',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 32),
          AboutListTile( // Use AboutListTile for Flutter info
            icon: Icon(Icons.label),
            applicationIcon: Icon(Icons.flutter_dash),
            applicationName: 'ICCM Europe Licenses',
            applicationVersion: '0.1.0',
            applicationLegalese: 'Licensed under MIT',
            aboutBoxChildren: [
              // Add additional custom information here
            ],
          ),
        ],
      ),
    );
  }
}