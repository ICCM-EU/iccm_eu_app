import 'package:flutter/material.dart';

class TrackData {
  final String imageUrl;
  final TextSpan name;
  final TextSpan details;

  factory TrackData.fromItemData(Map<String, dynamic> itemData) {
    return TrackData._(
      imageUrl: itemData['Photo'] ?? '',
      name: TextSpan(text: itemData['Name'] ?? ''),
      details: TextSpan(text: itemData['Description'] ?? ''),
    );
  }

  TrackData._({
    required this.imageUrl,
    required this.name,
    required this.details,
  });
}
