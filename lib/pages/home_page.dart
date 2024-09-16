import 'package:flutter/material.dart';
import "package:provider/provider.dart" show Provider;

import 'package:iccm_eu_app/theme/theme_provider.dart';
import 'package:iccm_eu_app/controls/settings_drawer.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({
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
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  void setCurrentIndex(int index) {
    // This call to setState tells the Flutter framework that something has
    // changed in this State, which causes it to rerun the build method below
    // so that the display can reflect the updated values. If we changed
    // _currentIndex without calling setState(), then the build method would not be
    // called again, and so nothing would appear to happen.
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider tp = Provider.of<ThemeProvider>(context);
    String darkString = tp.isDarkMode.toString();

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
        drawer: const SettingsDrawer(),
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
                  icon: const Icon(Icons.settings),
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
          currentIndex: 0,
          fixedColor: Theme.of(context).colorScheme.secondary,
          backgroundColor: Colors.green[400]!,
          onTap: (index) => setCurrentIndex(index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: "Speakers",
            ),
          ],
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            //
            // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
            // action in the IDE, or press "p" in the console), to see the
            // wireframe for each widget.
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Welcome. Index:',
              ),
              Text(
                '$_currentIndex',
                //style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                'Dark Theme: $darkString',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
