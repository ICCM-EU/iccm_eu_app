import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/page_title.dart';
import 'package:iccm_eu_app/data/dataProviders/speakers_provider.dart';
import 'package:iccm_eu_app/pages/speaker_details_page.dart';
import 'package:provider/provider.dart';

class SpeakersPage extends StatelessWidget {
  const SpeakersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView(
          shrinkWrap: true, // Important to prevent unbounded height issues
          physics: const NeverScrollableScrollPhysics(), // Disable scrolling for static list
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: const <Widget>[
            PageTitle(title: 'Speakers'),
          ]
        ),
        Expanded( // Use Expanded to allow ListView.builder to take available space
          child: Consumer<SpeakersProvider>( // Wrap ListView.builder with Consumer
            builder: (context, itemList, child) {
              return ListView.builder(
                itemCount: itemList.items.length,
                itemBuilder: (context, index) {
                  final item = itemList.items[index];
                  return ListTile(
                    leading: item.imageUrl.startsWith("http") ?
                      CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          backgroundImage: imageProvider,
                          radius: 50,
                        ),
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ) :
                        const SizedBox.shrink(),
                    title: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: item.name.text,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                      softWrap: false,
                    ),
                    subtitle: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: item.details.text,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      softWrap: true,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Theme(
                            data: Theme.of(context),
                            child: SpeakerDetailsPage(item: item),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
