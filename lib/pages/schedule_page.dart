import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/page_title.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return  ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: const <Widget>[
          PageTitle(title: 'Schedule'),
        ]
    );
  }
}