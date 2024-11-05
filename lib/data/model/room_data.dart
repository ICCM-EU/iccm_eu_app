import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/model/model_item.dart';

class RoomData extends ModelItem {
  @override
  final String imageUrl;
  @override
  final TextSpan name;
  @override
  final TextSpan details;

  RoomData._({
    required this.imageUrl,
    required this.name,
    required this.details,
    int? id,
  });

  factory RoomData.fromItemData(Map<String, dynamic> itemData) {
    return RoomData._(
      imageUrl: itemData['Photo 1'] ?? '',
      name: TextSpan(text: itemData['Name'] ?? ''),
      details: TextSpan(text: itemData['Description'] ?? ''),
    );
  }


  factory RoomData.fromJson(Map<String, dynamic> json) {
    return RoomData._(
      imageUrl: json['imageUrl'],
      name: TextSpan(text: json['name'] as String? ?? ''),
      details: TextSpan(text: json['details'] as String? ?? ''),
      id: int.tryParse(json['id'] ?? '-1'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'name': name.toPlainText(),
      'details': details.toPlainText(),
      'id': id.toString(),
    };
  }
}
