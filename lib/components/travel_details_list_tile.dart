import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/model/travel_details_data.dart';
import 'package:iccm_eu_app/pages/travel_details_page.dart';
import 'package:iccm_eu_app/utils/text_functions.dart';

class TravelDetailsListTile extends StatelessWidget {
  final TravelDetailsData item;

  const TravelDetailsListTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    bool isValidEmoji = (item.emoji != null && item.emoji!.isNotEmpty);
    bool isValidImageUrl = item.imageUrl.startsWith("http");
    return ListTile(
      leading: isValidEmoji ?
        Text(item.emoji ?? '',
          style: TextStyle(
            fontSize: 24,
          ),
        ) :
        isValidImageUrl ?
          CachedNetworkImage(
            imageUrl: item.imageUrl,
            imageBuilder: (context, imageProvider) => CircleAvatar(
              backgroundImage: imageProvider,
              radius: 50,
            ),
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
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
              text: item.name,
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
              text: TextFunctions.cutTextToWords(
                text: item.details,
                length: 20,
              ),
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
              child: TravelDetailsPage(item: item),
            ),
          ),
        );
      },
    );
  }
}