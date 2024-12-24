import 'package:shared_preferences/shared_preferences.dart';

class IdGenerator {
  static const String _counterKey = 'notification_ids';
  static List<int> _notificationIds = [];
  static int _lastFound = 0;

  static Future<int> generateItemId() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> idStrings = prefs.getStringList(_counterKey) ?? [];
    _notificationIds = idStrings.map((id) => int.tryParse(id) ?? 0).toList();
    int nextId = _findFirstNonExistingInteger(_notificationIds);
    await prefs.setStringList(
        _counterKey,
        _notificationIds.map((id) => id.toString()).toList(),
    ); // Save updated counter
    return nextId;
  }

  static int _findFirstNonExistingInteger(List<int> ids) {
    // Save the last found number in this session to optimize search.
    int i = _lastFound + 1;
    while (ids.contains(i)) {
      i++;
    }
    _lastFound = i;
    return i;
  }
}
