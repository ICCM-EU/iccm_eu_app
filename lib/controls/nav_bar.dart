import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/appProviders/page_index_provider.dart';
import 'package:iccm_eu_app/pages/about_page.dart';
import 'package:iccm_eu_app/pages/communication_page.dart';
import 'package:iccm_eu_app/pages/home_page.dart';
import 'package:iccm_eu_app/pages/preferences_page.dart';
import 'package:iccm_eu_app/pages/rooms_page.dart';
import 'package:iccm_eu_app/pages/events_page.dart';
import 'package:iccm_eu_app/pages/share_page.dart';
import 'package:iccm_eu_app/pages/speakers_page.dart';
import 'package:iccm_eu_app/pages/tracks_page.dart';
import 'package:iccm_eu_app/pages/travel_page.dart';
import 'package:provider/provider.dart';

enum PageList {
  home, // 0
  events, // 1
  tracks, // 2
  speakers, // 3
  rooms, // 4
  preferences, // 5
  travelInformation, // 6
  communication, // 7
  about, // 8
  share,// 9
}

class NavBar extends StatefulWidget {
  const NavBar({
    super.key,
  });

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(), // 0
    const EventsPage(), // 1
    TracksPage(), // 2
    SpeakersPage(), // 3
    RoomsPage(), // 4
    PreferencesPage(), // 5
    const TravelPage(), // 6
    const CommunicationPage(), // 7
    const AboutPage(), // 8
    const SharePage(url: 'https://github.com/ICCM-EU/iccm_eu_app'), // 9
  ];

  List<Widget> get widgetOptions => _widgetOptions;

  static final List<BottomNavigationBarItem> bottomNavigationBarItems = [
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
  ];

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).colorScheme.secondary,
      showUnselectedLabels: true,
      onTap: (index) {
        Provider.of<PageIndexProvider>(context, listen: false).
          updateSelectedIndex(index);
        Navigator.popUntil(context, (route) => route.settings.name == '/');
      },
      currentIndex: Provider.of<PageIndexProvider>(context, listen: true).
        selectedIndex >= NavBar.bottomNavigationBarItems.length ? 0 :
        Provider.of<PageIndexProvider>(context, listen: true).selectedIndex,
      items: NavBar.bottomNavigationBarItems,
    );
  }
}