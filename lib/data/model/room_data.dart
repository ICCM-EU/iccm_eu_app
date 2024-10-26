import 'package:flutter/material.dart';

class RoomData {
  final String imageUrl;
  final TextSpan name;
  final TextSpan details;

  factory RoomData.fromItemData(Map<String, dynamic> itemData) {
    return RoomData._(
      imageUrl: itemData['Photo 1'] ?? '',
      name: TextSpan(text: itemData['Name'] ?? ''),
      details: TextSpan(text: itemData['Description'] ?? ''),
    );
  }

  RoomData._({
    required this.imageUrl,
    required this.name,
    required this.details,
  });
}
