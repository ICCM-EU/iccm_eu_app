import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/utils/text_functions.dart';

void main() {
  group('TextFunctions.normalizeListKey Tests', () {
    test('normalizes basic topic names to lower case with underscores', () {
      expect(TextFunctions.normalizeListKey('Announcements', '|'), equals('announcements'));
      expect(TextFunctions.normalizeListKey('Test Topic', '|'), equals('test_topic'));
    });

    test('replaces separator character with underscore', () {
      expect(TextFunctions.normalizeListKey('announcements|test', '|'), equals('announcements_test'));
      expect(TextFunctions.normalizeListKey('a|b|c', '|'), equals('a_b_c'));
    });

    test('preserves allowed FCM topic characters: letters, numbers, hyphen, underscore, dot, tilde, percent', () {
      expect(TextFunctions.normalizeListKey('topic-name.v1_2026~test%100', '|'), equals('topic-name.v1_2026~test%100'));
    });

    test('replaces invalid characters for FCM topic names and PWA storage keys with underscore', () {
      expect(TextFunctions.normalizeListKey('Track #1: Heavy Metal!', '|'), equals('track__1__heavy_metal_'));
      expect(TextFunctions.normalizeListKey('Topic @ Hall A (Q&A)', '|'), equals('topic___hall_a__q_a_'));
      expect(TextFunctions.normalizeListKey('münchen/station', '|'), equals('m_nchen_station'));
      expect(TextFunctions.normalizeListKey('key=value;foo:bar', '|'), equals('key_value_foo_bar'));
    });

    test('handles empty and whitespace-only strings gracefully', () {
      expect(TextFunctions.normalizeListKey('', '|'), equals(''));
      expect(TextFunctions.normalizeListKey('   ', '|'), equals(''));
    });

    test('handles empty separator without crashing or adding extra underscores', () {
      expect(TextFunctions.normalizeListKey('Test Topic', ''), equals('test_topic'));
    });
  });

  group('TextFunctions.cutTextToWords Tests', () {
    test('returns empty string when text is null or empty', () {
      expect(TextFunctions.cutTextToWords(text: null, wordCount: 5), equals(''));
      expect(TextFunctions.cutTextToWords(text: '', wordCount: 5), equals(''));
    });

    test('cuts text to specified word count and adds ellipsis when exceeded', () {
      const text = 'One two three four five six seven';
      expect(TextFunctions.cutTextToWords(text: text, wordCount: 3), equals('One two three...'));
    });

    test('returns original text without ellipsis when word count is within limit', () {
      const text = 'One two three';
      expect(TextFunctions.cutTextToWords(text: text, wordCount: 5), equals('One two three'));
    });

    test('returns original text without ellipsis when word count matches total word count', () {
      const text = 'One two three';
      expect(TextFunctions.cutTextToWords(text: text, wordCount: 3), equals('One two three'));
    });

    test('handles multiple whitespaces, tabs, and newlines correctly', () {
      const text = 'Hello \t world \n from \r\n Flutter  app';
      expect(TextFunctions.cutTextToWords(text: text, wordCount: 3), equals('Hello world from...'));
    });

    test('handles word count of 0', () {
      const text = 'One two three';
      expect(TextFunctions.cutTextToWords(text: text, wordCount: 0), equals('...'));
    });

    test('handles single word input', () {
      expect(TextFunctions.cutTextToWords(text: 'Hello', wordCount: 1), equals('Hello'));
      expect(TextFunctions.cutTextToWords(text: 'Hello', wordCount: 0), equals('...'));
    });
  });
}
