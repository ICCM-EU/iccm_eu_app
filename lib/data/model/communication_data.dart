class CommunicationData {
  final String title;
  final String url;

  CommunicationData._({
    required this.title,
    required this.url,
  });

  factory CommunicationData.fromItemData(Map<String, dynamic> itemData) {
    return CommunicationData._(
      title: itemData['Title'] ?? '',
      url: itemData['URL'] ?? '',
    );
  }

  factory CommunicationData.fromJson(Map<String, dynamic> json) {
    return CommunicationData._(
      title: json['title'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title.toString(),
    };
  }
}
