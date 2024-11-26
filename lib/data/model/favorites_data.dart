class FavoritesData {
  final String eventName;

  FavoritesData({
    required this.eventName,
  });

  FavoritesData._({
    required this.eventName,
  });

  factory FavoritesData.fromJson(Map<String, dynamic> json) {
    return FavoritesData._(
      eventName: json['eventIdentification'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventIdentification': eventName,
    };
  }
}
