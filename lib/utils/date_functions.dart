import 'package:intl/intl.dart';

class DateFunctions {
  static String formatDate({
    required DateTime date,
    required String format,
  }) {
    DateFormat f = DateFormat(format);
    return f.format(date);
  }

  static String formatDuration(Duration? duration) {
    if (duration == null) {
      return '--:--:--';
    }
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (days == 0) {
      return
        '${hours > 0 ? '${hours.toString().padLeft(2, '0')}:' : ''}'
            '${minutes.toString().padLeft(2, '0')}:'
            '${seconds.toString().padLeft(2, '0')}';
    } else {
      return
        '${days > 0 ? '${days.toString().padLeft(2, '0')}d ' : ''}'
            '${hours.toString().padLeft(2, '0')}h '
            '${minutes.toString().padLeft(2, '0')}m ';
    }
  }
}