import 'package:iccm_eu_app/data/model/colors_data.dart';
import 'package:iccm_eu_app/data/model/model_item.dart';
import 'package:iccm_eu_app/utils/url_functions.dart';

class RoomData extends ModelItem {
  @override
  final String imageUrl;
  @override
  final String name;
  @override
  final String details;
  String? mapImageUrl;
  late ColorsData? colors;

  RoomData({
    required this.imageUrl,
    required this.name,
    required this.details,
    this.mapImageUrl,
    this.colors,
  });

  RoomData._({
    required this.imageUrl,
    required this.name,
    required this.details,
    this.mapImageUrl,
    this.colors,
  });

  factory RoomData.fromItemData(Map<String, dynamic> itemData) {
    return RoomData._(
      imageUrl: UrlFunctions.proxy(itemData['Photo 1']),
      name: itemData['Name'] ?? '',
      details: itemData['Description'] ?? '',
      mapImageUrl: UrlFunctions.proxy(itemData['Photo 2']),
      colors: null,
    );
  }


  factory RoomData.fromJson(Map<String, dynamic> json) {
    return RoomData._(
      imageUrl: json['imageUrl'],
      name: json['name'] as String? ?? '',
      details: json['details'] as String? ?? '',
      mapImageUrl: json['mapImageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'name': name.toString(),
      'details': details.toString(),
      'mapImageUrl': mapImageUrl.toString()
    };
  }
}
