import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/dataProviders/favorites_provider.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';
import 'package:iccm_eu_app/pages/event_details_page.dart';
import 'package:iccm_eu_app/utils/date_functions.dart';
import 'package:iccm_eu_app/utils/text_functions.dart';
import 'package:provider/provider.dart';

class EventListTile extends StatelessWidget {
  final EventData item;

  const EventListTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    FavoritesProvider favProvider =
    Provider.of<FavoritesProvider>(context, listen: true);
    bool isFavorite = favProvider.isInFavorites(
      name: item.name,
      start: item.start
    );
    String imageUrl = item.imageUrl ?? '';
    Color bgColor = Theme
        .of(context)
        .colorScheme
        .surface;
    if (item.start.isBefore(DateTime.now())) {
      bgColor = Theme
          .of(context)
          .colorScheme
          .secondary;
    }
    Color? borderColor;
    DateTime now = DateTime.now();
    if (item.start.isBefore(now) &&
        item.end.isAfter(now)) {
      borderColor = Theme
          .of(context)
          .colorScheme
          .secondary;
      bgColor = Theme
          .of(context)
          .colorScheme
          .tertiary;
    }
    return Container(
      decoration: (borderColor != null) ? BoxDecoration(
        border: Border.all(
          color: borderColor, // Set border color to blue
          width: 2.0, // Set border width to 2.0
        ),
      ) : BoxDecoration(),
      child: ListTile(
        tileColor: bgColor,
        leading: imageUrl.startsWith("http") ?
        SizedBox(
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
            children: [
              if (item.notifyAfterBreak == true) TextSpan(
                text: '📢 ',
                style: Theme
                    .of(context)
                    .textTheme
                    .titleMedium,
              ),
              TextSpan(
                text: DateFunctions.formatDate(
                    date: item.start,
                    format: 'EEE, dd.MM., HH:mm'),
                style: Theme
                    .of(context)
                    .textTheme
                    .titleMedium,
              ),
              TextSpan(
                text: ' ',
                style: Theme
                    .of(context)
                    .textTheme
                    .titleMedium,
              ),
              if (isFavorite) WidgetSpan(
                child: Icon(
                  Icons.favorite,
                  size: 15,
                  color: Colors.red,
                ),
              ),
              TextSpan(
                text: '\n',
                style: const TextStyle(
                  fontSize: 10,
                ),
              ),
              TextSpan(
                text: TextFunctions.cutTextToWords(
                    text: item.details,
                    length: 30),
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
                    child: EventDetailsPage(item: item),
                  ),
            ),
          );
        },
      ),
    );
  }
}