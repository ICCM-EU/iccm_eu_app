import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/model/track_data.dart';
import 'package:iccm_eu_app/pages/track_details_page.dart';
import 'package:iccm_eu_app/utils/text_functions.dart';

class TrackListTile extends StatelessWidget {
  final TrackData item;

  const TrackListTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    String imageUrl = item.imageUrl;
    return ListTile(
      leading: imageUrl.startsWith("http") ?
      CircleAvatar(
          radius: 50.0,
          child: SizedBox(
              width: 100.0, // Diameter of CircleAvatar
              height: 100.0,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) =>
                    FittedBox(
                      child: CircularProgressIndicator(),
                    ),
                errorWidget: (context, url, error) =>
                    FittedBox(
                      child: Icon(Icons.error),
                    ),
              )
          )
      ) :
      const SizedBox(
        height: 100,
        width: 100,
      ),
      title: RichText(
        text: TextSpan(
          style: DefaultTextStyle
              .of(context)
              .style,
          children: <TextSpan>[
            TextSpan(
              text: item.name,
              style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium,
            ),
          ],
        ),
        softWrap: false,
      ),
      subtitle: RichText(
        text: TextSpan(
          style: DefaultTextStyle
              .of(context)
              .style,
          children: <TextSpan>[
            TextSpan(
              text: TextFunctions.cutTextToWords(
                  text: item.details,
                  wordCount: 10),
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyMedium,
            ),
          ],
        ),
        softWrap: true,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                Theme(
                  data: Theme.of(context),
                  child: TrackDetailsPage(item: item),
                ),
          ),
        );
      },
    );
  }
}