import 'package:flutter/material.dart';
import 'package:iccm_eu_app/controls/menu_drawer.dart';
import 'package:iccm_eu_app/controls/nav_bar.dart';
import 'package:iccm_eu_app/data/page_index_provider.dart';
import "package:provider/provider.dart" show Consumer, Provider;

import 'package:iccm_eu_app/theme/theme_provider.dart';


class BasePage extends StatefulWidget {
  const BasePage({
    super.key,
    //required this.prefsProvider,
  });

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title = 'ICCM Europe App';

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  final NavBar navBar = const NavBar();

  void _setPageIndex(int index) {
    final pageIndexProvider = Provider.of<PageIndexProvider>(context, listen: false);
    pageIndexProvider.updateSelectedIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Consumer<PageIndexProvider>(
      builder: (context, appState, child) {
        return Consumer<PageIndexProvider>(
          builder: (context, appState, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: Provider
                  .of<ThemeProvider>(context)
                  .themeData,
              home: Scaffold(
                drawer: MenuDrawer(setPageIndex: _setPageIndex),
                backgroundColor: Colors.green[400]!,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Theme
                      .of(context)
                      .colorScheme
                      .surface,
                  foregroundColor: Theme
                      .of(context)
                      .colorScheme
                      .tertiary,
                  // TRY THIS: Try changing the color here to a specific color (to
                  // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
                  // change color while the other colors stay the same.
                  // Here we take the value from the MyHomePage object that was created by
                  // the App.build method, and use it to set our appbar title.
                  title: Row(
                    children: [
                      Builder(
                        builder: (context) =>
                            IconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: () =>
                                  Scaffold.of(context)
                                      .openDrawer(),
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

                bottomNavigationBar: const NavBar(),

                body: IndexedStack( // Use IndexedStack here
                  index: Provider.of<PageIndexProvider>(context, listen: true).selectedIndex,
                  children: navBar.widgetOptions,
                ),
              ),
            );
          });
      });
  }
}
