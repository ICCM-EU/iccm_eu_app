import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/travel_details_list_tile.dart';
import 'package:iccm_eu_app/components/url_button.dart';
import 'package:iccm_eu_app/data/dataProviders/travel_details_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/travel_provider.dart';
import 'package:provider/provider.dart';

class TravelPage extends StatelessWidget {
  const TravelPage({super.key});

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
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.3, // 30% of screen height
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Consumer<TravelProvider>(
                      builder: (context, itemProvider, child) {
                        final itemList = itemProvider.items();
                        if (itemList.isEmpty) {
                          return const Center(
                            child: Text('Loading dynamic content...'),
                          );
                        }
                        final item = itemList.first;
                        return CachedNetworkImage(
                          imageUrl: item.imageUrl,
                          fit: BoxFit.cover,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                          colorBlendMode: BlendMode.srcIn,
                        );
                      },
                    );
                  }
              ),
            ),
          ),
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
                      const SizedBox(height: 16.0),
                      Text(item.name,
                        style: Theme
                            .of(context)
                            .textTheme
                            .headlineSmall,
                      ),
                      const SizedBox(height: 8.0),
                      Text(item.details,
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
                    Consumer<TravelDetailsProvider>(
                      builder: (context, itemList, child) {
                        return TravelDetailsListTile(
                          item: itemList.items()[index],
                        );
                      },
                    ),
                  ],
                );
              },
              childCount:
              context
                  .read<TravelDetailsProvider>()
                  .items()
                  .length,
            ),
          ),
        ],
      ),
    );
  }
}