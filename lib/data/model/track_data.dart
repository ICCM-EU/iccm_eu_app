import 'package:flutter/material.dart';

class TrackData {
  final String imageUrl;
  final TextSpan name;
  final TextSpan details;

  TrackData({
    required this.imageUrl,
    required this.name,
    required this.details,
  });
}
