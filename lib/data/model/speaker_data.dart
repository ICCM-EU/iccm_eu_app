import 'package:flutter/material.dart';

class SpeakerData {
  final String imageUrl;
  final TextSpan name;
  final TextSpan details;

  SpeakerData({
    required this.imageUrl,
    required this.name,
    required this.details,
  });
}
