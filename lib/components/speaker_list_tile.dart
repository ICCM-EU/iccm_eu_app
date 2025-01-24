import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/model/speaker_data.dart';
import 'package:iccm_eu_app/pages/speaker_details_page.dart';
import 'package:iccm_eu_app/utils/text_functions.dart';

class SpeakerListTile extends StatelessWidget {
  final SpeakerData item;

  const SpeakerListTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    String imageUrl = item.imageUrl;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                Theme(
                  data: Theme.of(context),
                  child: SpeakerDetailsPage(item: item),
                ),
          ),
        );
      },
      onVerticalDragUpdate: (details) {
        // Get the parent ListView's scroll controller
        final ScrollController scrollController = PrimaryScrollController.of(context);
        // Scroll the ListView based on the drag details
        scrollController.jumpTo(scrollController.offset - details.primaryDelta!);
      },
      onVerticalDragEnd: (details) {
        // Optional: Handle any scroll fling behavior here
      },
      child: ListTile(
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
                    text: item.details, length: 30),
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyMedium,
              ),
            ],
          ),
          softWrap: true,
        ),
      ),
    );
  }
}