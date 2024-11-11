import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/model/model_item.dart';
import 'package:iccm_eu_app/utils/url_functions.dart';

class TravelDirectionsData extends ModelItem {
  @override
  final String imageUrl;
  @override
  final TextSpan name;
  @override
  final TextSpan details;
  final String? emoji;

  TravelDirectionsData._({
    required this.imageUrl,
    required this.name,
    required this.details,
    this.emoji,
  });

  factory TravelDirectionsData.fromItemData(Map<String, dynamic> itemData) {
    return TravelDirectionsData._(
      imageUrl: UrlFunctions.proxy(itemData['Photo']),
      name: TextSpan(text: itemData['Name'] ?? ''),
      details: TextSpan(text: itemData['Description'] ?? ''),
      emoji: itemData['Emoji'] ?? '',
    );
  }

  factory TravelDirectionsData.fromJson(Map<String, dynamic> json) {
    return TravelDirectionsData._(
      imageUrl: json['imageUrl'],
      name: TextSpan(text: json['name'] as String? ?? ''),
      details: TextSpan(text: json['details'] as String? ?? ''),
      emoji: json['emoji'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'name': name.toPlainText(),
      'details': details.toPlainText(),
      'emoji': emoji,
    };
  }
}
