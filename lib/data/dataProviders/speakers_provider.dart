import 'package:flutter/cupertino.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/model/provider_data.dart';
import 'package:iccm_eu_app/data/model/speaker_data.dart';
import 'package:provider/provider.dart';

class SpeakersProvider extends ProviderData<SpeakerData> with ChangeNotifier {
  @override
  String get worksheetTitle => "Speakers";

  List<SpeakerData> get items => _speakers;
  final List<SpeakerData> _speakers = [];
  final GsheetsProvider sheetsProvider;
  final BuildContext context;

  factory SpeakersProvider(BuildContext context) {
    final sheetsProvider = Provider.of<GsheetsProvider>(context, listen: false);
    return SpeakersProvider._(
      sheetsProvider: sheetsProvider,
      context: context,
    );
  }

  SpeakersProvider._({
    required this.sheetsProvider,
    required this.context,
  }) {
    final sheetsProvider = Provider.of<GsheetsProvider>(context, listen: false);
    sheetsProvider.fetchData(context);

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

    sheetsProvider.fetchData(context);
  }

  @override
  void add(SpeakerData item) {
    _speakers.add(item);
    notifyListeners();
  }

  @override
  void clear() {
    _speakers.clear();
    notifyListeners();
  }
}