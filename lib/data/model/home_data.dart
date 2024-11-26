import 'package:iccm_eu_app/data/model/model_item.dart';
import 'package:iccm_eu_app/utils/url_functions.dart';

class HomeData extends ModelItem {
  @override
  final String imageUrl;
  @override
  final String name;
  @override
  final String details;
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
      imageUrl: UrlFunctions.proxy(itemData['Photo 1']),
      name: itemData['Title'] ?? '',
      details: itemData['Description'] ?? '',
      nowPageUrl: itemData['Now Page Link'] ?? '',
      votingPageUrl: itemData['Survey Link'] ?? '',
    );
  }

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData._(
      imageUrl: json['imageUrl'],
      name: json['name'] as String? ?? '',
      details: json['details'] as String? ?? '',
      nowPageUrl: json['nowPageUrl'],
      votingPageUrl: json['votingPageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'name': name.toString(),
      'details': details.toString(),
      'nowPageUrl': nowPageUrl,
      'votingPageUrl': votingPageUrl,
    };
  }
}
