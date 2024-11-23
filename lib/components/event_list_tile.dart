import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';
import 'package:iccm_eu_app/pages/event_details_page.dart';
import 'package:iccm_eu_app/utils/date_functions.dart';
import 'package:iccm_eu_app/utils/text_functions.dart';

class EventListTile extends StatelessWidget {
  final EventData item;

  const EventListTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: item.imageUrl!.startsWith("http") ?
      CircleAvatar(
          radius: 50.0,
          child: SizedBox(
              width: 100.0, // Diameter of CircleAvatar
              height: 100.0,
              child: CachedNetworkImage(
                imageUrl: item.imageUrl ?? '',
                placeholder: (context, url) => FittedBox(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => FittedBox(
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
          style: DefaultTextStyle.of(context).style,
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
          style: DefaultTextStyle.of(context).style,
          children: <TextSpan>[
            TextSpan(
              text: DateFunctions().formatDate(
                  date: item.start,
                  format: 'EEE, dd.MM., HH:mm'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: '\n',
              style: const TextStyle(
                fontSize: 10,
              ),
            ),
            TextSpan(
              text: '\n',
              style: const TextStyle(
                fontSize: 4,
              ),
            ),
            TextSpan(
              text: TextFunctions.cutTextToWords(
                  text: item.details.text,
                  length: 30),
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
              child: EventDetailsPage(item: item),
            ),
          ),
        );
      },
    );
  }
}