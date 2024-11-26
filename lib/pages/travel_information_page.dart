import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/travel_direction_list_tile.dart';
import 'package:iccm_eu_app/components/url_button.dart';
import 'package:iccm_eu_app/data/dataProviders/travel_directions_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/travel_provider.dart';
import 'package:provider/provider.dart';

class TravelInformationPage extends StatelessWidget {
  const TravelInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Center(
      //     child: const Text('Travel Information'),
      //   ),
      //   automaticallyImplyLeading: false,
      //   backgroundColor: Theme
      //       .of(context)
      //       .appBarTheme
      //       .backgroundColor,
      //   foregroundColor: Theme
      //       .of(context)
      //       .appBarTheme
      //       .foregroundColor,
      // ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Consumer<TravelProvider>(
              builder: (context, itemProvider, child) {
                final itemList = itemProvider.items();
                if (itemList.isEmpty) {
                  return const Center(
                      child: Text('Loading dynamic content...'));
                }
                final item = itemList.first; // Use the first item
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(item.imageUrl), // Banner image
                      const SizedBox(height: 16.0),
                      Text(item.name.text!,
                        style: Theme
                            .of(context)
                            .textTheme
                            .headlineSmall,
                      ),
                      const SizedBox(height: 8.0),
                      Text(item.details.text!,
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyMedium,
                      ),
                      UrlButton(
                        title: 'Website',
                        url: item.locationUrl,
                      ),
                      UrlButton(
                        title: 'Google Maps Link',
                        url: item.mapsUrl,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final isFirstItem = index == 0;
                return Column( // Wrap the list item and Divider in a Column
                  children: [
                    if (isFirstItem) const Divider(),
                    Consumer<TravelDirectionsProvider>(
                      builder: (context, itemList, child) {
                        return TravelDirectionListTile(
                          item: itemList.items()[index],
                        );
                      },
                    ),
                  ],
                );
              },
              childCount:
              context
                  .read<TravelDirectionsProvider>()
                  .items()
                  .length,
            ),
          ),
        ],
      ),
    );
  }
}