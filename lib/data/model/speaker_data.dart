import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/model/model_item.dart';
import 'package:iccm_eu_app/utils/url_functions.dart';

class SpeakerData extends ModelItem {
  @override
  final String imageUrl;
  @override
  final TextSpan name;
  @override
  final TextSpan details;

  SpeakerData._({
    required this.imageUrl,
    required this.name,
    required this.details,
  });

  factory SpeakerData.fromItemData(Map<String, dynamic> itemData) {
    return SpeakerData._(
      imageUrl: UrlFunctions.proxy(itemData['Photo']),
      name: TextSpan(text: itemData['Name'] ?? ''),
      details: TextSpan(text: itemData['Bio'] ?? ''),
    );
  }

  factory SpeakerData.fromJson(Map<String, dynamic> json) {
    return SpeakerData._(
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
