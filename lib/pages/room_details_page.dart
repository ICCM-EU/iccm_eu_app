import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/page_title.dart';

class RoomDetailsPage extends StatelessWidget {
  const RoomDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: const <Widget>[
          PageTitle(title: 'Room Detail'),
        ]
    );
  }
}