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
    return ListTile(
      leading: RichText(
        text: TextSpan(
          text: item.leading,
          style: Theme
              .of(context)
              .textTheme
              .titleLarge,
        ),
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