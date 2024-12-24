class FavoritesData {
  final String name;
  final String? details;
  final DateTime start;
  int? id;

  FavoritesData({
    required this.name,
    required this.start,
    this.details = '',
  });

  FavoritesData._({
    required this.name,
    required this.start,
    this.details = '',
  });

  factory FavoritesData.fromJson(Map<String, dynamic> json) {
    return FavoritesData._(
      name: json['name'] ?? '',
      details: json['details'] ?? '',
      start: DateTime.parse(json['start'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'details': details ?? '',
      'start': start.toIso8601String(),
    };
  }
}
