import "package:provider/provider.dart" show ChangeNotifierProvider, Provider;

import 'package:flutter/material.dart';
import 'package:iccm_eu_app/theme/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ICCM Europe App',
      home: const MyHomePage(title: 'ICCM Europe App'),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

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
        drawer: const NavBar(),
        backgroundColor: Colors.green[400]!,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.background,
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
            ],
          ),
        ),
      ),
    );
  }
}

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  //bool _forceDarkMode = false;

  //void setForceDarkMode(bool value) {
    // setState(() {
    //   _forceDarkMode = value;
    // });
  //}

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green[400]!,
            ),
            child: Wrap(
              children: <Widget>[
                const Text("Settings",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SwitchListTile(
                  activeColor: Colors.black,
                  activeTrackColor: Colors.grey[800]!.withOpacity(0.4),
                  inactiveThumbColor: Colors.grey[300]!.withOpacity(0.4),
                  inactiveTrackColor: Colors.grey[700]!.withOpacity(0.4),
                  splashRadius: 20,
                  title: const Text('Dark Mode'),
                  secondary: const Icon(Icons.lightbulb_outline),
                  value: Provider.of<ThemeProvider>(context, listen: false).isDark(),
                  onChanged: (value) => setState(() {
                    //_forceDarkMode = value;
                    Provider.of<ThemeProvider>(context, listen: false).setTheme(value);
                  }),
                ),              ],
            ),
          ),
          //Switch.adaptive(

          const ListTile(
            leading: Icon(Icons.question_mark),
            title: Text("About"),
            //onTap: () => print("Tapped"),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.question_mark),
            title: Text("About"),
            //onTap: () => AboutDialog(
            //  applicationName: Text("ICCM Europe App"),
            //  applicationVersion: Text("2025"),
            //  applicationLegalese: Text("Made by participants."),
            // ),
          ),
        ],
      )
    );
  }
}