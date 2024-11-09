import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/model/model_item.dart';

class TravelData extends ModelItem {
  @override
  final String imageUrl;
  @override
  final TextSpan name;
  @override
  final TextSpan details;
  final String? locationUrl;
  final String? mapsUrl;

  TravelData._({
    required this.imageUrl,
    required this.name,
    required this.details,
    this.locationUrl,
    this.mapsUrl,
  });

  factory TravelData.fromItemData(Map<String, dynamic> itemData) {
    return TravelData._(
      imageUrl: itemData['Photo 1'] ?? '',
      name: TextSpan(text: itemData['Title'] ?? ''),
      details: TextSpan(text: itemData['Location'] ?? ''),
      locationUrl: itemData['Website'] ?? '',
      mapsUrl: itemData['Google Maps'] ?? '',
    );
  }

  factory TravelData.fromJson(Map<String, dynamic> json) {
    return TravelData._(
      imageUrl: json['imageUrl'],
      name: TextSpan(text: json['name'] as String? ?? ''),
      details: TextSpan(text: json['details'] as String? ?? ''),
      locationUrl: json['locationUrl'] as String? ?? '',
      mapsUrl: json['mapsUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'name': name.toPlainText(),
      'details': details.toPlainText(),
      'locationUrl': locationUrl,
      'mapsUrl': mapsUrl,
    };
  }
}
