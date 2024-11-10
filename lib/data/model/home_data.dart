import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/model/model_item.dart';

class HomeData extends ModelItem {
  @override
  final String imageUrl;
  @override
  final TextSpan name;
  @override
  final TextSpan details;
  final String? nowPageUrl;
  final String? votingPageUrl;

  HomeData._({
    required this.imageUrl,
    required this.name,
    required this.details,
    this.nowPageUrl,
    this.votingPageUrl,
  });

  factory HomeData.fromItemData(Map<String, dynamic> itemData) {
    return HomeData._(
      imageUrl: itemData['Photo 1'] ?? '',
      name: TextSpan(text: itemData['Title'] ?? ''),
      details: TextSpan(text: itemData['Description'] ?? ''),
      nowPageUrl: itemData['Now Page Link'] ?? '',
      votingPageUrl: itemData['Survey Link'] ?? '',
    );
  }

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData._(
      imageUrl: json['imageUrl'],
      name: TextSpan(text: json['name'] as String? ?? ''),
      details: TextSpan(text: json['details'] as String? ?? ''),
      nowPageUrl: json['nowPageUrl'],
      votingPageUrl: json['votingPageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'name': name.toPlainText(),
      'details': details.toPlainText(),
      'nowPageUrl': nowPageUrl,
      'votingPageUrl': votingPageUrl,
    };
  }
}
