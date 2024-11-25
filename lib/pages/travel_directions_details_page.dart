import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/controls/nav_bar.dart';
import 'package:iccm_eu_app/data/model/travel_directions_data.dart';


class TravelDirectionsDetailsPage extends StatelessWidget {
  final TravelDirectionsData item;
  const TravelDirectionsDetailsPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Travel Directions"),
      ),
      body:
      ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (item.imageUrl.startsWith("http"))
                  CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      backgroundImage: imageProvider,
                      radius: 50,
                    ),
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  )
                else
                  const SizedBox.shrink(),
                const SizedBox(height: 16),
                Text(item.name.text!,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(item.details.text!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ]
      ),
      bottomNavigationBar: const NavBar(),
    );
  }
}