import 'dart:ui';
import 'package:iccm_eu_app/data/model/colors_data.dart';

/// Dictionary providing modernized, accessible color pairs for calendar items
/// (rooms, categories/tracks) in both light and dark calendar views.
class ItemColorsDictionary {
  final Map<String, ColorsData> colors = {
    'red': ColorsData(
      primary: const Color(0xFFFFDAD6),
      secondary: const Color(0xFF5D1010),
    ),
    'blue': ColorsData(
      primary: const Color(0xFFD6E4FF),
      secondary: const Color(0xFF001C3B),
    ),
    'green': ColorsData(
      primary: const Color(0xFFC4EED0),
      secondary: const Color(0xFF00210B),
    ),
    'yellow': ColorsData(
      primary: const Color(0xFFFFE082),
      secondary: const Color(0xFF3E2723),
    ),
    'orange': ColorsData(
      primary: const Color(0xFFFFDCC6),
      secondary: const Color(0xFF341200),
    ),
    'whine': ColorsData(
      primary: const Color(0xFFFFD8E4),
      secondary: const Color(0xFF31111D),
    ),
    'wine': ColorsData(
      primary: const Color(0xFFFFD8E4),
      secondary: const Color(0xFF31111D),
    ),
    'purple': ColorsData(
      primary: const Color(0xFFEADDFF),
      secondary: const Color(0xFF21005D),
    ),
    'grey': ColorsData(
      primary: const Color(0xFFE1E2EC),
      secondary: const Color(0xFF191C23),
    ),
    'teal': ColorsData(
      primary: const Color(0xFFBCEBE3),
      secondary: const Color(0xFF00201C),
    ),
  };
}
