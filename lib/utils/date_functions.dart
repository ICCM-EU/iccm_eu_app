import 'package:intl/intl.dart';

class DateFunctions {
  String formatDate({
    required DateTime date,
    required String format,
  }) {
    DateFormat f = DateFormat(format);
    return f.format(date);
  }
}