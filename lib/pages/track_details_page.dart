import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/page_title.dart';

class TrackDetailsPage extends StatelessWidget {
  const TrackDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: const <Widget>[
          PageTitle(title: 'Track Details'),
        ]
    );
  }
}