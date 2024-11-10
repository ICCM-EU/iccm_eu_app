import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iccm_eu_app/controls/menu_drawer.dart';
import 'package:iccm_eu_app/controls/nav_bar.dart';
import 'package:iccm_eu_app/data/appProviders/page_index_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/error_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import "package:provider/provider.dart" show Consumer, Provider;

import 'package:iccm_eu_app/data/appProviders/theme_provider.dart';

class BasePage extends StatefulWidget {
  const BasePage({
    super.key,
    //required this.prefsProvider,
  });

  final String title = 'ICCM Europe App';

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  final NavBar navBar = const NavBar();
  late Timer _timer;

  Future<void> _fetchData({
    bool force = false,
    ErrorProvider? errorProvider,
  }) async {
    Provider.of<GsheetsProvider>(context, listen: false).fetchData(
      errorProvider: errorProvider,
      force: force,
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchData(
      errorProvider: Provider.of<ErrorProvider>(context, listen: false),
      force: true,
    );
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _fetchData(
        errorProvider: Provider.of<ErrorProvider>(context, listen: false),
        force: false,
      ); // Call fetchData every 5 minutes
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _setPageIndex(int index) {
    final pageIndexProvider = Provider.of<PageIndexProvider>(
        context, listen: false);
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
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
          _fetchData(
            errorProvider: Provider.of<ErrorProvider>(context, listen: false),
            force: true,
          ),
        child: Consumer<PageIndexProvider>(
          builder: (context, appState, child) {
            return Consumer<PageIndexProvider>(
              builder: (context, appState, child) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: Provider.of<ThemeProvider>(context).themeData,
                  home: Scaffold(
                    drawer: MenuDrawer(setPageIndex: _setPageIndex),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    appBar: AppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).colorScheme.tertiary,
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

                    bottomNavigationBar: const NavBar(),

                    body: IndexedStack( // Use IndexedStack here
                      index: Provider.of<PageIndexProvider>(
                          context,
                          listen: true).selectedIndex,
                      children: navBar.widgetOptions,
                    ),
                  ),
                );
              }
            );
          }
        )
      )
    );
  }
}
