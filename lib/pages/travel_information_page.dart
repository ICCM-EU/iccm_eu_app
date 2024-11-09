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
    return CustomScrollView(
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
                    RichText(
                      text: TextSpan(
                          text: item.name.text,
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          )
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    RichText(
                      text: item.details,
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
              context.read<TravelDirectionsProvider>().items().length,
          ),
        ),
      ],
    );
  }
}