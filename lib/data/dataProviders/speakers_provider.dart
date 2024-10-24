import 'package:flutter/cupertino.dart';
import 'package:iccm_eu_app/data/model/provider_data.dart';
import 'package:iccm_eu_app/data/model/speaker_data.dart';

class SpeakersProvider extends ProviderData<SpeakerData> with ChangeNotifier {
  @override
  String get worksheetTitle => "Speakers";

  List<SpeakerData> get items => _items;
  final List<SpeakerData> _items = [];

  SpeakersProvider() {
    add(
      SpeakerData(
        imageUrl: 'https://via.placeholder.com/150',
        name: const TextSpan(
          text: 'John Doe',
        ),
        details: const TextSpan(
          text: 'Software Engineer',
        ),
      )
    );
    add(
      SpeakerData(
        imageUrl: 'https://via.placeholder.com/150',
        name: const TextSpan(
          text: 'Jane Doe',
        ),
        details: const TextSpan(
          text: 'Product Designer',
        ),
      )
    );
    add(
      SpeakerData(
        imageUrl: 'https://via.placeholder.com/150',
        name: const TextSpan(
          text: 'John Doe',
        ),
        details: const TextSpan(
          text: 'Software Engineer',
        ),
      )
    );
    add(
      SpeakerData(
        imageUrl: 'https://via.placeholder.com/150',
        name: const TextSpan(
          text: 'Jane Doe',
        ),
        details: const TextSpan(
          text: 'Product Designer',
        ),
      )
    );
    add(
      SpeakerData(
        imageUrl: 'https://via.placeholder.com/150',
        name: const TextSpan(
          text: 'John Doe',
        ),
        details: const TextSpan(
          text: 'Software Engineer',
        ),
      )
    );
    add(
      SpeakerData(
        imageUrl: 'https://via.placeholder.com/150',
        name: const TextSpan(
          text: 'Jane Doe',
        ),
        details: const TextSpan(
          text: 'Product Designer',
        ),
      )
    );
    add(
      SpeakerData(
        imageUrl: 'https://via.placeholder.com/150',
        name: const TextSpan(
          text: 'John Doe and a person with a very long name here which would possibly break across the lines',
        ),
        details: const TextSpan(
          text: 'Software Engineer who is engaged with a lot of development projects and would be willing to help',
        ),
      )
    );
    add(
      SpeakerData(
        imageUrl: 'https://via.placeholder.com/150',
        name: const TextSpan(
          text: 'Jane Doe',
        ),
        details: const TextSpan(
          text: 'Product Designer',
        ),
      )
    );
    add(
      SpeakerData(
        imageUrl: 'https://via.placeholder.com/150',
        name: const TextSpan(
          text: 'John Doe',
        ),
        details: const TextSpan(
          text: 'Software Engineer',
        ),
      )
    );
    add(
      SpeakerData(
        imageUrl: 'https://via.placeholder.com/150',
        name: const TextSpan(
          text: 'Jane Doe',
        ),
        details: const TextSpan(
          text: 'Product Designer',
        ),
      )
    );

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // Call fetchData after the widget tree is built
    //   sheetsProvider.fetchData(context);
    // });
  }

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