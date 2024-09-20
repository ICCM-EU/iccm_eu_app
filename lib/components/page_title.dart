import 'package:flutter/material.dart';

class PageTitle extends StatelessWidget {
  final String title;

  const PageTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child:Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(title,
            style: const TextStyle(fontSize: 30)),
        )
      )
    );
  }
}