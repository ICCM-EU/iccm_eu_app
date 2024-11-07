import 'dart:ui';
import 'package:iccm_eu_app/data/model/colors_data.dart';

class TrackColorsDictionary {
  final Map<String, ColorsData> colors = {
    'red': ColorsData(
        primary: const Color(0xffad2121),
        secondary: const Color(0xfffae3e3),
    ),
    'blue': ColorsData(
      primary: const Color(0xff2c21ad),
      secondary: const Color(0xffcecced),
  ),
    'yellow': ColorsData(
      primary: const Color(0xffa2ad21),
      secondary: const Color(0xffebeec2),
  ),
    'orange': ColorsData(
      primary: const Color(0xffad6421),
      secondary: const Color(0xffe7c9ad),
  ),
    'whine': ColorsData(
      primary: const Color(0xffad2164),
      secondary: const Color(0xffecbbd2),
  ),
    'purple': ColorsData(
      primary: const Color(0xff9e21ad),
      secondary: const Color(0xffe5b5eb),
  ),
    'grey': ColorsData(
      primary: const Color(0xffb1b1b1),
      secondary: const Color(0xffececec),
    ),
  };
}
