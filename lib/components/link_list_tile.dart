import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/model/communication_data.dart';
import 'package:iccm_eu_app/utils/url_functions.dart';

class LinkListTile extends StatelessWidget {
  final CommunicationData item;

  const LinkListTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    UrlFunctions.getFaviconUrl(item.url).then((websiteIconUrl) {
      if (websiteIconUrl != null) {
      } else {
      }
    });
    return ListTile(
      leading: FutureBuilder<String?>(
        future: UrlFunctions.getFaviconUrl(item.url),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for the Future to complete, show a loading indicator
            return const SizedBox(
              width: 100,
              height: 100,
              child: FittedBox(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            // If there's an error, show an error icon
            return const SizedBox(
              width: 100,
              height: 100,
              child: FittedBox(
                child: Icon(Icons.error),
              ),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            // If the Future completed successfully and has data, show the image
            return CircleAvatar(
              radius: 50.0,
              child: SizedBox(
                width: 100.0,
                height: 100.0,
                child: CachedNetworkImage(
                  imageUrl: snapshot.data!,
                  placeholder: (context, url) => const FittedBox(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const FittedBox(
                    child: Icon(Icons.error),
                  ),
                ),
              ),
            );
          } else {
            // If the Future completed successfully but has no data (null), show an empty box
            return const SizedBox(
              height: 100,
              width: 100,
            );
          }
        },
      ),
      title: RichText(
        text: TextSpan(
          style: DefaultTextStyle
              .of(context)
              .style,
          children: <TextSpan>[
            TextSpan(
              text: item.title,
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
              text: item.url,
              style: Theme
                  .of(context)
                  .textTheme
                  .bodySmall,
            ),
          ],
        ),
        softWrap: true,
      ),
      onTap: () {
        UrlFunctions.launch(item.url);
      },
    );
  }
}