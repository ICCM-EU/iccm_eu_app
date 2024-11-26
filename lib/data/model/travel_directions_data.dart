import 'package:iccm_eu_app/data/model/model_item.dart';
import 'package:iccm_eu_app/utils/url_functions.dart';

class TravelDirectionsData extends ModelItem {
  @override
  final String imageUrl;
  @override
  final String name;
  @override
  final String details;
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
      name: itemData['Name'] ?? '',
      details: itemData['Description'] ?? '',
      emoji: itemData['Emoji'] ?? '',
    );
  }

  factory TravelDirectionsData.fromJson(Map<String, dynamic> json) {
    return TravelDirectionsData._(
      imageUrl: json['imageUrl'],
      name: json['name'] as String? ?? '',
      details: json['details'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'name': name.toString(),
      'details': details.toString(),
      'emoji': emoji,
    };
  }
}
