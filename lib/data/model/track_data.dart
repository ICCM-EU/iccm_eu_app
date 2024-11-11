import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/model/model_item.dart';
import 'package:iccm_eu_app/data/model/colors_data.dart';
import 'package:iccm_eu_app/utils/url_functions.dart';

class TrackData extends ModelItem {
  @override
  final String imageUrl;
  @override
  final TextSpan name;
  @override
  final TextSpan details;
  late ColorsData? colors;

  TrackData._({
    required this.imageUrl,
    required this.name,
    required this.details,
    this.colors,
  });

  factory TrackData.fromItemData(Map<String, dynamic> itemData) {
    return TrackData._(
      imageUrl: UrlFunctions.proxy(itemData['Photo']),
      name: TextSpan(text: itemData['Name'] ?? ''),
      details: TextSpan(text: itemData['Description'] ?? ''),
      colors: null,
    );
  }

  factory TrackData.fromJson(Map<String, dynamic> json) {
    return TrackData._(
      imageUrl: json['imageUrl'],
      name: TextSpan(text: json['name'] as String? ?? ''),
      details: TextSpan(text: json['details'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'name': name.toPlainText(),
      'details': details.toPlainText(),
    };
  }
}
