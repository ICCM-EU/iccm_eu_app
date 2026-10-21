class TextFunctions {
  static String cutTextToWords({
    required String? text,
    required int wordCount,
  }) {
    if (text == null || text.isEmpty) {
      return '';
    }
    final words = text.split(RegExp(r'\s+')); // Split into words
    final limitedWords = words.take(wordCount).toList(); // Take first 50 words
    final limitedText = limitedWords.join(' '); // Join words back into a string

    if (words.length > wordCount) {
      // Add trailing ellipsis if text was cut
      return '$limitedText...';
    } else {
      return limitedText;
    }
  }
  static String normalizeListKey(String key, String sep) {
    String normalized = key.toLowerCase().trim();
    if (sep.isNotEmpty) {
      normalized = normalized.replaceAll(sep, '_');
    }
    return normalized.replaceAll(RegExp(r'[^a-zA-Z0-9\-_.~%]'), '_');
  }
}