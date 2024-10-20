import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/model/provider_data.dart';
import 'package:iccm_eu_app/data/model/room_data.dart';
import 'package:provider/provider.dart';

class RoomsProvider extends ProviderData<RoomData> with ChangeNotifier {
  @override
  String get worksheetTitle => "Rooms";

  List<RoomData> get items => _items;
  final List<RoomData> _items = [];
  final GsheetsProvider sheetsProvider;
  final BuildContext context;

  factory RoomsProvider(BuildContext context) {
    final sheetsProvider = Provider.of<GsheetsProvider>(context, listen: false);
    return RoomsProvider._(
      sheetsProvider: sheetsProvider,
      context: context,
    );
  }

  RoomsProvider._({
    required this.sheetsProvider,
    required this.context,
  }) {
    add(
      RoomData(
        imageUrl: 'https://via.placeholder.com/150',
        name: const TextSpan(
          text: 'AJAX',
        ),
        details: const TextSpan(
          text: 'Largest workshop room for the whole crowd.',
        ),
      ),
    );
    add(
        RoomData(
          imageUrl: 'https://via.placeholder.com/150',
          name: const TextSpan(
            text: 'Basic',
          ),
          details: const TextSpan(
            text: 'Second workshop room',
          ),
        )
    );
    add(
        RoomData(
          imageUrl: 'https://via.placeholder.com/150',
          name: const TextSpan(
            text: 'Delphi',
          ),
          details: const TextSpan(
            text: 'Third and smallest workshop room.\n\nLeft and then right',
          ),
        )
    );
    add(
      RoomData(
        imageUrl: 'https://via.placeholder.com/150',
        name: const TextSpan(
          text: 'Espresso',
        ),
        details: const TextSpan(
          text: 'Room for coffee breaks.',
        ),
      ),
    );

    sheetsProvider.fetchData(context);
  }

  @override
  void add(RoomData item) {
    _items.add(item);
    notifyListeners();
  }

  @override
  void clear() {
    _items.clear();
    notifyListeners();
  }
}