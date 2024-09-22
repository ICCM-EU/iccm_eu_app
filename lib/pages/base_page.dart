import 'package:flutter/material.dart';
import 'package:iccm_eu_app/pages/about_page.dart';
import 'package:iccm_eu_app/pages/home_page.dart';
import 'package:iccm_eu_app/pages/preferences_page.dart';
import 'package:iccm_eu_app/pages/rooms_page.dart';
import 'package:iccm_eu_app/pages/schedule_page.dart';
import 'package:iccm_eu_app/pages/speakers_page.dart';
import 'package:iccm_eu_app/pages/tracks_page.dart';
import 'package:iccm_eu_app/pages/travel_information_page.dart';
import "package:provider/provider.dart" show Provider;

import 'package:iccm_eu_app/theme/theme_provider.dart';
import 'package:iccm_eu_app/controls/menu_drawer.dart';


class BasePage extends StatefulWidget {
  const BasePage({
    super.key,
    required this.title,
    //required this.prefsProvider,
  });

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<BasePage> createState() => _BasePageState();
}

enum PageList {
  home,
  schedule,
  tracks,
  speakers,
  rooms,
  preferences,
  travelInformation,
  about,
}

class _BasePageState extends State<BasePage> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(), // 0
    SchedulePage(), // 1
    TracksPage(), // 2
    SpeakersPage(), // 3
    RoomsPage(), // 4
    PreferencesPage(), // 5
    TravelInformationPage(), // 6
    AboutPage(), // 7
  ];

  void _setCurrentIndex(int index) {
    // This call to setState tells the Flutter framework that something has
    // changed in this State, which causes it to rerun the build method below
    // so that the display can reflect the updated values. If we changed
    // _currentIndex without calling setState(), then the build method would not be
    // called again, and so nothing would appear to happen.
    if (index >= _widgetOptions.length) {
      index = 0;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: Scaffold(
        drawer: MenuDrawer(setPageIndex: _setCurrentIndex),
        backgroundColor: Colors.green[400]!,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.tertiary,
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 55),
                child: Text(
                    widget.title,
                    textAlign: TextAlign.center
                ),
              ),
            ],
          ),
        ),

        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.tertiary,
          showUnselectedLabels: true,
          //backgroundColor: Colors.green[900]!,
          onTap: (index) => _setCurrentIndex(index),
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
          currentIndex: (_selectedIndex >= 5) ? 0 : _selectedIndex,
        ),

        body: IndexedStack( // Use IndexedStack here
          index: _selectedIndex,
          children: _widgetOptions,
        ),
      ),
    );
  }
}
