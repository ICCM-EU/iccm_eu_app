class TextFunctions {
  static String cutTextToWords({
    required String? text,
    required int wordCount,
  }) {
    if (text!.isEmpty) {
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
}