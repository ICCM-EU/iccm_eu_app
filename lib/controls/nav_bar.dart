import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/appProviders/page_index_provider.dart';
import 'package:iccm_eu_app/pages/about_page.dart';
import 'package:iccm_eu_app/pages/home_page.dart';
import 'package:iccm_eu_app/pages/preferences_page.dart';
import 'package:iccm_eu_app/pages/rooms_page.dart';
import 'package:iccm_eu_app/pages/events_page.dart';
import 'package:iccm_eu_app/pages/speakers_page.dart';
import 'package:iccm_eu_app/pages/tracks_page.dart';
import 'package:iccm_eu_app/pages/travel_information_page.dart';
import 'package:provider/provider.dart';

enum PageList {
  home,
  schedule,
  tracks,
  speakers,
  rooms,
  preferences,
  travelInformation,
  countdownSchedule,
  about,
}

class NavBar extends StatefulWidget {
  const NavBar({
    super.key,
  });

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(), // 0
    const EventsPage(), // 1
    const TracksPage(), // 2
    const SpeakersPage(), // 3
    const RoomsPage(), // 4
    const PreferencesPage(), // 5
    const TravelInformationPage(), // 6
    const AboutPage(), // 7
  ];
  List<Widget> get widgetOptions => _widgetOptions;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Theme
          .of(context)
          .colorScheme
          .primary,
      unselectedItemColor: Theme
          .of(context)
          .colorScheme
          .tertiary,
      showUnselectedLabels: true,
      //backgroundColor: Colors.green[900]!,
      onTap: (index) {
        Provider.of<PageIndexProvider>(context, listen: false).
          updateSelectedIndex(index);
        Navigator.popUntil(context, (route) => route.settings.name == '/');
      },
      currentIndex: Provider.of<PageIndexProvider>(context, listen: true).
        selectedIndex >= 5 ? 0 :
        Provider.of<PageIndexProvider>(context, listen: true).selectedIndex,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: "Schedule",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_train),
          label: "Tracks",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: "Speakers",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.room),
          label: "Rooms",
        ),
      ],
    );
  }
}