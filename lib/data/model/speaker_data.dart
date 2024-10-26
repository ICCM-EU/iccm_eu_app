import 'package:flutter/material.dart';

class SpeakerData {
  final String imageUrl;
  final TextSpan name;
  final TextSpan details;

  factory SpeakerData.fromItemData(Map<String, dynamic> itemData) {
    return SpeakerData._(
      imageUrl: itemData['Photo'] ?? '',
      name: TextSpan(text: itemData['Name'] ?? ''),
      details: TextSpan(text: itemData['Bio'] ?? ''),
    );
  }

  SpeakerData._({
    required this.imageUrl,
    required this.name,
    required this.details,
  });
}
