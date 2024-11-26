import 'package:iccm_eu_app/data/model/model_item.dart';
import 'package:iccm_eu_app/utils/url_functions.dart';

class TravelData extends ModelItem {
  @override
  final String imageUrl;
  @override
  final String name;
  @override
  final String details;
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
      imageUrl: UrlFunctions.proxy(itemData['Photo 1']),
      name: itemData['Title'] ?? '',
      details: itemData['Location'] ?? '',
      locationUrl: itemData['Website'] ?? '',
      mapsUrl: itemData['Google Maps'] ?? '',
    );
  }

  factory TravelData.fromJson(Map<String, dynamic> json) {
    return TravelData._(
      imageUrl: json['imageUrl'],
      name: json['name'] as String? ?? '',
      details: json['details'] as String? ?? '',
      locationUrl: json['locationUrl'] as String? ?? '',
      mapsUrl: json['mapsUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'name': name.toString(),
      'details': details.toString(),
      'locationUrl': locationUrl,
      'mapsUrl': mapsUrl,
    };
  }
}
