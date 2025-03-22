class CommunicationData {
  final String leading;
  final String title;
  final String url;

  CommunicationData._({
    required this.leading,
    required this.title,
    required this.url,
  });

  factory CommunicationData.fromItemData(Map<String, dynamic> itemData) {
    return CommunicationData._(
      leading: itemData['Leading'] ?? '',
      title: itemData['Title'] ?? '',
      url: itemData['URL'] ?? '',
    );
  }

  factory CommunicationData.fromJson(Map<String, dynamic> json) {
    return CommunicationData._(
      leading: json['leading'] as String? ?? '',
      title: json['title'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leading': leading.toString(),
      'title': title.toString(),
      'url': url.toString(),
    };
  }
}
