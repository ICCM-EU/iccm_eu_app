import 'package:flutter/cupertino.dart';
import 'package:iccm_eu_app/data/model/provider_data.dart';
import 'package:iccm_eu_app/data/model/speaker_data.dart';

class SpeakersProvider extends ProviderData<SpeakerData> with ChangeNotifier {
  @override
  String get worksheetTitle => "Speakers";

  List<SpeakerData> get items => _items;
  final List<SpeakerData> _items = [];

  @override
  void add(SpeakerData item) {
    _items.add(item);
    notifyListeners();
  }

  @override
  void clear() {
    _items.clear();
    notifyListeners();
  }
}