import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/dataProviders/home_provider.dart';
import 'package:iccm_eu_app/utils/url_launcher.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Consumer<HomeProvider>(
        builder: (context, homeProvider, child) {
          final homeDataList = homeProvider.items();
          if (homeDataList.isEmpty) {
            return const Center(child: Text('No home data available.'));
          }
          final homeData = homeDataList.first; // Use the first item
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(homeData.imageUrl), // Banner image
                const SizedBox(height: 16.0),
                RichText(
                  text: TextSpan(
                    text: homeData.name.text,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    )
                  ),
                ),
                const SizedBox(height: 8.0),
                RichText(
                  text: homeData.details,
                ), // Descriptive text
                if (homeData.nowPageUrl != null &&
                    homeData.nowPageUrl!.startsWith('http'))
                  const SizedBox(height: 16.0),
                  Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.9, // 90% of parent width
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.green,
                            width: 2.0,
                            style: BorderStyle.solid,
                            strokeAlign: BorderSide.strokeAlignInside,
                          ),
                        ),
                        onPressed: () => UrlLauncher.url(homeData.nowPageUrl!),
                        child: const Text(
                          'Now Page',
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (homeData.votingPageUrl != null &&
                    homeData.votingPageUrl!.startsWith('http'))
                  const SizedBox(height: 16.0),
                  Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.9, // 90% of parent width
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.green,
                            width: 2.0,
                            style: BorderStyle.solid,
                            strokeAlign: BorderSide.strokeAlignInside,
                          ),
                        ),
                        onPressed: () => UrlLauncher.url(homeData.votingPageUrl!),
                        child: const Text(
                          'Voting Page',
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}