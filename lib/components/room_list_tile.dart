import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/model/room_data.dart';
import 'package:iccm_eu_app/pages/room_details_page.dart';

class RoomListTile extends StatelessWidget {
  final RoomData item;

  const RoomListTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
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
      const SizedBox(
        height: 100,
        width: 100,
      ),
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
              child: RoomDetailsPage(item: item),
            ),
          ),
        );
      },
    );
  }
}