import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/controls/menu_drawer.dart';
import 'package:iccm_eu_app/controls/nav_bar.dart';
import 'package:iccm_eu_app/data/appProviders/fullscreen_provider.dart';
import 'package:iccm_eu_app/data/appProviders/page_index_provider.dart';
import 'package:iccm_eu_app/data/appProviders/error_provider.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/home_provider.dart';
import 'package:iccm_eu_app/pages/countdown_page.dart';
import 'package:iccm_eu_app/pages/share_page.dart';
import 'package:iccm_eu_app/theme/dark_theme.dart';
import 'package:iccm_eu_app/theme/light_theme.dart';
import "package:provider/provider.dart" show Consumer, Provider;

import 'package:iccm_eu_app/data/appProviders/theme_provider.dart';

class BasePage extends StatefulWidget {
  const BasePage({
    super.key,
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
    // Delay the index update after the widget is initialized,
    // so the Consumer can listen to the changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getQueryParams();
    });
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

  void _getQueryParams() {
    if (kIsWeb) {
      final uri = Uri.base;
      final queryParams = uri.queryParameters;
      if (queryParams.containsKey('page') && queryParams['page'] != null) {
        if (queryParams['page']! == 'events') {
          _setPageIndex(PageList.events.index);
          PreferencesProvider.setIsDayView(false);
          PreferencesProvider.setFutureEvents(true);
        } else if (queryParams['page']! == 'countdown') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CountdownPage(),
              fullscreenDialog: true, // Open fullscreen
            ),
          );
        }
      }
    }
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
        child: Consumer<FullscreenProvider>(
          builder: (context, fullscreenProvider, child) {
            return Consumer<PageIndexProvider>(
              builder: (context, pageIndex, child) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode: Provider.of<ThemeProvider>(context).themeMode,
                  home: Scaffold(
                    drawer: MenuDrawer(setPageIndex: _setPageIndex),
                    backgroundColor: Theme
                        .of(context)
                        .appBarTheme
                        .backgroundColor,
                    appBar: fullscreenProvider.isFullscreen &&
                        pageIndex.selectedIndex == PageList.events.index ?
                        null : AppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: Theme
                          .of(context)
                          .appBarTheme
                          .backgroundColor,
                      foregroundColor: Theme
                          .of(context)
                          .appBarTheme
                          .foregroundColor,
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
                      actions: [
                        Consumer<HomeProvider>(
                          builder: (context, itemProvider, child) {
                            final itemList = itemProvider.items();
                            if (itemList.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            final item = itemList.first; // Use the first item
                            String shareUrl = item.appShareUrl ?? '';
                            return (shareUrl.startsWith('https://')) ? IconButton(
                              icon: Icon(
                                Icons.share,
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .tertiary,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                    SharePage(
                                      url: shareUrl,
                                    ),
                                    fullscreenDialog: true, // Open fullscreen
                                  ),
                                );
                              },
                            ) : SizedBox.shrink();
                          },
                        ),
                      ],
                    ),

                    bottomNavigationBar: fullscreenProvider.isFullscreen &&
                        pageIndex.selectedIndex == PageList.events.index ?
                      null : const NavBar(),

                    body: IndexedStack( // Use IndexedStack here
                      index: Provider.of<PageIndexProvider>(
                          context,
                          listen: true).selectedIndex,
                      children: navBar.widgetOptions, //.asMap().entries.map((entry) {
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
